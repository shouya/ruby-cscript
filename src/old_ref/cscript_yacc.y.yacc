%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#include "cscript_types.h"
#include "cscript_for_yacc.h"

int dbg_emit(const char *s, ...);
void yyerror(const char *s, ...);

extern int yylex(void);

extern int yylineno;


#ifdef _GNUC_
# define inline __inline__
#else
# define inline
#endif

%}


%glr-parser
%expect 2


%union {
	int intval;
	double fltval;
	char *strval;
/*	struct cs_bt *btree;*/
};

/* type declaration */
%token <intval> INTNUM
%token <fltval> FLTNUM
%token <strval> STRING
%token <strval> NAME
%token <intval> EQUALITY RELATION
%token <intval> ASSIGNMENT
%token <intval> SHIFT

/* key word */
%token IF ELSE WHILE FOR DO SWITCH CASE
%token DEFAULT BREAK CONTINUE REDO
%token RETURN TYPEOF IN STRUCT ENUM LAMBDA IMPORT XNULL
%token AUTO EXTERN

/* operator */
%token INCREASE DECREASE LOGIAND LOGIOR ARROW POINT
/*     ++       --       &&      ||    */

/* conflinct operator */
/*%token ADDRESS INDIRECT MULIPLY BITAND PLUS MINUS*/

/* internal types */
%token STR INT FLOAT



%nonassoc LOWEST

/* operator precedence (low->high) */
%left ','
%right ASSIGNMENT '='
%right '?' COND_OP /* conditional operator */
%left LOGIOR
%left LOGIAND
%left '|'
%left '^'
%left '&'
%left EQUALITY
%left RELATION IN /* added */
%left SHIFT
%left '+' '-'
%left '*' '/' '%'
%right INCREASE DECREASE '!' '~' UMINUS UPLUS TYPE_CAST ADDR_OP INDI_OP
/* ^^  ++      --         !   ~  -      +     (int)     *       & */
%left INC_POST DEC_POST
%left '(' '[' POINT ARROW

/* pseudo precedences */
%nonassoc SOLE_IF
%nonassoc ELSE

%nonassoc HIGHEST

%code top {
#define EMIT0(type) _emit0(type);
#define EMIT1(type,a) _emit1(type,a);
#define EMIT2(type,a,b) _emit2(type,a,b);
#define EMIT3(type,a,b,c) _emit3(type,a,b,c);
}

%%

main_rule:	{ EMIT0(_EMPTY_STMT); }	
	|	main_rule statement { EMIT0(_GLUE); }
	|	main_rule function_defination
	;

/* literal */
literal:	string
	|	integer
	|	floatnumber
	|	XNULL
	;

string:		STRING	{ dbg_emit("STRING [%s]", $1); }
	;

integer:	INTNUM	{ EMIT1(_INTEGER, (void*)$1); }
	;

floatnumber:	FLTNUM	{ dbg_emit("FLOAT %f", $1); }
	;

/* name */
expr:		NAME		{ EMIT1(_NAME, $1); }
	|	expr ARROW NAME { dbg_emit("MEMBER ACCESS(->)"); }
	|	expr POINT NAME { dbg_emit("MEMBER ACCESS(.)"); }
	|	expr '[' expr ']'
	;


/* assignment */
assignment:	expr '=' expr %prec ASSIGNMENT {
			EMIT0(_ASGN);
		}
	|	expr ASSIGNMENT expr {
			dbg_emit("ASGN(%c)", $2);
		}
	;


/* declaration */
declaration:	function_declaration
	|	variable_declaration
	;

/* function declaration */
function_declaration:
		EXTERN NAME '(' parameter_list ')' {
			dbg_emit("DECL FUNCTION(%s)", $2);
		}
	;
parameter_list:	name_list
	;

name_list:
	|	NAME
	|	name_list ',' NAME	{ EMIT0(_GLUE); }
	;

/* variable declaration */
variable_declaration:
		AUTO decl_list { dbg_emit("DECLARE VARIABLES"); }
	;

decl_list:	decl_list_item
	|	decl_list ',' decl_list_item	{ /*EMIT0(_GLUE);*/ }
	;

decl_list_item:	NAME		{ dbg_emit("A VARIABLE(%s)", $1); }
	|	NAME '=' expr	{
			dbg_emit("A VARIABLE WITH INITIALIZATION(%s)", $1);
		}
	;


/* binary operation */
binary_operation:
		expr '+' expr {
			EMIT0(_PLUS);
		}
	|	expr '-' expr {
			EMIT0(_MINUS);
		}
	|	expr '*' expr {
			EMIT0(_MULTIPLY);
		}
	|	expr '/' expr {
			dbg_emit("DIVIDE");
		}
	|	expr '%' expr {
			dbg_emit("MOD");
		}
	|	expr SHIFT expr {
			dbg_emit("SHIFT(%c)", $2);
		}
	|	expr EQUALITY expr {
			dbg_emit("EQUALITY(%c)", $2);
		}
	|	expr RELATION expr {
			dbg_emit("RELATION(%c)", $2);
		}
	|	expr '&' expr {
			dbg_emit("BIT AND");
		}
	|	expr '|' expr {
			dbg_emit("BIT OR");
		}
	|	expr '^' expr {
			dbg_emit("BIT XOR");
		}
	|	expr LOGIAND expr {
			dbg_emit("LOGI AND");
		}
	|	expr LOGIOR expr {
			dbg_emit("LOGI OR");
		}
	|	expr IN expr %dprec 1 {
			dbg_emit("IN");
		}
	;

/* unary operation */
unary_operation:
		INCREASE expr {
			dbg_emit("PREFIX INCREASE");
		}
	|	DECREASE expr {
			dbg_emit("PREFIX DECREASE");
		}
	|	expr INCREASE %prec INC_POST {
			dbg_emit("POSTFIX INCREASE");
		}
	|	expr DECREASE %prec DEC_POST {
			dbg_emit("POSTFIX DECREASE");
		}
	|	'!' expr {
			dbg_emit("LOGI NEGATION");
		}
	|	'~' expr {
			dbg_emit("BIT COMPLEMENT");
		}
	|	'-' expr %prec UMINUS {
			dbg_emit("UNARY MINUS");
		}
	|	'+' expr %prec UPLUS {
			dbg_emit("UNARY PLUS");
		}
	|	'(' type ')' expr %prec TYPE_CAST {
			dbg_emit("TYPE CAST");
		}
	|	'&' expr %prec ADDR_OP {
			dbg_emit("GET ADDRESS");
		}
	|	'*' expr %prec INDI_OP {
			dbg_emit("INDIRECT OPERATION");
		}
	;

/* type decalaration */
type:		INT	{ dbg_emit("TYPE INT"); }
	|	STR	{ dbg_emit("TYPE STR"); }
	|	FLOAT	{ dbg_emit("TYPE FLOAT"); }
	|	type '*' %prec HIGHEST { dbg_emit("AS A POINTER"); }
	|	STRUCT NAME	{ dbg_emit("AS A STRUCT"); }
/*	|	NAME		{ dbg_emit("AS A TYPE"); }*/
	;

/* trenary operation */
trenary_operation:
		expr '?' expr ':' expr %prec COND_OP {
			dbg_emit("CONDITIONING OPERATOR");
		}
	;


/* branch statements */
branch_statement:
		if_statement
	|	while_statement
	|	for_statement
	|	for_in_statement
	|	do_while_statement
	|	switch_statement
	;
/* if */
if_statement:	if_part %prec SOLE_IF {
			EMIT0(_SOLE_IF);
		}
	|	if_part else_part {
			EMIT0(_IF_ELSE);
		}
	;

if_part:	IF '(' expr ')' statement {
			EMIT0(_IF_PART);
		}
	;

else_part:	ELSE statement {
			EMIT0(_ELSE_PART);
		}
	;

/* block */
block:		'{' raw_block '}'

raw_block:	statements
	|	raw_statement
	|	statements raw_statement {
			EMIT0(_GLUE);
		}
	|	{
			dbg_emit("AS A EMPTY BLOCK");
		}
	;

statements:	statement
	|	statements statement	{
			EMIT0(_GLUE);
		}
	;

/* while */
while_statement:
		WHILE '(' expr ')' statement { dbg_emit("AS A WHILE"); }
	;

/* for and for-in statement */
for_statement:	FOR '(' raw_statement_or_empty ';'
		raw_statement_or_empty ';'
		raw_statement_or_empty ')'
		statement { dbg_emit("AS A FOR"); }
	;

raw_statement_or_empty:
		raw_statement
	|	{ dbg_emit("EMPTY STATEMENT"); }
	;

for_in_statement:
		FOR '(' NAME IN expr ')' statement %dprec 2 {
			dbg_emit("AS A FOR IN VAR(%s)", $3);
		}
	;
/* do-while */
do_while_statement:
		DO statement WHILE '(' expr ')' {
			dbg_emit("DO_WHILE WITH STATEMENT");
		}
	;

/* loop contorl */
loop_control_statement:
		continue_statement
	|	break_statement
	|	redo_statement
	;
continue_statement:
		CONTINUE
	|	CONTINUE INTNUM
	;
break_statement:
		BREAK
	|	BREAK INTNUM
	;
redo_statement:	REDO
	|	REDO INTNUM
	;


/* switch statement */
switch_statement:
		SWITCH '(' expr ')' '{' switch_content '}'
	|	SWITCH '(' expr ')' '{' '}'
	;

switch_content:	switch_item
	|	switch_content switch_item
	;

switch_item:	CASE expr ':' statements
	|	DEFAULT ':' statements
	;

/* function calling */
function_call:	expr '(' expr_list ')' { dbg_emit("F CALL"); }
	;

expr_list:	{ dbg_emit("EMPTY EXPR"); }
	|	expr
	|	expr_list ',' expr { EMIT0(_GLUE); }
	;


/* function defination */
function_defination:
		NAME '(' parameter_list ')' '{' raw_block '}' {
			dbg_emit("DEFINING FUNCTION(%s)", $1);
		}
	;

/* expression */
expr:		literal
	|	assignment
	|	binary_operation
	|	unary_operation
	|	trenary_operation
	|	'(' expr ')'
	|	function_call
	;

/* statement */
statement:	expr ';' { EMIT0(_STMT_EXPR); }
	|	declaration ';' { dbg_emit("as decl stmt"); }
	|	branch_statement ';' { EMIT0(_STMT_BRCH); }
	|	loop_control_statement ';' { dbg_emit("as loop stmt"); }
	|	';' { dbg_emit("EMPTY STATEMENT"); }
	|	block { dbg_emit("as blck stmt"); }
	;

raw_statement:	expr
	|	declaration
	;


%%

#ifdef DBG_EMIT0
# undef DBG_EMIT0
# undef DBG_EMIT1
# undef DBG_EMIT2
# undef DBG_EMIT3
#endif


int dbg_emit(const char *s, ...)
{
    va_list ap;
    va_start(ap, s);

    printf("rpn: ");
    vfprintf(stdout, s, ap);
    printf("\n");

    va_end(ap);

    return 0;
}

void yyerror(const char *s, ...)
{
    va_list ap;
    va_start(ap, s);

    fprintf(stderr, "Error[%d]: ", yylineno);
    vfprintf(stderr, s, ap);
    fprintf(stderr, "\n");

    va_end(ap);
}

/*
int main()
{
	_parser_init();
    if (!yyparse())
	printf("cscript parse worked.\n");
    else
	printf("cscript parse failed.\n");

    return 0;
}
*/

