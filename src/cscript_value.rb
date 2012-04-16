# Value Class for cscript project
# this class is for the storing a cscript variable
#
# Shou Ya   morning 15 April, 2012
#
#

class CScriptTypeError < CScriptRuntimeError; end

class CScriptValue
    attr_accessor :value, :type
    alias :val :value
    alias :val= :value=
    attr_accessor :first_defined, :last_assigned

    def initialize(value = nil, type = nil)
        if value == nil
            @value = nil
            @type = :NULL
        else
            if type == nil
                @type = CScriptValue.detect_type(value)
                if @type == :NAME
                    @value = value.to_s
                    return self
                end
            else
                @type = type
            end
            @value = value
        end

        @first_assigned = nil
        @last_defined = nil

        return self
    end

    def self.detect_type(val)
        case val
        when String
            return :STRING
        when Fixnum, Bignum
            return :INTEGER
        when NilClass
            return :NULL
        when Symbol
            return :NAME
        else
            warn "WTF is this value(#{val}, #{val.class})!"
        end
    end

    def type_is?(*arg)
        return arg.include? @type
    end

    def type_assert(*arg, stack)
        if arg.empty?
            arg << stack
            stack = nil
        end
        if !type_is? *arg
            raise CScriptTypeError,
                "Not expected type",
                stack.stack if stack
            raise CScriptTypeError,
                "Not expected type"
        end
        true
    end

    def to_i
        type_assert(:INTEGER, :NULL)
        return @value.to_i
    end
    def to_s
        case @type
        when :STRING
            return @value
        when :INTEGER
            return @value.to_s
        when :NULL
            return ''
        end
        return @value.to_s
    end

    def is_false?
        case @type
        when :STRING
            return @value.length == 0
        when :INTEGER
            return @value == 0
        when :NULL
            return true
        end
    end
    def is_true?
        return !is_false?
    end

    def is_function?
        return @type == :FUNCTION
    end

end


