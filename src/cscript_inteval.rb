# Internal evaluate module of cscript project
#
# Shou Ya   11 Apr, 2012
#
#


module CScriptInternalEvaluator
    require_relative 'cscript_value'

    def eval_ignore(tree, runtime)
        nil
    end

    def eval_value(tree, runtime)
        case tree
        when :INTEGER, :STRING
            return CScriptValue.new(tree.val)
        when :NAME
            return runtime.find(tree.val)
        end

        warn "WTF is this value #{tree.val} of #{tree.type}"
    end

    def eval_unary(tree, runtime)
        val = evaluate(tree.op[0], runtime)
        case tree
        when :UMINUS
            val.type_assert(:INTEGER, runtime.call_stack)
            return -val.val
        when :UPLUS
            val.type_assert(:INTEGER, runtime.call_stack)
            return val.val
        when :PRINT
            if val.type_is? :INTEGER and val.to_i == -1
                puts runtime.call_stack.inspect
                return 0
            end
            return puts val.val.inspect
        end

        warn "WTF is this unary operation #{tree.type}"
        nil
    end

    def eval_binary(tree, runtime)
        op1 = evaluate(tree.op[0], runtime)
        op2 = evaluate(tree.op[1], runtime)

        case tree
        when :PLUS
            op1.type_assert :INTEGER, runtime.call_stack
            op2.type_assert :INTEGER, runtime.call_stack
            return CScriptValue.new(op1.val + op2.val)
        when :MINUS
            op1.type_assert :INTEGER, runtime.call_stack
            op2.type_assert :INTEGER, runtime.call_stack
            return CScriptValue.new(op1.val - op2.val)
        when :MULTIPLY
            op1.type_assert :INTEGER, runtime.call_stack
            op2.type_assert :INTEGER, runtime.call_stack
            return CScriptValue.new(op1.val * op2.val)
        when :DIVIDE
            op1.type_assert :INTEGER, runtime.call_stack
            op2.type_assert :INTEGER, runtime.call_stack
            return CScriptValue.new(op1.val / op2.val)
        end
        warn "WTF is this binary operation #{tree.type}"

        nil
    end
    def eval_assign(tree, runtime)
        name = tree.op[0]
        if !name.type_is? :NAME
            raise CScriptRuntimeError,
                "Can't be not a name as left operand" \
                   "of an assignment operation",
                runtime.call_stack
        end

        rhs = evaluate(tree.op[1], runtime)

        runtime.set_variable(name.val, rhs)

        return rhs
    end

    def evaluate(tree, runtime)
        case tree
        when :INTEGER, :STRING, :NAME
            return eval_value(tree, runtime)
        when :PLUS, :MINUS, :MULTIPLY, :DIVIDE
            return eval_binary(tree, runtime)
        when :UMINUS, :UPLUS, :PRINT
            return eval_unary(tree, runtime)
        when :EMPTY
            return eval_ignore(tree, runtime)
        when :ASSIGN
            return eval_assign(tree, runtime)
        end
        warn "Unrecognized type of tree: #{tree.type}"
    end
end
