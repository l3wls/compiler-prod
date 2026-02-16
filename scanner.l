/* definitions */

%option yytext_ptr
%x COMMENT
%x STR

%{
#include <stdio.h>
#include <stdlib.h>
#include "tokendef.h"

 /* integers to track line and column numbers */
int scancol = 1;
int yycol = 1;
int scanlineno = 1;

 /* char pointer to pass error messages to driver.c */
char *yyerror;

 /* functions to update line and column numbers */
void updateCol();
void countLines();

 /* function to process a string literal */
int processString();

static int comment_start_line, comment_start_col;
static int string_start_line, string_start_col;

static char strbuf[4096];
static int  stridx;

static char numbuf[32];


%}

newline         \n
whitespace      [ \t]+
integer         [1-9][0-9]*|0
integerlead0    0[0-9]+
character       \'[^\'\n]\'

identifier      [a-zA-Z][a-zA-Z0-9]*
illidentifier   [0-9]+[a-zA-Z][a-zA-Z0-9]*

%%

 /* rules */

 "/*" {
    comment_start_line = scanlineno;
    comment_start_col  = scancol;
    scancol += yyleng;      /* consume "/*" */
    BEGIN(COMMENT);
}

<COMMENT>"*/" {
    scancol += yyleng;      /* consume "*/" */
    BEGIN(INITIAL);
}

<COMMENT>\n {
    scanlineno++;
    scancol = 1;
}

<COMMENT>. {
    scancol += yyleng;
}

<COMMENT><<EOF>> {
    yyerror  = "Unterminated comment";
    yylineno = comment_start_line;
    yycol    = comment_start_col;
    BEGIN(INITIAL);
    return ERROR;
}


 /* Keywords */
"if"      { updateCol(); return KWD_IF; }
"else"    { updateCol(); return KWD_ELSE; }
"while"   { updateCol(); return KWD_WHILE; }
"int"     { updateCol(); return KWD_INT; }
"string"  { updateCol(); return KWD_STRING; }
"char"    { updateCol(); return KWD_CHAR; }
"return"  { updateCol(); return KWD_RETURN; }
"void"    { updateCol(); return KWD_VOID; }

 /* Operators - Multi-character first */
"++"      { updateCol(); return OPER_INC; }
"--"      { updateCol(); return OPER_DEC; }
"&&"      { updateCol(); return OPER_AND; }
"||"      { updateCol(); return OPER_OR; }
"<="      { updateCol(); return OPER_LTE; }
">="      { updateCol(); return OPER_GTE; }
"=="      { updateCol(); return OPER_EQ; }
"!="      { updateCol(); return OPER_NEQ; }

 /* Operators - Single character */
"+"       { updateCol(); return OPER_ADD; }
"-"       { updateCol(); return OPER_SUB; }
"*"       { updateCol(); return OPER_MUL; }
"/"       { updateCol(); return OPER_DIV; }
"%"       { updateCol(); return OPER_MOD; }
"<"       { updateCol(); return OPER_LT; }
">"       { updateCol(); return OPER_GT; }
"="       { updateCol(); return OPER_ASGN; }
"!"       { updateCol(); return OPER_NOT; }
"@"       { updateCol(); return OPER_AT; }

 /* Brackets and Parentheses */
"["       { updateCol(); return LSQ_BRKT; }
"]"       { updateCol(); return RSQ_BRKT; }
"{"       { updateCol(); return LCRLY_BRKT; }
"}"       { updateCol(); return RCRLY_BRKT; }
"("       { updateCol(); return LPAREN; }
")"       { updateCol(); return RPAREN; }

 /* Punctuation */
","       { updateCol(); return COMMA; }
";"       { updateCol(); return SEMICLN; }

 /* Identifiers */
{identifier}    { updateCol(); return ID; }
{illidentifier} { updateCol(); yyerror = "Illegal token"; return ERROR; }

 /* Constants */
{integer}       { updateCol(); return INTCONST; }
{integerlead0}  { updateCol(); yyerror = "Illegal token"; return ERROR; }
{character}     { updateCol(); return CHARCONST; }

 /* Other */
{newline}       { scancol = 1; scanlineno++; }
{whitespace}    { updateCol(); }
.               { updateCol(); yyerror = "Illegal token"; return ERROR; }

%%

/* user routines */

void updateCol(){
    yycol = scancol;
    yylineno = scanlineno;
    scancol += yyleng;
}

void countLines(){
    int i;
    for(i = 0; i < yyleng; i++){
        if(yytext[i] == '\n'){
            scanlineno++;
        }
    }
}

/* Michael will implement this function */
int processString(){
    return STRCONST;
}

int yywrap(){
    return 1;
}