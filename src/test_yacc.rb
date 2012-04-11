
require_relative 'cscript_parser'
require_relative 'cscript_syntree'

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
parser.scan_string($stdin.read)
tree = parser.do_parse

tree.print




