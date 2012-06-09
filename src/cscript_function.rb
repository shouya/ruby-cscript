# function class of cscript project
#
# Shou Ya  morning, 19 Apr, 2012
#
#


require_relative 'cscript'

CScript::Runtime  # to load runtime error

module CScript
    class ArugmentError < RuntimeError; end

    class Function
        attr_accessor :parameters, :body, :name

        def initialize(body, parameters = nil, name)
            @body = body
            @parameters = parameters || []
            @name = name
        end

        def validate_body
            # validate some syntax error or stuff here
            return true
        end

        def validate_arguments(args)
            # could add more validation rules here
            return true if args.length == @parameters.length
            return false
        end
        def make_parameter_hash(args)
            if not validate_arguments(args) then
                raise ArgumentError,
                    'Argument(s) not valid',
                    $run_ptr.stack
            end

            return Hash[ *@parameters.zip(args).flatten ]
        end

        def call(runstack, args)
            callstack = CallStack.new(
                runstack.callstack, runstack, self, args)

            callstack.instance_variable_set :@runtime, runstack.runtime \
                unless runstack.type == :root

            return callstack.execute
        end
    end

end
