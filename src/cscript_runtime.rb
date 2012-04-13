# Runtime stack module for cscript project
#
# Shou Ya     11 Apr, 2012 night
#
#


class CScriptRuntimeError < Exception; end
class CScriptNoNameError < CScriptRuntimeError; end
class CScriptInvalidStackError < CScriptRuntimeError; end

class CScriptRuntime
    attr_accessor :symbol_table
    attr_accessor :parent
    attr_accessor :type

    def initialize(parent = nil, type = nil)
        @symbol_table = {}
        @parent = parent
        @type = type
    end

    def find_position(symbol_name)
        return self if @symbol_table.has_key? symbol_name
        return @parent.find_position(symbol_name) if has_parent?

        return nil
    end

    def find(symbol_name)
        if pos = find_position(symbol_name)
            return pos.symbol_table[symbol_name]
        else
            raise CScriptNoNameError,
                "Name(#{symbol_name}) not found in symbol table",
                call_stack
        end
    end

    def ===(symbol)
        # USELESS now
        return true if @type == :symbol
        return false
    end
    
    def is_block_scope?
        return true if [:if, :while, :for, :root].include? @type
        return false
    end

    def has_parent?
        return true if @parent
        return false
    end

    def set_local_variable(name, value)
        # PLAN: Check readonly variable here.
        @symbol_table[name] = value
    end
    def set_last_block_variable(name, value)
        if is_block_scope?
            @symbol_table[name] = value
            return self
        end
        if has_parent?
            return @parent.set_last_block_variable(name, value)
        end

        raise CScriptInvalidStackError,
            "Cannot found any valid block scope to set new variable (%s)" %
                     name, call_stack
    end
    def set_variable(name, value)
        found = find_position(name)
        if found
            found.set_local_variable(name, value)
        else
            set_last_block_variable(name, value)
        end
    end
    def set_global_variable(name, value)
        # TODO: add varible into :root scope
    end

    def call_stack
        myself = "#{@type}"
        if has_parent?
            return @parent.call_stack.unshift myself #TODO: and lineno
        end
        return [myself]
    end

end
