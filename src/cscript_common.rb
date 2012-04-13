# common operations for cscript project
#
# Shou Ya   12 Apr, 2012  morning
#
#

module CScriptCommon
    def is_false?(obj)
        case obj
        when String
            return obj.length == 0
        when Fixnum
            return obj == 0
        when NilClass
            return true
        end
    end
    def is_block?(scope) # actually it should special a Runtime object
        case scope
        when :if, :while, :for, :root
            return true
        end
        return false
    end
end


