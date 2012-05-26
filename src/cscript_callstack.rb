# Call stack module of cscript project
#
# Shou Ya   evening, 18 Apr, 2012
#

require_relative 'cscript_runstack'

module CScript
    class ReturnSignal < CScriptControl; end

    class CallStack
        # Meta Info
        attr_reader :caller # Parent of callstack
        attr_reader :runtime # Runtime of the program
        attr_reader :function # Function of the stack, `Function` object
        attr_reader :arguments # Arguments to call the function, Array of Value

        # Dynamic Changed
        attr_accessor :current_runstack

        # Dynamic Generated
        attr_reader :runstack
        attr_reader :return_value # Return value


=begin Deprecated
        attr_accessor :function, :func_name, :arguments
        attr_accessor :name_scope, :parent
        attr_accessor :child_scope
        attr_accessor :return_val
=end

        def initialize(x_caller, function, arguments = nil)
            @caller = x_caller
            @runtime = x_caller ? x_caller.runtime : nil
            @function = function
            @arguments = argumemnts || []

            @return_value = nil
        end

        def execute
            @runstack = RunStack.new(nil, :func_call)
            @runstack.instance_exec(self) do |who|
                @callstack = who
                @runtime = who.runtime
            end

            @current_runstack = @runstack

            @function.make_parameters_hash(@arguments).each do |p, a|
                @runstack.store_local(p, a)
            end

            begin
                @runstack.execute(@function.body)
            rescue ReturnSignal
                return @return_value
            else
                @return_value = @current_runstack.last_value
            end

            @return_value
        end

        def return(return_value = nil)
            @return_value = return_value
            raise ReturnSignal
        end


=begin Deprecated
        def initialize(args)
            @function = args[:function]
            @parent = args[:parent]
            @arguments = args[:arguments]
            @func_name = args[:function_name] || '<anonymous>'
            @name_scope = args[:name_scope] || @parent.root
        end

        def execute()
            @child_scope = CScriptRunStack.new(@name_scope, :func_call)
            @child_scope.call_stack = self

            @child_scope.append_variables(@arguments)

            ret = catch :return do
                @child_scope.execute(function.body)
                :not_returned
            end

            if ret == :not_returned then
                @return_val = @child_scope.last_value
            end
            return @return_val
        end
        alias :evaluate :execute

        def location
            return @parent.run_ptr.place_str
        end
        def args_str
            arguments.map { |k,v| "#{k}: #{v.val}" }.join ', '
        end
        def stack()
            myself = "[#{@func_name} (#{args_str}) at #{location}]"
            return @parent.stack.unshift myself if @parent
            return [myself]
        end
    end

=end
end

