# Syntax Tree for cscript project
# required by yacc_parser
# 
# Shou Ya
#

class Symbol
    alias :old_eee :===
    def ===(another)
        if another.is_a? CSTreeNode
            return another === self
        else
            return self.send :old_eee, another
        end
    end
end
class CSTreeNode
    attr_accessor :type, :next
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
        Kernel.print(". " * lvl)
        if self.val.class == String
            if self.type == :NAME
                puts "Name: #{self.val}"
            else
                puts "String: #{self.val}"
            end
        else
            puts "#{self.val.class}: #{self.val}"
        end
        @next.print(lvl) if @next
    end
end

class CSCtrl < CSTreeNode
    attr_accessor :operators
    alias :op :operators
    alias :op= :operators=

    def initialize(type, *op)
        @type = type
        @operators = op
    end
    def print(lvl = 0)
        Kernel.print(". " * lvl)
        puts "#{self.type}"
        self.op.each do |op|
            op.print(lvl + 1)
        end
        @next.print(lvl) if @next
    end
    def << (new_op)
        @operators << new_op
        self
    end
    def length
        @operators.length
    end
end


def mkCtrl(type, *op)
    return CSCtrl.new(type, *op)
end
def mkVal(val)
    return CSValue.new(val)
end

