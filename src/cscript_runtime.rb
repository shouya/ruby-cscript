# The new runtime class for the cscript project
#
# Shou, 24 May, 2012
#

require_relative 'cscript'

module CScript
    class RuntimeError < CScriptError; end
    class Runtime
        attr_reader :program
        attr_reader :root_stack # The root runtstack
        attr_reader :symbol_table
        attr_reader :processor # Macro processor

        def initialize(program)
            @program = program
            @root_stack = RunStack.new(nil, :root)
            @root_stack.instance_exec(self) { |rt| @runtime = rt }
            @symbol_table = SymbolTable.new(nil)
            @processor = Processor.new
        end

        def execute_code(code_tree)
            @root_stack.execute(code_tree)
        end
        def process(callerx, tree)
            @processor.process(callerx, tree)
        end

=begin Deprecated
        def initialize(dispatcher)
            @dispatcher = dispatcher
            @project = dispatcher.program
            @runstack = RunStack.new(self)
        end

        def execute(tree)
            case
            when tree['type'] == 'STATEMENTS'
                @dispatcher.execute(tree)
            else
                @last_statement = @runstack.execute(tree)
            end
        end

        def evaluate(tree)
        end
=end
    end
end

