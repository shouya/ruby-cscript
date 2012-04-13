# Internal executor module for cscript project
#
# Shou Ya 12 Apr, 2012 morning
#

module CScriptInternalExecutor
    def exec_if(tree, runtime)
       if_rt = CScriptRuntime.new(runtime, :if)

       cond = evaluate(tree.op[0], if_rt)
       if_part = tree.op[1]
       else_part = tree.op[2] if tree.length == 3

       if !is_false?(cond)
           execute(if_part, if_rt)
       else
           execute(else_part.op[0], if_rt) if tree.length == 3
       end
    end

    def exec_while(tree, runtime)
        while_rt = CScriptRuntime.new(runtime, :while)

        cond = tree.op[0]
        loop_part = tree.op[1]

        loop do
            cond_res = evaluate(cond, while_rt)
            break if is_false? cond_res
            execute(loop_part, while_rt)
        end
    end
end
