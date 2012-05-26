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

                method_name = 'tmpm_' + handle_types.join('_').downcase
                method_name = method_name.intern

                Object.send(:define_method, method_name, &block)
                unbinded = Object.send(:instance_method, method_name)
                Object.send(:remove_method, method_name)

                @table.store(handle_types, {
                    :block => unbinded,
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
                raise RuntimeError, msg_or_exc, *others
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

            retval = handler[:block].bind(self).call(*args)

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
                return op1 + op2
            else
                eval_error("Type Error")
            end
        end

        handle :MINUS, [0, 1] do |op1, op2|
            op1.type_assert :INTEGER
            op2.type_assert :INTEGER
            return op1 - op2
        end

        handle :MULTIPLY, [0, 1] do |op1, op2|
            if (op1.type_is? :INTEGER and op2.type_is? :INTEGER) or
                (op1.type_is? :STRING and op2.type_is? :INTEGER) then
                return op1 * op2
            else
                eval_error("Type Error")
            end
        end

        handle :DIVIDE, [0, 1] do |op1, op2|
            op1.type_assert :INTEGER
            op2.type_assert :INTEGER
            op1 / op2
        end

        handle :UMINUS, [0] do |op|
            op.type_assert :INTEGER
            return op.send(:-@)  # :-@ 囧
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


        handle :FUNC_CALL do |name, args|
            func = @stack.evaluate(name)
            func.type_assert :FUNCTION

            args.map! {|x| evaluate x}

            callstack = CallStack.new(@stack.callstack, func, args)

            if @stack.type == :root
                callstack.instance_exec(@stack.runtime) do |rt|
                    @runtime = rt
                end
            end

            callstack.execute

            return callstack.return_value
        end

        handle :COMPARISON, [0, 2] do |op1, operator, op2|
            unless op1.type == op2.type then
                eval_error \
                    "Type of operands are not same. (%s vs %s)." % [
                    op[0].type.downcase, op[1].type.downcase]
            end
            op1, op2 = op1.value, op2.value

            case operator
            when :==
                return (op1 == op2)
            when :!=
                return (op1 != op2)
            when :<
                return (op1 < op2)
            when :<=
                return (op1 <= op2)
            when :>
                return (op1 > op2)
            when :>=
                return (op1 >= op2)
            end
        end

        handle :AND, [0] do |x, y|
            return false unless x.is_true?
            y = @stack.evaluate(y)
            return false unless x.is_true?

            return true
        end

        handle :OR, [0] do |x, y|
            return x if x.is_true?

            y = evaluate(y)
            return y if y.is_true?

            return false
        end

        handle :NOT, [0] do |v|
            return v.is_false?
        end

    end
end
