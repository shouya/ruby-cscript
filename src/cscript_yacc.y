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
    noassoc     ELSE
    noassoc     LOWER_THAN_ELSE
preclow

start main_rule

rule
    main_rule:           { return mkCtrl(:EMPTY_STMT) }
        | main_rule stmt { return val[0].append val[1] }
    ;

    literal: STRING { return mkVal(val[0]) }
        | INTEGER   { return mkVal(val[0]) }
    ;

    name: NAME          { return mkVal(val[0], :NAME) }
    ;
        

    expr: literal       { return val[0] }
        | expr '+' expr { return mkCtrl(:PLUS, val[0], val[2]) }
        | expr '-' expr { return mkCtrl(:MINUS, val[0], val[2]) }
        | expr '*' expr { return mkCtrl(:MULTIPLY, val[0], val[2]) }
        | expr '/' expr { return mkCtrl(:DIVIDE, val[0], val[2]) }
        | NAME          { return mkVal(val[0], :NAME) }
        | '%' expr      { return mkCtrl(:PRINT, val[1]) }
        | '(' expr ')'  { return val[1] }
        | assignment    { return val[0] }
    ;

    assignment: expr '=' expr {
        return mkCtrl(:ASIGN, val[0], val[2])
    }
    ;
        
    stmt_lst: stmt      { return val[0] }
        | stmt_lst stmt { return val[0].append val[1] }
    ;

    stmt: expr ';' { return mkCtrl(:STMT, val[0]) }
        | x_if     { return val[0] }
    ;

    x_if: if_part     =LOWER_THAN_ELSE  { return val[0] }
        | if_part else_part { return val[0] << val[1] }
    ;

    if_part: IF '(' expr ')' '{' stmt_lst '}' {
            return mkCtrl(:IF_PART, val[2], val[5])
        }
        |    IF '(' expr ')' stmt {
            return mkCtrl(:IF_PART, val[2], val[4])
        }
    ;

    else_part: ELSE '{' stmt_lst '}' {
            return mkCtrl(:ELSE_PART, val[2])
        }
        |      ELSE stmt             {
            return mkCtrl(:ELSE_PART, val[1])
        }
    ;

end

