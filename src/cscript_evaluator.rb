# new evaluation mix-in module for cscript project
#
# Shou Ya   morning in 17 Apr, 2012
#

require_relative 'cscript_syntree'
require_relative 'cscript_function'
require_relative 'cscript_callstack'

module CScriptEvaluator
    def evaluate(tree)
        if ! running? and ! [:if, :while].include? @type then
            warn 'Unexpected evaluating without running itself'
        end
        @eval_tree = tree

        @i = 0

        retval = case @eval_tree
                 when CScriptValue
                     @eval_tree
                 when :EMPTY
                     nil
                 when :INTEGER, :STRING
                     eval_literal(@eval_tree)
                 when :PLUS, :MINUS, :MULTIPLY, :DIVIDE
                     eval_binary_arithmetic(@eval_tree)
                 when :PRINT
                     eval_debug_print(@eval_tree)
                 when :UMINUS, :UPLUS
                     eval_unary_arithmetic(@eval_tree)
                 when :ASSIGN
                     eval_assignment(@eval_tree)
                 when :NAME
                     eval_name(@eval_tree)
                 when :FUNC_CALL
                     eval_func_call(@eval_tree)
                 else
                     warn "Unknown expression type #{@eval_tree.type}"
                 end
        retval
    end

    def eval_literal(tree)
        return CScriptValue.new(tree.val)
    end
    def eval_binary_arithmetic(tree)
        op1, op2 = tree.op[0..1].map {|x| evaluate x }


        case tree
        when :PLUS
            if op1.type_is? :INTEGER and op2.type_is? :INTEGER then
                return CScriptValue.new(op1.val + op2.val)
            elsif op1.type_is? :STRING and op2.type_is? :STRING then
                return CScriptValue.new(op1.val + op2.val)
            else
                raise CScriptRuntimeError,
                    'Cannot operate PLUS between' \
                    "`#{op1.type}' and `#{op2.type}'.",
                    stack
            end
        when :MINUS
            op1.type_assert :INTEGER, self
            op2.type_assert :INTEGER, self
            return CScriptValue.new(op1.val - op2.val)
        when :MULTIPLY
            if op1.type_is? :INTEGER and op2.type_is? :INTEGER then
                return CScriptValue.new(op1.val * op2.val)
            elsif op1.type_is? :STRING and op2.type_is? :INTEGER then
                return CScriptValue.new(op1.val * op2.val)
            else
                raise CScriptRuntimeError,
                    'Cannot operate MULTIPLY between' \
                    "`#{op1.type}' and `#{op2.type}",
                    stack
            end
        when :DIVIDE
            op1.type_assert :INTEGER, self
            op2.type_assert :INTEGER, self
            return CScriptValue.new(op1.val / op2.val)
        end
    end
    def eval_unary_arithmetic(tree)
        op = evaluate(tree.op[0])

        case tree
        when :UMINUS
            op.type_assert(:INTEGER, self)
            return CScriptValue.new(-op.val)
        when :UPLUS
            op.type_assert(:INTEGER, self)
            return CScriptValue.new(op.val)
        end
    end
    def eval_assignment(tree)
        name = tree.op[0]
        value = evaluate(tree.op[1])

        if name.type != :NAME then
            raise CScriptRuntimeError,
                "The left of assignment must be a lvalue",
                stack
        end

        store_variable(name.val, value)

        return value
    end
    def eval_name(tree)
        value = query_variable(tree.val)

        return value
    end
    def eval_debug_print(tree)
        op = evaluate(tree.op[0])
        if op.type_is? :INTEGER and op.to_i == -1
            puts stack.inspect
        elsif op.type_is? :INTEGER
            puts op.val
        elsif op.type_is? :STRING
            print op.val
        end

        return CScriptValue.new(0)
    end
    def eval_func_call(tree)
        name = tree.op[0]
        args = tree.op[1]
        evaled_args = []

        args.each do |op|
            evaled_args << evaluate(op)
        end


        f = evaluate(name)
        f.type_assert :FUNCTION, stack
        
        param_hash = f.val.make_param_hash(evaled_args)
        
        stack_obj = CScriptCallStack.new :function => f.val,
                                         :parent => self,
                                         :arguments => param_hash,
                                         :function_name => name.val
        return stack_obj.evaluate
    end

    public :evaluate
    private :eval_literal, :eval_binary_arithmetic, :eval_unary_arithmetic,
        :eval_assignment, :eval_name, :eval_debug_print

end
