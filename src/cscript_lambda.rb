# Lambda object support for cscript project
#
# by Shou Ya, at June 10, 2012
#

require 'cscript'

CScript::CallStack   # for ReturnSignal class

module CScript
    class Lambda
        attr :parameters
        attr :body
        attr :binding
        attr :options

        def initialize(runstack, body, params = [])
            @parameters = params
            @body = body

            @binding = runstack.make_binding
        end

        def make_paramter_hash(args)
            return Hash[ *@parameters.zip(args).flatten ]
        end

        def call(runstack, args)
            lambda_stack = RunStack.new(runstack, :lambda)
            lambda_stack.set_variables(@binding)
            lambda_stack.set_variables(make_paramter_hash(args))

            begin
                lambda_stack.execute(@body)
            rescue ReturnSignal => ret
                return ret.return_value
            else
                lambda_stack.last_value
            end
        end

        class << self
            def return(return_value)
                raise ReturnSignal.new(return_value)
            end
        end
    end
end


