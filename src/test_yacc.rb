
require_relative 'cscript_parser'

=begin
class Lexer
    include CScriptScanner
end
lexer = Lexer.new
lexer.scan_string($stdin.read)

CScriptParser.class_eval do
    define_method :next_token do
        lexer.next_token
    end
end

=end

parser = CScriptParser.new
parser.scan_stdin
tree = parser.do_parse

puts "======== TREE ============"
puts tree.print
puts "======== END ============="




