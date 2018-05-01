/*
  GAMMA
*/
%code requires{
#include "main.h"
#include "cc_tree.h"
comp_tree_t* tree;
comp_tree_t* last_function;
comp_tree_t* list_exp;

}
// Inicializando contador que identifica a primeira função
%{
  int count = 0;
  int pcount = 0;  
%}
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
%type <node> program
%type <node> body
%type <node> dec_func
%type <node> command_block
%type <node> simple_commands
%type <node> attribution
%type <node> expression
%type <node> control_flow
%type <node> shift
%type <node> input
%type <node> output
%type <node> list_exp
%type <node> func_params
%type <node> func_call
%type <node> iterative
%type <node> conditional
%type <node> switch
%type <node> init
%type <node> declare_var_local
%type <node> pipes_exp
%type <node> pipes_func

%type <valor_lexico> lit
%type <valor_lexico> TK_LIT_INT
%type <valor_lexico> TK_LIT_FLOAT
%type <valor_lexico> TK_LIT_FALSE
%type <valor_lexico> TK_LIT_TRUE
%type <valor_lexico> TK_LIT_CHAR
%type <valor_lexico> TK_LIT_STRING
%type <valor_lexico> TK_IDENTIFICADOR


%union
{
  symbol* valor_lexico;
  comp_tree_t* node;
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

program: body {
  tree = ast_make_tree(AST_PROGRAMA, NULL);
  $$ = tree;

  if ($1 != NULL){
    tree_insert_node($$,$1);
  }
}
;

body:
body dec_var_new_type ';'|
body dec_var_global ';' |
body dec_func {
  comp_tree_t* first;

  $$ = first;
  //Se não for a primeira função, concatena na ultima função
  if(count > 0) {
    tree_insert_node(last_function,$2);
  }

  last_function = $2;
  count++;

  if(count == 1){
    first = $2;
    $$ = $2;
  }

}|
/* empty */ {$$ = NULL;}
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
TK_PR_STATIC type TK_IDENTIFICADOR '(' list_params ')' '{' simple_commands '}' {
  $$ = ast_make_tree(AST_FUNCAO, $3);
  if ($8 != NULL)
  {
    tree_insert_node($$, $8);
  }
}|
type TK_IDENTIFICADOR '(' list_params ')' '{' simple_commands '}' {
  $$ = ast_make_tree(AST_FUNCAO, $2);
  if ($7 != NULL)
  {
    tree_insert_node($$, $7);
  }
}
;

list_params:
param ',' list_params |
param |
;

param:
type TK_IDENTIFICADOR |
TK_PR_CONST type TK_IDENTIFICADOR
;

command_block:
'{' simple_commands '}' {
    $$ = ast_make_tree(AST_BLOCO, NULL);
    if($2 != NULL) {
      tree_insert_node($$,$2);
    }
}
;

simple_commands:
simple_commands command_block ';' { 
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else {
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
simple_commands declare_var_local ';' {
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else {
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
simple_commands attribution ';' {
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else {
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
simple_commands input ';' {
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else {
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
simple_commands output ';' {
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else {
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
simple_commands shift  ';' {
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else {
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
simple_commands func_call ';' {
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else if($2 != NULL){
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
simple_commands conditional  ';' {
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else if($2 != NULL){
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
simple_commands iterative ';' {
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else if($2 != NULL){
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
simple_commands switch {
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else {
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
simple_commands control_flow ';' {
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else if($2 != NULL){
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
/* empty */ {$$ = NULL;}
;

declare_var_local:
TK_PR_STATIC TK_PR_CONST type TK_IDENTIFICADOR init{
  if($5 != NULL){
    comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $4);
    $$ = ast_make_binary_node(AST_DEC_INIT, ident_node, $5);
  }
}|
TK_PR_STATIC type TK_IDENTIFICADOR init {
  if($4 != NULL){  
    comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $3);
    $$ = ast_make_binary_node(AST_DEC_INIT, ident_node, $4);
  }
}|
TK_PR_CONST type TK_IDENTIFICADOR init {
  if($4 != NULL){    
    comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $3);
    $$ = ast_make_binary_node(AST_DEC_INIT, ident_node, $4);
  }
}|
type TK_IDENTIFICADOR init {
  if($3 != NULL){
    comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $2);
    $$ = ast_make_binary_node(AST_DEC_INIT, ident_node, $3);
  }
}|
TK_PR_STATIC TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR init {
  if($5 != NULL){
    comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $4);
    $$ = ast_make_binary_node(AST_DEC_INIT, ident_node, $5);
  }
}|
TK_PR_STATIC TK_IDENTIFICADOR TK_IDENTIFICADOR init {
  if($4 != NULL){      
    comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $3);
    $$ = ast_make_binary_node(AST_DEC_INIT, ident_node, $4);
  }
}|
TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR init {
  if($4 != NULL){
    comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $3); 
    $$ = ast_make_binary_node(AST_DEC_INIT, ident_node, $4);
  }
}|
TK_IDENTIFICADOR TK_IDENTIFICADOR init {
  if($3 != NULL){
    comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $2);
    $$ = ast_make_binary_node(AST_DEC_INIT, ident_node, $3);
  }
}
;

init:
TK_OC_LE TK_IDENTIFICADOR { $$ = ast_make_tree(AST_IDENTIFICADOR, $2); }|
TK_OC_LE lit { $$ = ast_make_tree(AST_LITERAL, $2); }|
/* empty */ {$$ = NULL;}
;

attribution:
TK_IDENTIFICADOR '=' expression {
  comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $1);

  $$ = ast_make_binary_node(AST_ATRIBUICAO, ident_node, $3);
}|
TK_IDENTIFICADOR '[' expression ']' '=' expression {
  comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $1);
  comp_tree_t* vetor_tree_node = ast_make_binary_node(AST_VETOR_INDEXADO, ident_node, $3);

  $$ = ast_make_binary_node(AST_ATRIBUICAO, vetor_tree_node, $6);
}|
TK_IDENTIFICADOR '.' TK_IDENTIFICADOR '=' expression {
  comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $1);
  comp_tree_t* ident_node_campo = ast_make_tree(AST_IDENTIFICADOR, $3);

  comp_tree_t* vetor_tree_node = ast_make_binary_node(AST_TIPO_CAMPO, ident_node, ident_node_campo);
  $$ = ast_make_binary_node(AST_ATRIBUICAO, vetor_tree_node, $5);
}
;

input:
TK_PR_INPUT expression { $$ = ast_make_unary_node(AST_INPUT, $2); }
;

output:
TK_PR_OUTPUT list_exp { $$ = ast_make_unary_node(AST_OUTPUT, $2); }
;

func_call:
TK_IDENTIFICADOR '(' ')' {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  $$ = ast_make_unary_node(AST_CHAMADA_DE_FUNCAO, ident_tree);
}|
TK_IDENTIFICADOR '(' func_params ')' {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  $$ = ast_make_binary_node(AST_CHAMADA_DE_FUNCAO,ident_tree,$3);
}|
TK_IDENTIFICADOR '('')' TK_OC_U1 pipes_func {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  $$ = ast_make_binary_node(AST_PIPE_R1,ident_tree,$5);
}|
TK_IDENTIFICADOR '(' func_params ')' TK_OC_U1 pipes_func {$$ = NULL;}|
TK_IDENTIFICADOR '('')' TK_OC_U2 pipes_func {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  $$ = ast_make_binary_node(AST_PIPE_R2,ident_tree,$5);
}|
TK_IDENTIFICADOR '(' func_params ')' TK_OC_U2 pipes_func {$$ = NULL;}
;

func_params:
expression ',' func_params {
  if($3 != NULL){
    tree_insert_node($$,$3);   
  }
}|
expression
;

pipes_func:
pipes_func TK_OC_U2 TK_IDENTIFICADOR '(' '.' pipes_exp ')' {
  // TODO: Finalizar pipes.
  if($6 != NULL){
    // tree_insert_node($$,$6);   
  }
}|
pipes_func TK_OC_U1 TK_IDENTIFICADOR '(' '.' pipes_exp ')' {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $3);
  $$ = ast_make_unary_node(AST_PIPE_R1,ident_tree);
}|
TK_IDENTIFICADOR '(' '.' pipes_exp ')' {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  
  if($4 == NULL){
    $$ = ident_tree;   
  } else {
    tree_insert_node(ident_tree,$4);
    $$ = ident_tree;                  
  }
}
;

pipes_exp:
',' expression pipes_exp {
  $$ = $2;
}| {$$ = NULL;}
;

shift:
TK_IDENTIFICADOR TK_OC_SL TK_LIT_INT { 
  comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $1);
  comp_tree_t* int_node = ast_make_tree(AST_LITERAL, $3);

  $$ = ast_make_binary_node(AST_SHIFT_LEFT, ident_node, int_node);
}|
TK_IDENTIFICADOR TK_OC_SR TK_LIT_INT {
  comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $1);
  comp_tree_t* int_node = ast_make_tree(AST_LITERAL, $3);

  $$ = ast_make_binary_node(AST_SHIFT_RIGHT, ident_node, int_node);
}
;

list_exp:
expression ',' list_exp {
  if($3 != NULL){
   tree_insert_node($$,$3);   
  }
}|
expression
;

conditional:
TK_PR_IF '(' expression ')' TK_PR_THEN '{' simple_commands '}' {
  comp_tree_t* if_then_tree_node = ast_make_tree(AST_IF_ELSE, NULL);

  ast_node_t *t = $3->value;
  tree_insert_node(if_then_tree_node, $3);
  if ($7 != NULL) {
    tree_insert_node(if_then_tree_node, $7);
  }
  $$ = if_then_tree_node;
}|
TK_PR_IF '(' expression ')' TK_PR_THEN '{' simple_commands '}' TK_PR_ELSE '{' simple_commands '}' {
  comp_tree_t* if_then_tree_node = ast_make_tree(AST_IF_ELSE, NULL);
  tree_insert_node(if_then_tree_node, $3);
  if ($7 != NULL) {
    tree_insert_node(if_then_tree_node, $7);
  }
  if ($11 != NULL) {
    tree_insert_node(if_then_tree_node, $11);
  }
  $$ = if_then_tree_node;
}
;

iterative:
TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' list_exp ')' '{' simple_commands '}' {
  comp_tree_t* ident_node = ast_make_tree(AST_IDENTIFICADOR, $3);
  comp_tree_t* foreach_tree_node = ast_make_tree(AST_FOREACH, NULL);

  tree_insert_node(foreach_tree_node,$5);
  tree_insert_node(foreach_tree_node,$8);
  tree_insert_node(foreach_tree_node,ident_node);

  $$ = foreach_tree_node;
}|
TK_PR_FOR '(' list_exp ':' expression ':' list_exp ')' '{' simple_commands '}' {
  comp_tree_t* for_tree_node = ast_make_tree(AST_FOR, NULL);

  tree_insert_node(for_tree_node,$3);
  tree_insert_node(for_tree_node,$5);
  tree_insert_node(for_tree_node,$7);
  tree_insert_node(for_tree_node,$10);  

  $$ = for_tree_node;
}|
TK_PR_WHILE '(' expression ')' TK_PR_DO '{' simple_commands '}' {
  comp_tree_t* while_tree_node = ast_make_tree(AST_WHILE_DO, NULL);
  tree_insert_node(while_tree_node, $3);
  tree_insert_node(while_tree_node, $7);

  $$ = while_tree_node;
}|
TK_PR_DO '{' simple_commands '}' TK_PR_WHILE '(' expression ')' {
  comp_tree_t* while_tree_node = ast_make_tree(AST_DO_WHILE, NULL);
  tree_insert_node(while_tree_node, $3);
  tree_insert_node(while_tree_node, $7);

  $$ = while_tree_node;
}
;

switch:
TK_PR_SWITCH '(' expression ')' '{' simple_commands '}' {
  comp_tree_t* switch_tree_node = ast_make_tree(AST_SWITCH, NULL);

  if($3 != NULL){
    tree_insert_node(switch_tree_node,$3);
  }
  if($6 != NULL){
    tree_insert_node(switch_tree_node,$6);
  }
  $$ = switch_tree_node;
}
;

control_flow:
TK_PR_RETURN expression {
  $$ = ast_make_unary_node(AST_RETURN, $2);
}|
TK_PR_BREAK {
  $$ = NULL;
}|
TK_PR_CONTINUE {
  $$ = NULL;
}|
TK_PR_CASE TK_LIT_INT ':' {
  $$ = NULL;
}
;

expression:
'('expression')' {$$ = $2;}|
'-' expression {$$ = $2;}|
'+' expression {$$ = $2;}|
expression '*' expression { $$ = ast_make_binary_node(AST_ARIM_MULTIPLICACAO, $1, $3); }|
expression '+' expression { $$ = ast_make_binary_node(AST_ARIM_SOMA, $1, $3); }|
expression '-' expression { $$ = ast_make_binary_node(AST_ARIM_SUBTRACAO, $1, $3); }|
expression '/' expression { $$ = ast_make_binary_node(AST_ARIM_DIVISAO, $1, $3); }|
expression '>' expression { $$ = ast_make_binary_node(AST_LOGICO_COMP_G, $1, $3); }|
expression '<' expression { $$ = ast_make_binary_node(AST_LOGICO_COMP_L, $1, $3); }|
expression TK_OC_LE expression { $$ = ast_make_binary_node(AST_LOGICO_COMP_LE, $1, $3); }|
expression TK_OC_GE expression { $$ = ast_make_binary_node(AST_LOGICO_COMP_GE, $1, $3); }|
expression TK_OC_EQ expression { $$ = ast_make_binary_node(AST_LOGICO_COMP_IGUAL, $1, $3); }|
expression TK_OC_NE expression { $$ = ast_make_binary_node(AST_LOGICO_COMP_DIF, $1, $3); }|
expression TK_OC_AND expression { $$ = ast_make_binary_node(AST_LOGICO_E, $1, $3); }|
expression TK_OC_OR expression { $$ = ast_make_binary_node(AST_LOGICO_OU, $1, $3); }|
expression TK_OC_SL expression { $$ = ast_make_binary_node(AST_SHIFT_LEFT, $1, $3); }|
expression TK_OC_SR expression { $$ = ast_make_binary_node(AST_SHIFT_RIGHT, $1, $3); }|
TK_LIT_INT { $$ = ast_make_tree(AST_LITERAL, $1); }|
TK_LIT_FLOAT { $$ = ast_make_tree(AST_LITERAL, $1); }|
func_call { $$ = $1; }|
TK_IDENTIFICADOR { $$ = ast_make_tree(AST_IDENTIFICADOR, $1); }|
TK_IDENTIFICADOR '['expression']' {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  $$ = ast_make_binary_node(AST_VETOR_INDEXADO, ident_tree, $3);
}
;
%%
