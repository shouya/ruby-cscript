# Call stack module of cscript project
#
# Shou Ya   evening, 18 Apr, 2012
#

require_relative 'cscript_runstack'

class CScriptCallStack
    attr_accessor :function, :func_name, :arguments
    attr_accessor :name_scope, :parent
    attr_accessor :child_scope
    attr_accessor :return_val

    def initialize(args)
        @function = args[:function] 
        @parent = args[:parent]
        @arguments = args[:arguments]
        @func_name = args[:function_name] || '<annoymous>'
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


