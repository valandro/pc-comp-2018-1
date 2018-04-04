/*
  GAMMA
*/
%{
#include "parser.h" //arquivo automaticamente gerado pelo bison
%}

%option yylineno

SPACE [\ \t\r]
LETTER [a-zA-Z]
UNDERSCORE [\_]
SPECIAL_CHARACTER [.,;:()\[\]\*{}+-/<>=!&%#^]
DIGIT [0-9]
SIGNAL (\+|\-)?
INTEGER {SIGNAL}{DIGIT}+
FLOAT {INTEGER}[\.]{DIGIT}+
EXP_FLOAT ({FLOAT}|{INTEGER})(E|e){INTEGER}

LIT_FALSE (false)
LIT_TRUE (true)
LIT_CHAR 	\'(.?)\'
LIT_STRING 	\"(\\.|[^\\"])*\"

IDENTIFIER ({LETTER}|{UNDERSCORE})+({LETTER}|{UNDERSCORE}|{DIGIT})*

%x comentarioMultiline

%%
  /* Comentários */
"/*"  BEGIN(comentarioMultiline);   /* Alteração de estado para tratar comentário multiline. */
<comentarioMultiline>[^*\n]*        /* remove qualquer coisa que não seja '*' */
<comentarioMultiline>"*"+[^*/\n]*   /* remove todos '*' não seguidos de '/' */
<comentarioMultiline>\n             /* remove line-ending */
<comentarioMultiline>"*"+"/"        BEGIN(INITIAL); /* Encerramento de comentário. Retorna ao estado normal. */

"//".*  {};

  /* Whitespace */
\n {};
{SPACE}* {};

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
{SPECIAL_CHARACTER} return yytext[0];

  /* Literais */
{LIT_TRUE} return TK_LIT_TRUE;
{LIT_FALSE} return TK_LIT_FALSE;
{INTEGER} { insert_symbol_table(TK_LIT_INT); return TK_LIT_INT;}
{FLOAT} { insert_symbol_table(TK_LIT_FLOAT); return TK_LIT_FLOAT; }
{EXP_FLOAT} { insert_symbol_table(TK_LIT_FLOAT); return TK_LIT_FLOAT; }
{LIT_CHAR} { insert_symbol_table(TK_LIT_CHAR); return TK_LIT_CHAR; }
{LIT_STRING} { insert_symbol_table(TK_LIT_STRING); return TK_LIT_STRING; }

  /* Identificadores */
{IDENTIFIER} { insert_symbol_table(TK_IDENTIFICADOR); return TK_IDENTIFICADOR; }

  /* Catch erro de númericos seguidos por identificadores */
({INTEGER}|{FLOAT}|{EXP_FLOAT}){IDENTIFIER}+ return TOKEN_ERRO;

  /* Catch-all para inválidos */
. {
  /* yyerror("Token invalido"); */
  return TOKEN_ERRO;
}
%%
