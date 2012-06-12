# syntax parser of cscript project
# generate use `racc cscript_yacc.y`
#
# Shou Ya
# vim: filetype=racc
#

class CScript::Yacc

prechigh
    nonassoc     HIGHEST

    nonassoc    '(' ')'
    right       UMINUS UPLUS '!'

    left        '*' '/' '%'
    left        '+' '-'

    left        EQUALITY
    left        RELATION

    left        LOGAND
    left        LOGOR

    right       '='

    nonassoc     EMIT

    nonassoc    "\n"

    nonassoc     ELSE
    nonassoc     LOWER_THAN_ELSE

    nonassoc     LOWEST
preclow

options no_result_var
start main_rule

rule
    main_rule
        : /* EMPTY */           { mkSList(:STATEMENTS) }
        | main_rule stmt        { val[0] << val[1] }
        | main_rule func_def    { val[0] << val[1] }
        | main_rule "\n"        { val[0] }
    ;

    literal
        : STRING    { mkVal(val[0]) }
        | INTEGER   { mkVal(val[0]) }
        | BOOL      { mkVal(val[0]) }
    ;

    name: NAME          { mkVal(val[0], :NAME) }
    ;

    name_list
        : name                          { mkVList(:NAME_LST) << val[0] }
        | name_list ',' optnl name      { val[0] << val[3] }
        ;

    expr: literal
        | name
        | bracket_expr
        | assignment
        | unary_op
        | binary_op
        | func_call
        | comp_expr
        | logic_expr
        | lambda_expr
        ;

    bracket_expr: '(' optnl expr optnl ')' { val[2] }
        ;

    binary_op
        : expr '+' optnl expr   { mkExpr(:PLUS, val[0], val[3]) }
        | expr '-' optnl expr   { mkExpr(:MINUS, val[0], val[3]) }
        | expr '*' optnl expr   { mkExpr(:MULTIPLY, val[0], val[3]) }
        | expr '/' optnl expr   { mkExpr(:DIVIDE, val[0], val[3]) }
        | expr '%' optnl expr   { mkExpr(:MOD, val[0], val[3]) }
        ;


    unary_op
        : '-' optnl expr =UMINUS        { mkExpr(:UMINUS, val[2]) }
        | '+' optnl expr =UPLUS         { mkExpr(:UPLUS, val[2]) }
        ;

    assignment
        : name '=' optnl expr { mkExpr(:ASSIGN, val[0], val[3]) }
        ;

    expr_list
        : expr                          { mkEList(:ARG_LIST) << val[0] }
        | expr_list ',' optnl expr      { val[0] << val[3] }
        ;

    func_call
        : expr '(' optnl opt_arg_list optnl ')' {
            mkExpr(:FUNC_CALL, val[0], val[3]);
        }
        ;

    opt_arg_list
        : /* EMPTY */   { mkEList(:ARG_LIST) }
        | expr_list
        ;

    braced_block
        : '{' optnl stmts inline_stmt '}' { val[2] << val[3] }
        | '{' optnl stmts '}' { val[2] }
        | '{' optnl '}' { mkStmt(:EMPTY_STMT) }
        ;

    stmts
        : stmt                  { mkSList(:STATEMENTS) << val[0] }
        | stmts stmt            { val[0] << val[1] }
        ;

    func_def
        : DEF optnl name optnl opt_bracketed_param_lst
          optnl braced_block { mkStmt(:FUNC_DEF, val[2], val[4], val[6]) }
        ;

    opt_bracketed_param_lst
        : '(' optnl opt_param_lst optnl ')'  { val[2] }
        | /* EMPTY */ { mkVList(:NAME_LST) }
        ;

    opt_param_lst
        : name_list
        | /* EMPTY */ { mkVList(:NAME_LST) }

    emit_macro: EMIT optnl expr       { mkMac(:DEBUG_EMIT, val[2]) }
    ;

    stmt: x_if
        | x_while
        | import_macro
        | inline_stmt terminator { val[0] }
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
        | braced_block
        ;

    x_if: if_part     =LOWER_THAN_ELSE  { mkStmt(:IF1, val[0]) }
        | if_part multinl else_part     { mkStmt(:IF2, val[0], val[2]) }
        | if_part else_part             { mkStmt(:IF2, val[0], val[1]) }
        ;

    if_part
        : IF optnl '(' optnl expr optnl ')' optnl stmt_or_blk {
            mkStmt(:IF_PART, val[4], val[8])
        }
        ;

    else_part
        : ELSE optnl stmt_or_blk {
            mkStmt(:ELSE_PART, val[2])
        }
        ;

    x_while
        : WHILE optnl '(' optnl expr optnl ')' optnl stmt_or_blk {
            mkStmt(:WHILE, val[4], val[8]);
        }
        ;

    x_return
        : RETURN        { mkStmt(:RETURN) }
        | RETURN expr   { mkStmt(:RETURN, val[1]) }
        ;

    loop_ctrl
        : REDO          { mkStmt(:REDO) }
        | NEXT          { mkStmt(:NEXT) }
        | BREAK         { mkStmt(:BREAK) }
        ;

    comp_expr
        : expr RELATION optnl expr {
            mkExpr(:COMPARISON, val[0], val[1], val[3]) }
        | expr EQUALITY optnl expr {
            mkExpr(:COMPARISON, val[0], val[1], val[3]) }
        ;


    logic_expr
        : '!' optnl expr              { mkExpr(:NOT, val[2]) }
        | expr LOGAND optnl expr      { mkExpr(:AND, val[0], val[3]) }
        | expr LOGOR optnl expr       { mkExpr(:OR,  val[0], val[3]) }
        ;

    import_macro
        : IMPORT_LOC            { mkMac(:IMPORT_LOCAL, val[0]) }
        | IMPORT_SYS            { mkMac(:IMPORT_SYSTEM, val[0]) }
        ;

    var_decl_lst
        : var_decl_item                 { mkEList(:DECL_LIST) << val[0] }
        | var_decl_lst ',' optnl var_decl_item  { val[0] << val[3] }
        ;
    var_decl_item
        : NAME                  { mkMark(:DECL_ITEM, val[0]) }
        | NAME '=' optnl expr   { mkMark(:DECL_ITEM_ASGN, val[0], val[3])}
        ;
    global_var_decl
        : GLOBAL optnl var_decl_lst { mkStmt(:GLOBAL, val[2]) }
        ;

    static_var_decl
        : STATIC optnl var_decl_lst { mkStmt(:STATIC, val[2]) }
        ;

    lambda_param
        : opt_bracketed_param_lst
        ;

    lambda_expr
        : RARROW optnl lambda_param optnl braced_block {
            mkExpr(:LAMBDA, val[2], val[4])
        }
        ;

    terminator
        : "\n"
        | ';'
        ;

    optnl
        : optnl_sub =LOWEST
        ;

    optnl_sub
        :
        | optnl_sub "\n"
        ;
    multinl
        : "\n"
        | multinl "\n"
        ;

end

