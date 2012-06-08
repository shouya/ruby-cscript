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
        def store_static(name, value)
            trace_static.dup {|x| p x.stack.type}.store_local(name, value)
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

        def undef_local(name)
            return @symbol_table.delete(name)
        end
        def undef(name)
            tbl = nil
            return tbl.undef_local(name) if tbl = find_table_by_name(name)
            return nil
        end

        def trace_up
            return nil if @stack.nil? # runtime symbol_table
            return @stack.parent.symbol_table if @stack.parent
            return @stack.runtime.static_scope.symbol_table if \
                @stack.type != :static
            return @stack.runtime.symbol_table
            warn 'How could...'
        end

        def trace_global
            return @stack.runtime.symbol_table if @stack
            return self # this is just the global scope
        end
        def trace_static
            return self if @stack.type == :static
            return @stack.runtime.static_scope.symbol_table
        end

        def find_table_by_name(name)
            return self if @symbol_table.has_key? name
            upper = trace_up

            return upper.find_table_by_name(name) if upper
            return nil if upper.nil?
        end

        public :find, :find_local, :store, :store_local, :store_global,
            :undef, :undef_local
        protected :trace_up, :trace_global, :find_table_by_name
    end
end

