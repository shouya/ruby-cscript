# new evaluation mix-in module for cscript project
#
# Shou Ya   morning in 17 Apr, 2012
#

require_relative 'cscript_function'

require 'pp'

module CScriptExecutor
    def execute(tree)
        if running? then
            warn 'Do not execute anything inside itself while running'
            return
        end
        @tree = tree
        @state = :running
        @current_child = nil
        @last_value = nil

        @run_ptr = @tree

        loop do
            break if @run_ptr.nil?
            step()
        end
        @state = :finished
        @last_value
    end

    def step()
        case @run_ptr
        when :EXPR_STMT
            @last_value = evaluate(@run_ptr.op[0])
        when :EMPTY_STMT
            nil
        when :IF_PART
            @last_value = exec_if
        when :WHILE
            @last_value = exec_while
        when :FUNC_DEF
            @last_value = exec_func_def
        when :RETURN
            @last_value = exec_return
        else
            warn "Unknown statement: #{@run_ptr.type} at #{@run_ptr.place_str}"
        end

        @run_ptr = @run_ptr.next
    end

    def exec_if
        if_stack = CScriptRunStack.new(self, :if)
        @current_child = if_stack

        cond = if_stack.evaluate(@run_ptr.op[0])
        @last_value = cond

        has_else_block = (@run_ptr.length == 3)

        if_part = @run_ptr.op[1]
        else_part = @run_ptr.op[2].op[0] if has_else_block

        if ! cond.is_false? then
            @last_value = if_stack.execute(if_part)
        else
            @last_value = if_stack.execute(else_part) if has_else_block
        end

        @current_child = nil
        @last_value
    end
    def exec_while
        while_stack = CScriptRunStack.new(self, :while)
        @current_child = while_stack

        cond = @run_ptr.op[0]
        loop_part = @run_ptr.op[1]

        loop do
            cond_res = while_stack.evaluate(cond)
            @last_value = cond_res

            break if cond_res.is_false?

            @last_value = while_stack.execute(loop_part)
        end

        @current_child = nil
        @last_value
    end

    def exec_func_def
        func_name = @run_ptr.op[0]
        param = @run_ptr.op[1].map { |x| x.val }
        body = @run_ptr.op[2..-1].inject { |b,n| b.append(n) }

        func_obj = CScriptValue.new(
            CScriptFunction.new(body, param, func_name.val))
        gen_stmt = CScriptSyntaxTree::CSCtrl.new(:ASSIGN, func_name, func_obj)
        gen_stmt.place = func_name.place
        root.evaluate(gen_stmt)
    end
    def exec_return
        has_retval = @run_ptr.op.length == 1
        if has_retval then
            @call_stack.return_val = evaluate(@run_ptr.op[0])
        else
            @call_stack.return_val = CScriptValue.new(nil)
        end
        throw :return
    end

    public :execute, :step
    private :exec_if, :exec_while

end
