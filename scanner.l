/*
  GAMMA
*/
%{
#include "parser.h" //arquivo automaticamente gerado pelo bison
%}

%option yylineno

SPACE [\ \t\r]
LETTERS [a-zA-Z]
UNDERSCORE [\_]
SPECIAL_CHARACTER [,;:()\[\]\*{}+-/<>=!&%#^]
DIGIT [0-9]
SIGNAL (\+|\-)*
INTEGER {SIGNAL}{DIGIT}+

%%
  /* Palavras Reservadas */
int return TK_PR_INT;
float return TK_PR_FLOAT;
bool return TK_PR_BOOL;
char return TK_PR_CHAR;
string return TK_PR_STRING;
if return TK_PR_IF;
then return TK_PR_THEN;
else return TK_PR_ELSE;
while return TK_PR_WHILE;
do return TK_PR_DO;
input return TK_PR_INPUT;
output return TK_PR_OUTPUT;
return return TK_PR_RETURN;
const return TK_PR_CONST;
static return TK_PR_STATIC;
foreach return TK_PR_FOREACH;
for return TK_PR_FOR;
switch return TK_PR_SWITCH;
case return TK_PR_CASE;
break return TK_PR_BREAK;
continue return TK_PR_CONTINUE;
class return TK_PR_CLASS;
private return TK_PR_PRIVATE;
public return TK_PR_PUBLIC;
protected return TK_PR_PROTECTED;

  /* Operadores Compostos */
"<=" return TK_OC_LE;
">=" return TK_OC_GE;
"==" return TK_OC_EQ;
"!=" return TK_OC_NE;
"&&" return TK_OC_AND;
"||" return TK_OC_OR;
"<<" return TK_OC_SL;
">>" return TK_OC_SR;
"%>%" return TK_OC_U1;
"%|%" return TK_OC_U2;

  /* Caracteres Especiais */
{SPECIAL_CHARACTER}* return yytext[0];

  /* Literais */
{INTEGER} return TK_LIT_INT;
{INTEGER}.{DIGIT}+ return TK_LIT_FLOAT;
{INTEGER}(E|e){INTEGER} return TK_LIT_FLOAT;
(true|TRUE) return TK_LIT_TRUE;
(false|FALSE) return TK_LIT_FALSE;
\'(.?)\' return TK_LIT_CHAR;
\"(.*)\" return TK_LIT_STRING;

  /* Whitespace */
\n {};
{SPACE}* {};

  /* Comentários */
"//".*  {};
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/] {};

  /* Identificadores */
({LETTERS}|{UNDERSCORE})+({LETTERS}|{UNDERSCORE}|{DIGIT})* return TK_IDENTIFICADOR;
%%
