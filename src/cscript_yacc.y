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
    right       UMINUS UPLUS

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
        | main_rule func_def { return val[0].append val[1] }
    ;

    literal: STRING { return mkVal(val[0]) }
        | INTEGER   { return mkVal(val[0]) }
    ;

    name: NAME          { return mkVal(val[0], :NAME) }
    ;
    
    name_list: name     { return mkCtrl(:NAME_LST) << val[0] }
        | name_list ',' name    { val[0] << val[2] }
    ;
        
    expr: literal       { return val[0] }
        | name          { return val[0] }
        | '%' expr      { return mkCtrl(:PRINT, val[1]) }
        | '(' expr ')'  { return val[1] }
        | assignment    { return val[0] }
        | unary_op      { return val[0] }
        | binary_op     { return val[0] }
        | func_call     { return val[0] }
    ;

    binary_op: expr '+' expr    { return mkCtrl(:PLUS, val[0], val[2]) }
        | expr '-' expr         { return mkCtrl(:MINUS, val[0], val[2]) }
        | expr '*' expr         { return mkCtrl(:MULTIPLY, val[0], val[2]) }
        | expr '/' expr         { return mkCtrl(:DIVIDE, val[0], val[2]) }
    ;


    unary_op: '-' expr =UMINUS  { return mkCtrl(:UMINUS, val[1]) }
        | '+' expr =UPLUS       { return mkCtrl(:UPLUS, val[1]) }
    ;

    assignment: name '=' expr {
            return mkCtrl(:ASSIGN, val[0], val[2])
        }
    ;

    expr_list: expr           { return mkCtrl(:ARG_LIST) << val[0] }
        | expr_list ',' expr  { return val[0] << val[2] }
    ;

    func_call: name '(' expr_list ')' {
            return mkCtrl(:FUNC_CALL, val[0], val[2]);
        }
        | name '(' ')' {
            return mkCtrl(:FUNC_CALL, val[0], mkCtrl(:ARG_LIST))
        }
    ;

    func_def: DEF name '(' ')' '{' stmt_lst '}' {
            return mkCtrl(:FUNC_DEF, val[1], mkCtrl(:NAME_LST), val[5])
        }
        | DEF name '(' name_list ')' '{' stmt_lst '}' {
            return mkCtrl(:FUNC_DEF, val[1], val[3], val[6])
        }
    ;

    stmt_lst: stmt      { return val[0] }
        | stmt_lst stmt { return val[0].append val[1] }
    ;

    stmt: expr ';' { return mkCtrl(:EXPR_STMT, val[0]) }
        | x_if     { return val[0] }
        | x_while  { return val[0] }
        | x_return { return val[0] }
    ;

    stmt_or_blk: stmt           { return val[0] }
        | '{' stmt_lst '}'      { return val[1] }

    x_if: if_part     =LOWER_THAN_ELSE  { return val[0] }
        | if_part else_part   { return val[0] << val[1] }
    ;

    if_part: IF '(' expr ')' stmt_or_blk {
            return mkCtrl(:IF_PART, val[2], val[4])
        }
    ;

    else_part: ELSE stmt_or_blk {
            return mkCtrl(:ELSE_PART, val[1])
        }
    ;

    x_while: WHILE '(' expr ')' stmt_or_blk {
            return mkCtrl(:WHILE, val[2], val[4]);
        }
    ;

    x_return: RETURN ';'        { return mkCtrl(:RETURN) }
        | RETURN expr ';'       { return mkCtrl(:RETURN, val[1]) }
    ;

end

