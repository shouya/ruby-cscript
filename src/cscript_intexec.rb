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

       if !CS_is_false?(cond)
           execute(if_part, if_rt)
       else
           execute(else_part.op[0], if_rt) if tree.length == 3
       end
   end
end
