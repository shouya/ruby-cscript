# Syntax Tree for cscript project
# required by yacc_parser
# 
# Shou Ya
#

# Monkey patch
class Symbol
    alias :old_eee :===
    def ===(another)
        if another.is_a? CScriptSyntaxTree::CSTreeNode
            return another === self
        else
            return self.send :old_eee, another
        end
    end
end

module CScriptSyntaxTree

    class CSTreeNode
        attr_accessor :type, :next, :place
        def print
        end
        def append(obj)
            a = self
            a = a.next while !a.next.nil?
            a.next = obj
             
            self
        end
        def ===(name)
    #        p "#{self}, #{@type} === #{name}, #{@type == name}"
            return name == @type 
        end
        def place_str
            if @place
                return @place.join ':'
            end
            return ''
        end

        def type_is? (*arg)
            return true if arg.include? @type
            return false
        end

    end

    class CSValue < CSTreeNode
        attr_accessor :val

        def initialize(val, type = nil)
            @val = val
            @type = CSValue.get_type(val, type)
        end
        def self.get_type(val, given_type)
            case val
            when Fixnum
                return :INTEGER
            when String
                return given_type || :STRING
            else
                return :UNKNOWN
            end
        end
        def print(lvl = 0)
            ret = '. ' * lvl
            if self.val.class == String
                if self.type == :NAME
                    ret << "Name: #{self.val}"
                else
                    ret << "String: #{self.val}"
                end
            else
                ret << "#{self.val.class}: #{self.val}"
            end
            ret << "  (#{place_str})\n"
            ret << @next.print(lvl) if @next
            ret
        end
    end

    class CSCtrl < CSTreeNode
        attr_accessor :operands
        alias :op :operands
        alias :op= :operands=

        def initialize(type, *op)
            @type = type
            @operands = op
        end
        def print(lvl = 0)
            ret = '. ' * lvl
            ret << "#{self.type}  (#{place_str})\n"
            self.op.each do |op|
                ret << op.print(lvl + 1)
            end
            ret << @next.print(lvl) if @next
            ret
        end
        def << (new_op)
            @operands << new_op
            self
        end
        def length
            @operands.length
        end
    end


    def mkCtrl(type, *op)
        return CSCtrl.new(type, *op)
    end
    def mkVal(val, *type)
        return CSValue.new(val, *type)
    end
end
