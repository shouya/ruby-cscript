# CScript Syntax Tree


require 'json'

module CScript
    module SyntaxTree
        class Node
            attr_accessor :type, :place

            def append(obj)
                ptr = self
                ptr = ptr.next until ptr.next.nil?
                ptr.next = obj
                self
            if $CS_DEBUG
                def print
                    to_json
                end
            end
            end

            def ===(name)
                return type_is? [name]
            end

            def type_is? (*test_type)
                return test_type.include? @type
            end
            def nodetype
                classname = self.class.to_s.gsub /.*::/, ''
                strout = classname[0].downcase
                classname[1..-1].each_char do |c|
                    strout << (c==c.downcase ? c : "_#{c.downcase}")
                end
                return strout.intern
            end
            def as_json
                json = { :nodetype => nodetype, :type => @type }
                if $CS_DEBUG
                    json.merge({ :place => @place })
                end
                json
            end
            def to_json(*)
                return JSON.dump(as_json)
            end
            def tree_hash
                JSON.load(to_json)
            end
        end

        class Tree < Node
            attr_accessor :meta_info
            attr_accessor :root

            def initialize(root, meta_info = nil)
                @root = root
                @meta_info = meta_info || {}
            end
            def as_json
                super.merge({ :meta_info => @meta_info,
                              :root => @root.as_json })
            end
        end

        class Value < Node
            include Comparable

            attr_accessor :value
            alias_method :val, :value
            alias_method :val=, :value=

            def self.scan_type(val)
                case val
                when TrueClass, FalseClass
                    :BOOL
                when String
                    :STRING
                when Fixnum
                    :INTEGER
                end
            end

            def initialize(val, type=nil)
                @value = val
                @type = type || self.class.scan_type(val)
            end

            def <=>(other)
                return nil unless @type == other.type
                return @val <=> other.val
            end

            def as_json
                super.merge({ :value => @value })
            end
        end

        class Control < Node
            include Enumerable
            attr_accessor :operands
            alias_method :op, :operands
            alias_method :op=, :operands=

            def each(&block)
                return @operands.each if block.nil?
                @operand.each(&block)
            end

            def initialize(type, *operands)
                @type = type
                @operands = operands || []
            end

            def as_json
                jsonified_operands = @operands.map do |x|
                    x.respond_to?(:as_json) ? x.as_json : x
                end
                super.merge({ :operands => jsonified_operands })
            end
        end

        class Expression < Control
        end
        class Statement < Control
        end
        class Container < Node
            include Enumerable

            attr_accessor :subnodes

            def initialize(type, *objs)
                @type = type
                @subnodes = objs || []
            end

            def append(new_node)
                @subnodes.push new_node
                return self
            end
            alias_method :<<, :append

            def each(&block)
                return @subnodes.each if block.nil?
                @subnodes.each(&block)
            end
            def as_json
                super.merge({ :subnodes => @subnodes.map(&:as_json) })
            end
        end

        class StatementList < Container
        end

        class ExpressionList < Container
        end
        class ValueList < Container
        end
        class Macro < Control
        end

        def self.Shortcut(&hook)
            tmp_module = Module.new do
                @shortcuts ||= {
                    #                :Ctrl => Control,
                    #                :Node => Node,
                    :Val => Value,
                    :Expr => Expression,
                    :Stmt => Statement,
                    :Mac => Macro,
                    #                   :Cont => Container,
                    :SList => StatementList,
                    :EList => ExpressionList,
                    :VList => ValueList,
                }

                @shortcuts.each do |short, redir|
                    define_method("mk#{short}".intern) do |*args|
                        new_obj = redir.new(*args)
                        unless hook.nil?
                            self.instance_exec(new_obj, &hook)
                        end
                        return new_obj
                    end
                end
            end
            return tmp_module
        end
    end
end

