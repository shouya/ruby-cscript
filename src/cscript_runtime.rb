# Runtime stack module for cscript project
#
# Shou Ya     11 Apr, 2012 night
#
#


class CScriptRuntimeError < Exception; end
class CScriptNoNameError < CScriptRuntimeError; end


class CScriptRuntime
    attr_accessor :symbol_table
    attr_accessor :parent
    attr_accessor :type

    def initialize(parent = nil, type = nil)
        @symbol_table = {}
        @parent = parent
        @type = type
    end

    def find(symbol_name)
        p = self
        loop do
            return p[symbol_name] if p.has_key? symbol_name
            if p.parent != nil
                p = p.parent
                next
            end

            raise CScriptNoNameError,
                "Name not found in symbol table",
                stack
        end
    end
    
end
