# Runstack moudle for cscript project
#
# Shou Ya,  morning in 17th April, 2012
#

require_relative 'cscript_value'
require_relative 'cscript_evaluator'
require_relative 'cscript_executor'

class SomeError < Exception; end

class CScriptRunStack
    include CScriptEvaluator
    include CScriptExecutor

    attr_accessor :type, :parent, :state    # meta info
    # execution info
    attr_accessor :run_ptr, :eval_tree, :current_child, :last_value
    attr_accessor :tree, :table   # content data

    def initialize(parent = nil, type = nil)
        @type = type
        @run_ptr = nil
        @current_child = nil
        @parent = parent
        @state = :initial

        @tree = nil
        @table = {}
    end

    def query_variable(name)
        found = upfind_variable(name)
        if ! found then
            raise CScriptRuntimeError,
                "Variable `#{name}' not found!",
                stack
        end

        return found.query_local_variable(name)
    end
    def store_variable(name, value)
        found = upfind_variable(name)
        if found then
            value.last_assigned = @eval_tree.place
            found.store_local_variable(name, value)
        else
            value.last_assigned = value.first_defined = @eval_tree.place
            
            block = upfind_variable_storable
            if block then
                block.store_local_variable(name, value)
            else
                raise CScriptRuntimeError,
                    'Storage variable but not block scope found',
                    stack
            end
        end
    end

    def query_local_variable(name)
        return @table.fetch(name)
    end

    def store_local_variable(name, value)
        @table.store(name, value)
    end

    def upfind_variable_storable(origin = self)
        return self if variable_storable?
        return @parent.upfind_variable_storable(origin) if has_parent?

        nil
    end
    def upfind_variable(var_name, origin = self)
        return self if @table.has_key? var_name
        return @parent.upfind_variable(var_name, origin) if has_parent?

        nil
    end

    def stack
        myself = "#{@type}#{": #{@run_ptr.place_str}" if @run_ptr}"
        if has_parent?
            return @parent.stack.unshift myself
        end
        return [myself]
    end

    def variable_storable?
        return true if [:root, :while, :if].include? @type
        return false
    end
    def has_parent?
        return true if @parent
        return false
    end
    def finished?
        return @state == :finished
    end
    def running?
        return @state == :running
    end
end
