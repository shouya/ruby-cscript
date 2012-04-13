# Internal evaluate module of cscript project
#
# Shou Ya   11 Apr, 2012
#
#

module CScriptInternalEvaluator
    def eval_ignore(tree, runtime)
        nil
    end

    def eval_value(tree, runtime)
        val = tree.val

        case tree
        when :INTEGER
            return val
        when :NAME
            return runtime.find(val)
        when :STRING
            return val
        end

        nil
    end

    def eval_unary(tree, runtime)
        val = evaluate(tree.op[0], runtime)
        case tree
        when :UMINUS
            return -val
        when :UPLUS
            return val
        when :PRINT
            if val == -1
                puts runtime.call_stack.inspect
                return 0
            end
            return puts val
        end

        warn "WTF is this(unary) #{tree.type}"
        nil
    end

    def eval_binary(tree, runtime)
        op1 = evaluate(tree.op[0], runtime)
        op2 = evaluate(tree.op[1], runtime)

        case tree
        when :PLUS
            return op1 + op2
        when :MINUS
            return op1 - op2
        when :MULTIPLY
            return op1 * op2
        when :DIVIDE
            return op1 / op2
        end
        warn "WTF is this(binary) #{tree.type}"

        nil
    end
    def eval_assign(tree, runtime)
        name = tree.op[0]
        if name.type != :NAME
            raise CScriptRuntimeError,
                "Can't be not a name as left operand of an assignment operation",
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
