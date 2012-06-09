# Value Class for cscript project
# this class is for the storing a cscript variable
#
# Shou Ya   morning 15 April, 2012
#
#

require 'cscript'

module CScript
    class TypeError < RuntimeError; end

    class Value < BasicObject # BlankSlate
        attr_accessor :value, :type
        alias :val :value
#        attr_accessor :first_defined, :last_assigned

        class << self
            def null
                @null ||= Value.new(nil)
            end
            def detect_type(value)
                case value
                when String
                    return :STRING
                when Fixnum, Bignum
                    return :INTEGER
                when NilClass
                    return :NULL
                when Symbol
                    return :NAME
                when TrueClass, FalseClass
                    return :BOOL
                when Function
                    return :FUNCTION
                when Lambda
                    return :LAMBDA
                else
                    raise TypeError,
                        %{Unknown type of "#{value}"}
                end
            end
        end

        def initialize(value, type = nil)
            @value = value
            @type = type || Value.detect_type(@value)
        end

        def type_is?(*arg)
            return arg.include? @type
        end

        def type_assert(*arg, stack)
            arg << stack and stack = nil if arg.empty?
            if !type_is? *arg
                raise TypeError, "Not expected type, expect #{
                    arg.map(&:to_s).join(', ')} but get #{@type}"
            end
            true
        end

        def to_i
            type_assert(:INTEGER, :NULL, :BOOL)
            case @type
            when :BOOL
                return @value ? 1 : 0
            else
                return @value.to_i
            end
        end
        def to_s
            case @type
            when :STRING
                return @value
            when :INTEGER
                return @value.to_s
            when :BOOL
                return @value.to_s
            when :NULL
                return ''
            else
                return @value.to_s
            end
        end
        def inspect
            return "#{@type}: #{@value.inspect}"
        end

        def is_false?
            case @type
            when :STRING
                return @value.length == 0
            when :INTEGER
                return @value == 0
            when :BOOL
                return @value == false
            when :NULL
                return true
            end
        end
        def is_true?
            return !is_false?
        end

        def callable?
            return (is_function? || is_lambda?)
        end
        def is_function?
            return @type == :FUNCTION
        end
        def is_lambda?
            return @type == :LAMBDA
        end


        def method_missing(m, *args, &block)
            args.map! {|x| Value === x ? x.value : x }
            @value.send(m, *args, &block)
        end

        def equal_to?(other)
            return true if self.object_id == other.object_id
            return false if @type != other.type
            return true if @value = other.value
        end
        alias_method :==, :equal_to?
    end
end

