# common operations for cscript project
#
# Shou Ya   12 Apr, 2012  morning
#
#

module CScriptCommon
    def CS_is_false?(obj)
        case obj
        when String
            return obj.length == 0
        when Fixnum
            return obj == 0
        when NilClass
            return true
        end
    end
end


