# The new runtime class for cscript project
#
# Shou Ya   morning 17 Apr, 2012
#

class CScriptRuntimeError < Exception; end

require_relative 'cscript_runstack'

class CScriptRuntime
    def self.execute(tree, stack = nil)
        stack ||= CScriptRunStack.new(nil, :root)
        stack.execute(tree)
    end

    if $CS_DEBUG
        attr_accessor :emissions
    end

    def execute(tree, stack = nil)
        stack ||= CScriptRunStack.new(nil, :root)
        stack.execute(tree)
        if $CS_DEBUG
            @emissions = stack.emissions
        end
    end
end
