/*
  GAMMA
*/
%code requires{
#include "main.h"
}

/* Declaração dos tokens da linguagem */
/* Palavras Reservadas */
%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_CHAR
%token TK_PR_STRING
%token TK_PR_IF
%token TK_PR_THEN
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_DO
%token TK_PR_INPUT
%token TK_PR_OUTPUT
%token TK_PR_RETURN
%token TK_PR_CONST
%token TK_PR_STATIC
%token TK_PR_FOREACH
%token TK_PR_FOR
%token TK_PR_SWITCH
%token TK_PR_CASE
%token TK_PR_BREAK
%token TK_PR_CONTINUE
%token TK_PR_CLASS
%token TK_PR_PRIVATE
%token TK_PR_PUBLIC
%token TK_PR_PROTECTED

/* Operadores Compostos */
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_OC_SL
%token TK_OC_SR
%token TK_OC_U1
%token TK_OC_U2

/* Literais */
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_LIT_STRING
%token TK_IDENTIFICADOR

%token TOKEN_ERRO

%left TK_OC_OR
%left TK_OC_AND
%left TK_OC_EQ TK_OC_NE
%left '>' TK_OC_GE
%left '<' TK_OC_LE
%left TK_OC_SL TK_OC_SR
%left '+' '-'
%left '*' '/'
%right '['']'
%right '('')'

%error-verbose

%union
{
  symbol* valor_lexico;
}

%start program
%%
/* Regras (e ações) da gramática */
/* Regras de apoio - Começo */
type:
TK_PR_INT |
TK_PR_FLOAT |
TK_PR_CHAR |
TK_PR_BOOL |
TK_PR_STRING
;

encap:
TK_PR_PROTECTED |
TK_PR_PRIVATE |
TK_PR_PUBLIC
;

lit:
TK_LIT_INT |
TK_LIT_FLOAT |
TK_LIT_CHAR |
TK_LIT_TRUE |
TK_LIT_FALSE |
TK_LIT_STRING
;

/* Regras de apoio - Fim */

program: body ;

body:
body dec_var_new_type ';' |
body dec_var_global ';' |
body dec_func |
;

dec_var_new_type:
TK_PR_CLASS TK_IDENTIFICADOR '[' list_fields ']'
;

list_fields:
list_fields ':' field |
field
;

field:
encap type TK_IDENTIFICADOR ;

dec_var_global:
declare vector |
TK_PR_STATIC declare vector |
TK_PR_CLASS declare vector |
TK_PR_STATIC TK_PR_CLASS declare vector

;

declare:
type TK_IDENTIFICADOR |
TK_IDENTIFICADOR TK_IDENTIFICADOR
;

vector:
'[' TK_LIT_INT ']' |
;

dec_func:
TK_PR_STATIC type TK_IDENTIFICADOR '(' list_params ')' func_body |
type TK_IDENTIFICADOR '(' list_params ')' func_body
;

list_params:
list_params ',' param |
param |
;

param:
type TK_IDENTIFICADOR |
TK_PR_CONST type TK_IDENTIFICADOR
;

func_body:
command_block
;

command_block:
'{' simple_commands '}'
;

simple_commands:
simple_commands command_block ';'|
simple_commands declare_var_local ';'|
simple_commands attribution ';'|
simple_commands input ';'';'|
simple_commands output ';'|
simple_commands shift  ';'|
simple_commands func_call ';'|
simple_commands conditional  ';'|
simple_commands iterative ';'|
simple_commands switch |
simple_commands control_flow ';' |
;
declare_var_local:
TK_PR_STATIC TK_PR_CONST type TK_IDENTIFICADOR init|
TK_PR_STATIC type TK_IDENTIFICADOR init|
TK_PR_CONST type TK_IDENTIFICADOR init|
type TK_IDENTIFICADOR init|
TK_PR_STATIC TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR init|
TK_PR_STATIC TK_IDENTIFICADOR TK_IDENTIFICADOR init|
TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR init|
TK_IDENTIFICADOR TK_IDENTIFICADOR init
;

init:
TK_OC_LE TK_IDENTIFICADOR |
TK_OC_LE lit |
;

attribution:
TK_IDENTIFICADOR '=' expression |
TK_IDENTIFICADOR '[' expression ']' '=' expression |
TK_IDENTIFICADOR '.' TK_IDENTIFICADOR '=' expression
;

input:
TK_PR_INPUT expression
;

output:
TK_PR_OUTPUT list_exp
;

func_call:
TK_IDENTIFICADOR '('')' |
TK_IDENTIFICADOR '(' func_params ')' |
TK_IDENTIFICADOR '('')' TK_OC_U1 pipes_func |
TK_IDENTIFICADOR '('')' TK_OC_U2 pipes_func
;

func_params:
func_params ',' expression |
expression
;

pipes_func:
pipes_func TK_OC_U2 pipe_func |
pipes_func TK_OC_U1 pipe_func |
pipe_func
;

pipe_func:
TK_IDENTIFICADOR '(' '.' pipes_exp ')'
;

pipes_exp:
',' expression pipes_exp |
;

shift:
TK_IDENTIFICADOR TK_OC_SL TK_LIT_INT |
TK_IDENTIFICADOR TK_OC_SR TK_LIT_INT
;

list_exp:
list_exp ',' expression |
expression
;

conditional:
TK_PR_IF '(' expression ')' TK_PR_THEN command_block |
TK_PR_IF '(' expression ')' TK_PR_THEN command_block TK_PR_ELSE command_block
;

iterative:
TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' list_exp ')' command_block |
TK_PR_FOR '(' list_exp ':' expression ':' list_exp ')' command_block |
TK_PR_WHILE '(' expression ')' TK_PR_DO command_block |
TK_PR_DO command_block TK_PR_WHILE '(' expression ')'
;

switch:
TK_PR_SWITCH '(' expression ')' command_block
;

control_flow:
TK_PR_RETURN expression |
TK_PR_BREAK |
TK_PR_CONTINUE |
TK_PR_CASE TK_LIT_INT ':'
;

expression:
'('expression')' |
expression '*' expression |
expression '+' expression |
expression '-' expression |
expression '/' expression |
expression '>' expression |
expression '<' expression |
expression TK_OC_LE expression |
expression TK_OC_GE expression |
expression TK_OC_EQ expression |
expression TK_OC_NE expression |
expression TK_OC_AND expression |
expression TK_OC_OR expression |
expression TK_OC_SL expression |
expression TK_OC_SR expression |
TK_LIT_FLOAT |
TK_LIT_INT |
func_call |
TK_IDENTIFICADOR |
TK_IDENTIFICADOR '['expression']'
;
%%
