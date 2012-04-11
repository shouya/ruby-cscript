# executor module of cscript project
#
# Shou Ya  11 Apr, 2012
#
#

require_relative 'cscript_common'
require_relative 'cscript_parser'
require_relative 'cscript_syntree'
require_relative 'cscript_runtime'
require_relative 'cscript_inteval'
require_relative 'cscript_intexec'


class CScriptExecutor
    include CScriptCommon
    include CScriptInternalEvaluator
    include CScriptInternalExecutor
    
    attr_accessor :syntax_tree

    def initialize(tree)
        @syntax_tree = tree
    end
    def execute(tree = nil, runtime = nil)
        tree ||= @syntax_tree
        runtime ||= CScriptRuntime.new(nil, :root)

        loop do
            case tree
            when :STMT
                evaluate(tree.op[0], CScriptRuntime.new(runtime, :stmt))
            when :EMPTY_STMT
                nil
            when :IF_PART
                exec_if(tree, CScriptRuntime.new(runtime, :stmt))
            end

            if tree.next == nil
                break
            else
                tree = tree.next
            end
        end
        
    end


end


