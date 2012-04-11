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
        end
        nil
    end

    def eval_unary(tree, runtime)
        val = evaluate(tree.op[0], runtime)
        case tree
        when :PRINT
            return (puts val)
        end
        nil
    end

    def eval_binary(tree, runtime)
        op1, op2 = tree.op[0..1]

        case tree
        when :PLUS
            return evaluate(op1, runtime) + evaluate(op2, runtime)
        when :MINUS
            return evaluate(op1, runtime) - evaluate(op2, runtime)
        when :MULTIPLY
            return evaluate(op1, runtime) * evaluate(op2, runtime)
        when :DIVIDE
            return evaluate(op1, runtime) / evaluate(op2, runtime)
        end
        nil
    end

    def evaluate(tree, runtime)
        case tree
        when :INTEGER, :STRING, :NAME
            return eval_value(tree, runtime)
        when :PLUS, :MINUS, :MULTIPLY, :DIVIDE
            return eval_binary(tree, runtime)
        when :PRINT
            return eval_unary(tree, runtime)
        when :EMPTY
            return eval_ignore(tree, runtime)
        end
    end
end
