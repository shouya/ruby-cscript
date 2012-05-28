# Symbol Table class for cscript project
#
# Shou Ya, Afternoon, 26 May, 2012
#
#

module CScript
    class SymbolTable
        attr_reader :stack
        attr_accessor :symbol_table

        def initialize(stack, init_table = nil)
            @stack = stack
            @symbol_table = init_table || {}
        end

        def store_local(name, value)
            @symbol_table[name.to_s] = value
        end

        def store_global(name, value)
            trace_global.store_local(name, value)
        end
        def store(name, value)
            place = find_table_by_name(name) || self
            place.store_local(name, value)
        end

        def find_local(name)
            return nil unless @symbol_table.has_key? name
            return @symbol_table.fetch(name)
        end
        def find(name)
            var = find_local(name)
            return var if var

            up = trace_up
            return up.find(name) if up

            error_raise "Variable #{name} not found!"
        end


        def trace_up
            return nil if @stack.nil?
            return @stack.parent.symbol_table if @stack.parent
            return @stack.runtime.symbol_table
        end

        def trace_global
            return @stack.runtime.symbol_table if @stack
            return self
        end

        def find_table_by_name(name)
            return self if @symbol_table.has_key? name
            upper = trace_up

            return upper.find_table_by_name(name) if upper
            return nil if upper.nil?
        end

        public :find, :find_local, :store, :store_local, :store_global
        protected :trace_up, :trace_global, :find_table_by_name
    end
end

