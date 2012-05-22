# new evaluation mix-in module for cscript project
#
# Shou Ya   morning in 17 Apr, 2012
#

require_relative 'cscript_syntax_tree'
require_relative 'cscript_function'
require_relative 'cscript_callstack'

module CScriptEvaluator
    def self.handler(*handle_types, &block)
        @@handlers ||={}

        evaled = []
        opt = {}
        if handle_types.last.class == Hash
            opt = handle_types.pop
        end
        if handle_types.last.class == Array
            evaled = handle_types.pop
        end

=begin
        # Not needed yet, use `Object#instance_exec` instead
        method_name = 'eval_' + handle_types.map(&:to_s).join('_')
        method_name = method_name.intern

        # Cool meta stuff! borrow from from source of sinatra
        define_method(method_name, block)
        method = instance_method method_name
        remove_method method_name
=end

        @@handlers.store(handle_types, [block, evaled, opt])
    end

    def eval_error(msg_or_exc, *others)
        if others.empty? or others.last.class != Array then
            others.push(stack)
        end

        if msg_or_exc.is_a? Exception
            raise msg_or_exc, *others
        elsif msg_or_exc.is_a? String
            raise CScriptRuntimeError, msg_or_exc, *others
        end
    end


    def newval(*args)
        CScriptValue.new(*args)
    end

    def dispatch(tree)
        @@handlers ||={}
        retval = nil

        matched = @@handlers.each do |match, (block, evaled, opt)|
            next unless match.include? tree.type

            args = []

            unless opt[:raw] == true
                tree.op.each_with_index do |op, idx|
                    if evaled.include? idx
                        args << evaluate(op)
                    else
                        args << op
                    end
                end
            else
                args << tree
            end

            retval = self.instance_exec(*args, &block)

            break :yes
        end

        if matched != :yes
            eval_error('Not handled type: %s.' % tree.type.to_s)
        end

        return retval
    end

    def evaluate(tree)
        if not running? and ! [:if, :while].include? @type then
            warn 'Unexpected evaluating without running itself'
        end

        @eval_tree = tree

        dispatch(tree)
    end


    handler :EMPTY do
        nil
    end

    handler :INTEGER, :STRING, :BOOL, :FUNCTION, :raw => true do |tree|
        newval(tree.val)
    end

    handler :PLUS, [0,1] do |op1, op2|
        if op1.type_is? :INTEGER and op2.type_is? :INTEGER then
            newval(op1.val + op2.val)
        elsif op1.type_is? :STRING and op2.type_is? :STRING then
            newval(op1.val + op2.val)
        else
            eval_error("Type Error")
        end
    end

    handler :MINUS, [0, 1] do |op1, op2|
        op1.type_assert :INTEGER, self
        op2.type_assert :INTEGER, self
        newval(op1.val - op2.val)
    end

    handler :MULTIPLY, [0, 1] do |op1, op2|
        if op1.type_is? :INTEGER and op2.type_is? :INTEGER then
            newval(op1.val * op2.val)
        elsif op1.type_is? :STRING and op2.type_is? :INTEGER then
            newval(op1.val * op2.val)
        else
            eval_error("Type Error")
        end
    end

    handler :DIVIDE, [0, 1] do |op1, op2|
        op1.type_assert :INTEGER, self
        op2.type_assert :INTEGER, self
        newval(op1.val / op2.val)
    end

    handler :UMINUS, [0] do |op|
        op.type_assert :INTEGER, self
        newval(-op.val)
    end
    handler :UPLUS, [0] do |op|
        op
    end

    handler :ASSIGN, [1] do |name, value|
        if name.type != :NAME then
            eval_error "The left of assignment must be a lvalue."
        end

        store_variable(name.val, value)
        value
    end

    handler :NAME, :raw => true do |tree|
        query_variable(tree.val)
    end

    if $CS_DEBUG then
        handler :DEBUG_EMIT, [0] do |value|
            root.emit(value.val)
        end
    end

    handler :FUNC_CALL do |name, args|
        f = evaluate(name)
        f.type_assert :FUNCTION, stack

        args = args.map {|x| evaluate x}

        param_hash = f.val.make_param_hash(args)

        stack_obj = CScriptCallStack.new :function => f.val,
                                         :parent => self,
                                         :arguments => param_hash,
                                         :function_name => name.val
        return stack_obj.evaluate
    end

    handler :COMPARISON, [0, 2] do |op1, operator, op2|
        unless op1.type == op2.type then
            eval_error "Type of operands are not same. (%s vs %s)." % [
                    op[0].type.downcase, op[1].type.downcase]
        end
        op1, op2 = op1.value, op2.value

        case operator
        when :==
            return newval(op1 == op2)
        when :!=
            return newval(op1 != op2)
        when :<
            return newval(op1 < op2)
        when :<=
            return newval(op1 <= op2)
        when :>
            return newval(op1 > op2)
        when :>=
            return newval(op1 >= op2)
        end
    end

    handler :AND, [0], &lambda {|x, y|
        return newval(false) unless x.is_true?
        y = evaluate(y)
        return newval(false) unless x.is_true?

        return newval(true)
    }

    handler :OR, [0], &lambda {|x, y|
        return x if x.is_true?

        y = evaluate(y)
        return y if y.is_true?

        return newval(false)
    }

    handler :NOT, [0] do |v|
        return newval(v.is_false?)
    end

end
