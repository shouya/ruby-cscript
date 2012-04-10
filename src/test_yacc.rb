
require_relative 'cscript_lex'
require_relative 'cscript_yacc.tab'
require_relative 'cscript_syntree'

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



parser = CScriptParser.new
tree = parser.do_parse

tree.print




