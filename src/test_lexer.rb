
require_relative 'cscript_lex'


class MyLexer
    include CScriptScanner
end

lexer = MyLexer.new
lexer.scan_stdin

until (scanned = lexer.next_token) == [false, false]
    puts scanned.inspect
end

