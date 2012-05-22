# CScript Syntax Tree


require 'pp' if $CS_DEBUG
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
            def as_json
                json = { :nodetype => :node, :type => @type }
                if $CS_DEBUG
                    json.merge({ :place => @place })
                end
                json
            end
            def to_json(*)
                return JSON.pretty_generate(as_json)
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
                super.merge({ :nodetype => :tree,
                              :meta_info => @meta_info,
                              :root => @root })
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
                super.merge({ :nodetype => :value, :value => @value })
            end
        end

        class Control < Node
            include Enumerable
            attr_accessor :operands
            alias_method :op, :operands
            alias_method :op=, :operands=

            def <<(obj)
                @operands << obj
                self
            end

            def each(&block)
                return @operands.each if block.nil?
                @operand.each(&block)
            end

            def initialize(type, *operands)
                @type = type
                @operands = operands || []
            end

            def as_json
                super.merge({ :nodetype => :control,
                              :operands => @operands.map {|x|
                                    x.respond_to?(:as_json)? x.as_json : x}})
            end
        end

        class Expression < Control
            def as_json
                super.merge({ :nodetype => :expression })
            end
        end
        class Statement < Control
            def as_json
                super.merge({ :nodetype => :statement })
            end
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
                super.merge({ :nodetype => :container,
                              :subnodes => @subnodes.map(&:as_json) })
            end
        end

        class Macro < Control
            def as_json
                super.merge({ :nodetype => :macro })
            end
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
                    :Cont => Container
                }

                @shortcuts.each do |short, redir|
                    define_method("mk#{short}".intern) do |*args|
                        new_obj = redir.new(*args)
                        self.instance_exec(new_obj, &hook) unless hook.nil?
                        return new_obj
                    end
                end
            end
            return tmp_module
        end
    end
end

