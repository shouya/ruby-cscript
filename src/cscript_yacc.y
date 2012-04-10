# syntax parser of cscript project
# generate use `racc cscript_yacc.y`
# 
# Shou Ya
# vim: filetype=ruby
#

# require 'cscript_lex'
# include 'CScriptLexer'

class CScriptParser

prechigh
    left        '*' '/'
    left        '+' '-'
    right       '='
    noassoc     '%'
preclow

start main_rule

rule
    main_rule:           { return mkCtrl(:EMPTY_STMT) }
        | main_rule stmt { return val[0].append val[1] }
    ;

    literal: STRING { return mkVal(val[0]) }
        | INTEGER   { return mkVal(val[0]) }
    ;
        

    expr: literal       { return val[0] }
        | expr '+' expr { return mkCtrl(:PLUS, val[0], val[2]) }
        | expr '-' expr { return mkCtrl(:MINUS, val[0], val[2]) }
        | expr '*' expr { return mkCtrl(:MULTIPLY, val[0], val[2]) }
        | expr '/' expr { return mkCtrl(:DIVIDE, val[0], val[2]) }
        | NAME          { return mkVal(val[0], :NAME) }
        | '%' expr      { return mkCtrl(:PRINT, val[1]) }
        | assignment    { return val[0] }
    ;

    assignment: expr '=' expr {
        return mkCtrl(:ASIGN, val[0], val[2])
    }
    ;
        

    stmt: expr ';' { return mkCtrl(:STMT, val[0]) }
    ;

end

