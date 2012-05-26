# new evaluation mix-in module for cscript project
#
# Shou Ya   morning in 17 Apr, 2012
#

require_relative 'cscript_function'

require 'pp' if $CS_DEBUG

module CScript
    class LoopControl < CScriptControl; end
    class LoopControlRedo < LoopControl; end
    class LoopControlBreak < LoopControl
        attr_accessor :level
    end
    class LoopControlNext < LoopControl; end

    class Executor
        attr_reader :stack
        class << self
            attr_reader :table
            def handle(type, &block)
                (@table ||= {}).store(type.to_s, block)
            end
        end

        def initialize(runstack)
            @stack = runstack
        end

        def dispatch(tree)
            assert_error "Unhandled statement type: #{tree['type']}" do
                self.class.table.has_key?(tree['type'])
            end
            self.instance_exec(tree, &self.class.table[tree['type']])
        end

        def execute(tree)
            @stack.run_ptr = tree
            dispatch(tree)
        end

        handle :EMPTY_STMT do
            nil
        end

        handle :EXPR_STMT do |tree|
            @stack.last_value = @stack.evaluate(tree['operands'][0])
        end

        handle :IF1 do |tree|
            substack = RunStack.new(@stack, :if)
            cond = tree['operands'][0]['operands'][0]
            if_part = tree['operands'][0]['operands'][1]

            if (@stack.last_value = substack.evaluate(cond)).is_true?
                substack.execute(if_part)
            end

            @stack.last_value = substack.last_value
        end

        handle :IF2 do |tree|
            substack = RunStack.new(@stack, :if)
            cond = tree['operands'][0]['operands'][0]
            if_part = tree['operands'][0]['operands'][1]
            else_part = tree['operands'][0]['operands'][2]

            if (@stack.last_value = substack.evaluate(cond)).is_true?
                substack.execute(if_part)
            else
                substack.execute(else_part)
            end
            @stack.last_value = substack.last_value
        end

        handle :WHILE do |tree|
            substack = RunStack.new(@stack, :while)

            cond = tree['operands'][0]['operands'][0]
            body = tree['operands'][0]['operands'][1]


            loop do # Cooloop
                cond_res = while_stack.evaluate(cond)
                @stack.last_value = cond_res

                break if cond_res.is_false?

                begin
                    substack.execute(loop_part)
                    @stack.last_value = substack.last_value
                rescue LoopControlRedo
                    retry
                rescue LoopControlBreak
                    break
                rescue LoopControlNext
                    # Do nothing, it just jump from loop body
                end
            end
        end

        handle :FUNC_DEF do |tree|
            func_name = tree['operands'][0]['value']
            parameters = tree['operands'][1]['subnodes'].map{|x| x['value']}
            body = tree['operands'][2]

            func_obj = Value.new(Function.new(body, param, func_name))
            @stack.store(func_name, func_obj)

            @stack.last_value = Value.null
        end

        handle :RETURN do |tree|
            ret_vals = tree['operands']

            if ret_vals.empty?
                @stack.callstack.return
            else
                @stack.callstack.return(@stack.evaluate(ret_vals.first))
            end
        end

        handle :REDO do
            raise LoopControlRedo
        end

        handle :NEXT do
            raise LoopControlNext
        end

        handle :BREAK do
            raise LoopControlBreak
        end

        handle :STATEMENTS do |tree|
            tree['subnodes'].each do |stmt|
                @stack.dispatch(stmt)
            end
        end

        public :execute
    end
end
