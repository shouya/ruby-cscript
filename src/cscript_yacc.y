# syntax parser of cscript project
# generate use `racc cscript_yacc.y`
# 
# Shou Ya
# vim: filetype=ruby
#

# require 'cscript_lex'
# include 'CScriptLexer'

class CScript::Parser

prechigh
    right       UMINUS UPLUS '!'

    left        '*' '/'
    left        '+' '-'

    left        EQUALITY
    left        RELATION

    left        LOGAND
    left        LOGOR

    right       '='

    noassoc     EMIT

    noassoc     ELSE
    noassoc     LOWER_THAN_ELSE
preclow

start main_rule

rule
    main_rule:           { return mkSList(:STATEMENTS) }
        | main_rule stmt { return val[0] << val[1] }
        | main_rule func_def { return val[0] << val[1] }
    ;

    literal: STRING { return mkVal(val[0]) }
        | INTEGER   { return mkVal(val[0]) }
        | BOOL      { return mkVal(val[0]) }
    ;

    name: NAME          { return mkVal(val[0], :NAME) }
    ;
    
    name_list: name     { return mkVList(:NAME_LST) << val[0] }
        | name_list ',' name    { val[0] << val[2] }
    ;
        
    expr: literal       { return val[0] }
        | name          { return val[0] }
        | EMIT expr     { return mkMac(:DEBUG_EMIT, val[1]) }
        | '(' expr ')'  { return val[1] }
        | assignment    { return val[0] }
        | unary_op      { return val[0] }
        | binary_op     { return val[0] }
        | func_call     { return val[0] }
        | comp_expr     { return val[0] }
        | logic_expr    { return val[0] }
    ;

    binary_op: expr '+' expr    { return mkExpr(:PLUS, val[0], val[2]) }
        | expr '-' expr         { return mkExpr(:MINUS, val[0], val[2]) }
        | expr '*' expr         { return mkExpr(:MULTIPLY, val[0], val[2]) }
        | expr '/' expr         { return mkExpr(:DIVIDE, val[0], val[2]) }
    ;


    unary_op: '-' expr =UMINUS  { return mkExpr(:UMINUS, val[1]) }
        | '+' expr =UPLUS       { return mkExpr(:UPLUS, val[1]) }
    ;

    assignment: name '=' expr {
            return mkExpr(:ASSIGN, val[0], val[2])
        }
    ;

    expr_list: expr           { return mkEList(:ARG_LIST) << val[0] }
        | expr_list ',' expr  { return val[0] << val[2] }
    ;

    func_call: name '(' expr_list ')' {
            return mkExpr(:FUNC_CALL, val[0], val[2]);
        }
        | name '(' ')' {
            return mkExpr(:FUNC_CALL, val[0], mkCtrl(:ARG_LIST))
        }
    ;

    func_def: DEF name '(' ')' '{' stmt_lst '}' {
            return mkStmt(:FUNC_DEF, val[1],
                        mkVList(:NAME_LST), val[5])
        }
        | DEF name '(' name_list ')' '{' stmt_lst '}' {
            return mkStmt(:FUNC_DEF, val[1], val[3], val[6])
        }
    ;

    stmt_lst: stmt      { return mkSList(:STATEMENTS) << val[0] }
        | stmt_lst stmt { return val[0] << val[1] }
    ;


    stmt: expr ';'      { return mkStmt(:EXPR_STMT, val[0]) }
        | x_if          { return val[0] }
        | x_while       { return val[0] }
        | x_return ';'  { return val[0] }
        | loop_ctrl ';' { return val[0] }
        | ';'           { return mkStmt(:EMPTY_STMT) }
    ; 

    stmt_or_blk: stmt           { return val[0] }
        | '{' stmt_lst '}'      { return val[1] }

    x_if: if_part     =LOWER_THAN_ELSE  { return mkStmt(:IF1, val[0]) }
        | if_part else_part   { return mkStmt(:IF2, val[0], val[1]) }
    ;

    if_part: IF '(' expr ')' stmt_or_blk {
            return mkStmt(:IF_PART, val[2], val[4])
        }
    ;

    else_part: ELSE stmt_or_blk {
            return mkStmt(:ELSE_PART, val[1])
        }
    ;

    x_while: WHILE '(' expr ')' stmt_or_blk {
            return mkStmt(:WHILE, val[2], val[4]);
        }
    ;

    x_return: RETURN    { return mkStmt(:RETURN) }
        | RETURN expr   { return mkStmt(:RETURN, val[1]) }
    ;

    loop_ctrl: REDO     { return mkStmt(:REDO) }
        | NEXT          { return mkStmt(:NEXT) }
        | BREAK         { return mkStmt(:BREAK) }
    ;

    comp_expr:
          expr RELATION expr { return mkExpr(:COMPARISON, *val[0..-1]) }
        | expr EQUALITY expr { return mkExpr(:COMPARISON, *val[0..-1]) }
    ;


    logic_expr: '!' expr        { return mkExpr(:NOT, val[1]) }
        | expr LOGAND expr      { return mkExpr(:AND, val[0], val[2]) }
        | expr LOGOR expr       { return mkExpr(:OR,  val[0], val[2]) }
    ;

end

