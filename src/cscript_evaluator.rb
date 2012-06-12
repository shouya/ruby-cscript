# new evaluation mix-in module for cscript project
#
# Shou Ya   morning in 17 Apr, 2012
#
# -*- encoding: utf-8 -*-

require_relative 'cscript'

module CScript
    class Evaluator
        attr_reader :stack

        class << self
            attr_reader :table
            def handle(*handle_types, &block)
                @table ||={}

                evaled = []
                options = {}
                if handle_types.last.class == Hash
                    options = handle_types.pop
                end
                if handle_types.last.class == Array
                    evaled = handle_types.pop
                end
                handle_types.map!(&:to_s)

=begin
                method_name = 'tmpm_' + handle_types.join('_').downcase
                method_name = method_name.intern

                Object.send(:define_method, method_name, &block)
                unbinded = Object.send(:instance_method, method_name)
                Object.send(:remove_method, method_name)
=end

                @table.store(handle_types, {
                    :block => block,
                    :evaluated => evaled,
                    :options => options})
            end
        end

        def initialize(runstack)
            @stack = runstack
        end

        def eval_error(msg_or_exc, *others)
            if others.empty? or others.last.class != Array then
                others.push(stack)
            end

            if msg_or_exc.is_a? Exception
                raise msg_or_exc, *others
            elsif msg_or_exc.is_a? String
                raise RuntimeError, msg_or_exc #, *others
            end
        end

        def dispatch(tree)
            handlers = self.class.table || {}
            type = tree['type']

            assert_error "Handler not implemented for #{type}" do
                handlers.keys.flatten.include? type
            end

            handler = nil
            handlers.each do |k, v|
                next unless k.include? type
                handler = v
            end

            retval = nil
            args = []

            if handler[:options][:raw] then
                args << tree
            else
                tree['operands'].each_with_index do |op, idx|
                    args << (handler[:evaluated].include?(idx) ? \
                             @stack.evaluate(op) : op)
                end
            end

#            retval = handler[:block].bind(self).call(*args)
            retval = self.instance_exec(*args, &handler[:block])

            retval = Value.new(retval) unless Value === retval

            return retval
        end

        def evaluate(tree)
            return dispatch(tree)
        end

        handle :EMPTY do
            nil
        end

        handle :INTEGER, :STRING, :BOOL, :raw => true do |tree|
            tree['value']
        end

        handle :PLUS, [0,1] do |op1, op2|
            if (op1.type_is? :INTEGER and op2.type_is? :INTEGER) or
               (op1.type_is? :STRING and op2.type_is? :STRING) then
                next op1 + op2
            else
                eval_error("Type Error on plus operator, " \
                        "expected two strings or two numbers but got " \
                        "#{op1.type} and #{op2.type}.")
            end
        end

        handle :MINUS, [0, 1] do |op1, op2|
            op1.type_assert :INTEGER
            op2.type_assert :INTEGER
            next op1 - op2
        end

        handle :MULTIPLY, [0, 1] do |op1, op2|
            if (op1.type_is? :INTEGER and op2.type_is? :INTEGER) or
                (op1.type_is? :STRING and op2.type_is? :INTEGER) then
                next op1 * op2
            else
                eval_error("Type Error")
            end
        end

        handle :DIVIDE, [0, 1] do |op1, op2|
            op1.type_assert :INTEGER
            op2.type_assert :INTEGER
            op1 / op2
        end

        handle :MOD, [0, 1] do |op1, op2|
            op1.type_assert :INTEGER
            op2.type_assert :INTEGER
            op1 % op2
        end

        handle :UMINUS, [0] do |op|
            op.type_assert :INTEGER
            next op.send(:-@)  # :-@ 囧
        end
        handle :UPLUS, [0] do |op|
            op
        end

        handle :ASSIGN, [1] do |name, value|
            if name['type'] != 'NAME' then
                eval_error "The left of assignment must be an lvalue."
            end

            @stack.store(name['value'], value)
            value
        end

        handle :NAME, :raw => true do |tree|
            @stack.find(tree['value'])
        end


        handle :FUNC_CALL, [0] do |name, o_args|
            error_raise 'Object is not callable.' unless name.callable?

            args = o_args['subnodes'].map {|x| evaluate x}

            case name.type
            when :FUNCTION
                next name.call(@stack, args)
            when :LAMBDA
                next name.call(@stack, args)
            else
                raise 'wtf?!'
            end

            callstack.execute

            next callstack.return_value
        end

        handle :COMPARISON, [0, 2] do |op1, operator, op2|
            unless op1.type == op2.type then
                eval_error \
                    "Type of operands are not same. (%s vs %s)." % [
                    op[0].type.downcase, op[1].type.downcase]
            end
            op1, op2 = op1.value, op2.value

            case operator.intern
            when :==
                next (op1 == op2)
            when :!=
                next (op1 != op2)
            when :<
                next (op1 < op2)
            when :<=
                next (op1 <= op2)
            when :>
                next (op1 > op2)
            when :>=
                next (op1 >= op2)
            end
        end

        handle :AND, [0] do |x, y|
            next false unless x.is_true?
            y = @stack.evaluate(y)
            next false unless y.is_true?

            next true
        end

        handle :OR, [0] do |x, y|
            next x if x.is_true?

            y = evaluate(y)
            next y if y.is_true?

            next false
        end

        handle :NOT, [0] do |v|
            next v.is_false?
        end

        handle :LAMBDA do |lbd|
            if lbd['type'] == 'BLOCK'        # block without params
                next Lambda.new(@stack, lbd['operands'][0])
            end

            params = lbd['operands'][0]['subnodes'].map {|x| x['value'] }
            body = lbd['operands'][1]

            next Lambda.new(@stack, body, params)
        end
    end
end
