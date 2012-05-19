%option noyywrap nodefault yylineno

%{
#include <stdlib.h>
#include <string.h>
#include "cscript_yacc.tab.h"

extern void yyerror(const char *s, ...);
extern int fileno(FILE *stream);
extern char *strdup(const char *s);

int oldstate;
%}

%x COMMENT

%%

[1-9]+ |
0[0-7]* |
0[xX][0-9a-fA-F]*	{ yylval.intval = atoi(yytext); return INTNUM; }

[0-9]*\.[0-9]+ |
[0-9]+\.[0-9]*		{ yylval.fltval = atof(yytext); return FLTNUM; }

\'([^\']|\\[nt\'])*\' |
\"([^\"]|\\[nt\"])*\"	{
	yytext[yyleng - 1] = '\0';
	yylval.strval = (char*)strdup((char*)yytext + 1);
	return STRING;
}

"+="			{ yylval.intval = '+'; return ASSIGNMENT; }
"-="			{ yylval.intval = '-'; return ASSIGNMENT; }
"*="			{ yylval.intval = '*'; return ASSIGNMENT; }
"/="			{ yylval.intval = '/'; return ASSIGNMENT; }
"<<="			{ yylval.intval = '<'; return ASSIGNMENT; }
">>="			{ yylval.intval = '>'; return ASSIGNMENT; }
"%="			{ yylval.intval = '%'; return ASSIGNMENT; }
"&="			{ yylval.intval = '&'; return ASSIGNMENT; }
"^="			{ yylval.intval = '^'; return ASSIGNMENT; }
"|="			{ yylval.intval = '|'; return ASSIGNMENT; }

"->"			{ return ARROW; }
"."			{ return POINT; }

"<"			{ yylval.intval = '<'; return RELATION; }
">"			{ yylval.intval = '>'; return RELATION; }
"<="			{ yylval.intval = 'L'; return RELATION; }
">="			{ yylval.intval = 'G'; return RELATION; }
"=="			{ yylval.intval = '='; return EQUALITY; }
"!="			{ yylval.intval = '!'; return EQUALITY; }


"if"			{ return IF; }
"else"			{ return ELSE; }
"while"			{ return WHILE; }
"for"			{ return FOR; }
"do"			{ return DO; }
"return"		{ return RETURN; }
"typeof"		{ return TYPEOF; }
"switch"		{ return SWITCH; }
"case"			{ return CASE; }
"default"		{ return DEFAULT; }
"break"			{ return BREAK; }
"continue"		{ return CONTINUE; }
"in"			{ return IN; }
"struct"		{ return STRUCT; }
"enum"			{ return ENUM; }
"lambda"		{ return LAMBDA; }
"import"		{ return IMPORT; }
"NULL"			{ return XNULL; }
"str"			{ return STR; }
"int"			{ return INT; }
"float"			{ return FLOAT; }
"auto"			{ return AUTO; }
"extern"		{ return EXTERN; }


"/*"			{ oldstate = YY_START; BEGIN COMMENT; }
<COMMENT>"*/"		{ BEGIN oldstate; }
<COMMENT>.|\n		;
<COMMENT><<EOF>>	;
"//".*			;
"#".*			;

"++"			{ return INCREASE; }
"--"			{ return DECREASE; }
"&&"			{ return LOGIAND; }
"||"			{ return LOGIOR; }
"<<"			{ yylval.intval = 'l'; return SHIFT; }
">>"			{ yylval.intval = 'r'; return SHIFT; }

"+" |
"-" |
"*" |
"/" |
"%" |
";" |
"," |
"{" |
"}" |
"!" |
"[" |
"]" |
"(" |
")" |
"?" |
":" |
"&" |
"|" |
"^" |
"~" |
"="			{ return *yytext; }

[a-zA-Z_][0-9a-zA-Z_]*	{ yylval.strval = (char*)strdup(yytext); return NAME; }

[ \t\n]			{ /* ignore whitespaces */ }


.			{ printf("What is it(%c)?\n", *yytext); }

