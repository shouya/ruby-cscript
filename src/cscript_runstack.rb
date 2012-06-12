# Runstack moudle for cscript project
#
# Shou Ya,  morning in 17th April, 2012
#


require_relative 'cscript'

module CScript
    class RunStack
        # Dynamic fields
        attr_accessor :last_value # Result value of last expression
        attr_accessor :run_ptr # Current running syntax tree node
        attr_accessor :substack # Current sub-stack
        # Static fields
        attr_reader :parent # Parent runstack
        attr_reader :type # Type of the runstack
        attr_reader :runtime # Program runtime
        attr_reader :executor, :evaluator # syntax tree execu/evalua-tor
        attr_reader :symbol_table # Symbol table of the runstack
        attr_reader :callstack # Runstack location in callstack

=begin depreacted
        attr_accessor :type, :parent, :state    # meta info
        # execution info
        attr_accessor :run_ptr, :eval_tree, :current_child, :last_value
        attr_accessor :tree, :table   # content data
        attr_accessor :call_stack
        attr_accessor :runtime
=end

        def initialize(parent = nil, type = nil)
            @parent = parent
            @type = type || :root
            @runtime = parent ? parent.runtime : nil

            @executor = Executor.new(self)
            @evaluator = Evaluator.new(self)
            @symbol_table = SymbolTable.new(self)
            @callstack = parent ? parent.callstack : nil

            @callstack.current_runstack = self if @callstack

            @run_ptr = @substack = @last_value = nil
        end

        def dispatch(*args)
            case args[0]['nodetype']
            when 'expression', 'value'
                return @evaluator.evaluate(*args)
            when 'statement', 'statement_list'
                return @executor.execute(*args)
            when 'macro'
                return @runtime.process(self, *args)
            else
                raise 'wtf?!'
            end
        end

        alias_method :execute, :dispatch
        alias_method :evaluate, :dispatch
        alias_method :process, :dispatch


        def store(*args)
            @symbol_table.store(*args)
        end
        def store_local(*args)
            @symbol_table.store_local(*args)
        end
        def find(*args)
            @symbol_table.find(*args)
        end

        def is_lambda_call?
            ptr = self
            while ptr.type != :lambda
                ptr = ptr.parent and next if ptr.parent
                return false
            end
            return true
        end
        def is_func_call?
            return false if @callstack.nil?
            ptr = self
            while ptr.type != :func_call
                ptr = ptr.parent and next if ptr.parent
                return false
            end
            return true
        end
        def is_inside_loop?
            ptr = self
            until [:while, :until].include?(ptr.type)
                ptr = ptr.parent and next if ptr.parent
                return false
            end
            return true
        end

        def return(value = nil)
            case
            when is_func_call?
                @callstack.return(value)
            when is_lambda_call?
                Lambda.return(value)
            else
                error_raise 'Cannot return without inside calling.'
            end
        end

        def set_variables(hash)
            @symbol_table.set_variables(hash)
        end

        def make_binding
            bind = @symbol_table.variables.dup
            ptr = self
            until ptr.parent.nil?
                ptr.symbol_table.variables.each do |k, v|
                    bind.store(k, v)
                end
                ptr = ptr.parent
            end
            bind
        end

=begin Deprecated
        def query_variable(name)
            found = nil
            assert_error %{Variable "#{name}" not found} do
                found = upfind_variable(name)
            end

            return found.query_local_variable(name)
        end
        def store_variable(name, value)
            found = upfind_variable(name)
            if found then
                if @eval_tree.respond_to? :place then
                    value.last_assigned = @eval_tree.place
                end
                found.store_local_variable(name, value)
            else
                if @eval_tree.respond_to? :place then
                    value.last_assigned = value.first_defined = \
                        @eval_tree.place
                end


                block = nil
                assert_error "ge variable but not block scope found" do
                    block = upfind_variable_storable
                end

                block.store_local_variable(name, value)
            end
        end
        def append_variables(hash)
            hash.each do |k, v|
                store_local_variable(k, v)
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
            return @parent.upfind_variable_storable(origin) \
                if has_parent?

            nil
        end
        def upfind_variable(var_name, origin = self)
            return self if @table.has_key? var_name
            return @parent.upfind_variable(var_name, origin) \
                if has_parent?

            nil
        end

        def stack
            myself = "#{@type}#{": #{@run_ptr.place_str}" if @run_ptr}"
            if @call_stack
                return @call_stack.stack.unshift myself
            elsif has_parent?
                return @parent.stack.unshift myself
            end
            return [myself]
        end
        def root
            p = self
            p = p.parent untile p.type == :root
            return p
        end

        def variable_storable?
            return true \
                if [:root, :while, :if, :func_call].include? @type
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

        if $CS_DEBUG
            def emit(*args)
                @runtime.emissions << \
                    (args.length == 1 ? args.first : args)
            end
        end
=end
    end
end

