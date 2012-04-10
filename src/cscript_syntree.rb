# Syntax Tree for cscript project
# required by yacc_parser
# 
# Shou Ya
#

class CSTreeNode
    attr_accessor :type, :next
    def print
    end
    def append(obj)
        b = a = self
        while a.next
            b = a
            a = a.next
        end
        b.next = obj
    end
end

class CSValue < CSTreeNode
    attr_accessor :val

    def initialize(val, type = nil)
        @val = val
        @type = type
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
end


def mkCtrl(type, *op)
    return CSCtrl.new(type, *op)
end
def mkVal(val)
    return CSValue.new(val)
end

