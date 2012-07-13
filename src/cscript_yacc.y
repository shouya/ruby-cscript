# syntax parser of cscript project
# generate use `racc cscript_yacc.y`
#
# Shou Ya
# vim: filetype=racc
#

class CScript::Yacc

prechigh
    nonassoc    HIGHEST

    nonassoc    '(' ')'
    right       UMINUS UPLUS '!'

    left        '*' '/' '%'
    left        '+' '-'

    left        EQUALITY
    left        RELATION

    left        LOGAND
    left        LOGOR

    right       '='

    nonassoc    EMIT

    nonassoc    ELSE
    nonassoc    LOWER_THAN_ELSE

    nonassoc    LOWEST
preclow

options no_result_var

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

    name_list
        : name     { return mkVList(:NAME_LST) << val[0] }
        | name_list ',' name    { val[0] << val[2] }
    ;

    expr: literal       { return val[0] }
        | name          { return val[0] }
        | bracket_expr  { return val[0] }
        | assignment    { return val[0] }
        | unary_op      { return val[0] }
        | binary_op     { return val[0] }
        | func_call     { return val[0] }
        | comp_expr     { return val[0] }
        | logic_expr    { return val[0] }
        | lambda_expr   { return val[0] }
    ;

    bracket_expr
        : '(' expr ')' { return val[1] }
        ;

    binary_op: expr '+' expr    { return mkExpr(:PLUS, val[0], val[2]) }
        | expr '-' expr         { return mkExpr(:MINUS, val[0], val[2]) }
        | expr '*' expr         { return mkExpr(:MULTIPLY, val[0], val[2]) }
        | expr '/' expr         { return mkExpr(:DIVIDE, val[0], val[2]) }
        | expr '%' expr         { return mkExpr(:MOD, val[0], val[2]) }
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

    func_call: expr '(' opt_arg_list ')' =FUNC_CALL {
            return mkExpr(:FUNC_CALL, val[0], val[2])
        }
    ;

    opt_arg_list
        : /* EMPTY */   { return mkEList(:ARG_LIST) }
        | expr_list
    ;

    param_lst
        : '(' ')'               { mkVList(:NAME_LST) }
        | '(' name_list ')'     { val[1] }
        ;

    func_def
        : DEF name param_lst '{' stmt_lst '}' {
            mkStmt(:FUNC_DEF, val[1], val[2], val[4])
        }
        ;


    stmt_lst
        : stmt_lst_strict
        | stmt_lst_strict inline_stmt { val[0] << val[1] }
        | inline_stmt { mkSList(:STATEMENTS) << val[0] }
        ;


    stmt_lst_strict
        : stmt { mkSList(:STATEMENTS) << val[0] }
        | stmt_lst_strict stmt { val[0] << val[1] }
        ;


    emit_macro
        : EMIT expr       { return mkMac(:DEBUG_EMIT, val[1]) }
        ;

    stmt: x_if          { return val[0] }
        | x_while       { return val[0] }
        | import_macro  { return val[0] }
        | inline_stmt ';' { return val[0] }
	;

    inline_stmt
        : expr { mkStmt(:EXPR_STMT, val[0]) }
        | x_return
        | loop_ctrl
        | emit_macro
        | global_var_decl
        | static_var_decl
    ;

    stmt_or_blk
        : stmt
        | block
        ;

    block
        : '{' stmt_lst '}' { val[1] }
        ;

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

    loop_ctrl
        : REDO          { return mkStmt(:REDO) }
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

    import_macro: IMPORT_LOC    { return mkMac(:IMPORT_LOCAL, val[0]) }
        | IMPORT_SYS            { return mkMac(:IMPORT_SYSTEM, val[0]) }
    ;

    var_decl_lst: var_decl_item { return mkEList(:DECL_LIST) << val[0] }
        | var_decl_lst ',' var_decl_item { return val[0] << val[2] }
    ;
    var_decl_item: NAME { return mkMark(:DECL_ITEM, val[0]) }
        | NAME '=' expr { return mkMark(:DECL_ITEM_ASGN, val[0], val[2]) }
    ;
    global_var_decl: GLOBAL var_decl_lst { return mkStmt(:GLOBAL, val[1]) }
    ;

    static_var_decl: STATIC var_decl_lst { return mkStmt(:STATIC, val[1]) }
    ;

    lambda_block
        : block                 { mkMark(:BLOCK, val[0]) }
        | param_lst block      { mkMark(:LBD_BLOCK, val[0], val[1]) }
        ;

    lambda_expr: RARROW lambda_block   { return mkExpr(:LAMBDA, val[1]) }
    ;


end

