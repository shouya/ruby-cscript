# parser (yacc mixin) module of cscript
#
# Shou Ya   11 Apr, 2012
#

# run `racc -E -v -ocscript_yacc.rb cscript_yacc.y' to generate this file
# the parser program
require_relative 'cscript_yacc'
# and the lexer program
require_relative 'cscript_lex'
# syntax tree support
require_relative 'cscript_syntree'


# this class is generated in `cscript_yacc.rb'
CScriptParser.class_eval do
    include CScriptScanner
    include CScriptSyntaxTree

    alias :old_mkCtrl :mkCtrl
    alias :old_mkVal :mkVal

    def mkCtrl(*arg)
        obj = old_mkCtrl(*arg)
        obj.place = where?
        obj
    end
    def mkVal(*arg)
        obj = old_mkVal(*arg)
        obj.place = where?
        obj
    end

=begin
    Methods:
        scan_string (str)       set input content
        scan_file (file_name)   set input content

        do_parse ()             start parse, return a tree object
=end

end




