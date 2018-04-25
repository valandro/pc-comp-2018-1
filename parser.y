/*
  GAMMA
*/
%code requires{
#include "main.h"
#include "cc_tree.h"
comp_tree_t* tree;
comp_tree_t* last_function;
}
// Inicializando contador que identifica a primeira função
%{
  int count = 0;
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

%type <valor_lexico> TK_LIT_INT
%type <valor_lexico> TK_LIT_FLOAT
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
  ast_node_t* node = malloc(sizeof(ast_node_t));
  node->type = AST_PROGRAMA;

  tree = tree_make_node((void*)node);
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
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_FUNCAO;
  node->value.data = $3;
  $$ = tree_make_node((void*)node);
  if($8 != NULL){
    tree_insert_node($$,$8);
  }  
}|
type TK_IDENTIFICADOR '(' list_params ')' '{' simple_commands '}' {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_FUNCAO;
  node->value.data = $2;
  $$ = tree_make_node((void*)node);
  if($7 != NULL){
    tree_insert_node($$,$7);
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
    ast_node_t *node = malloc(sizeof(ast_node_t));
    node->type = AST_BLOCO;
    $$ = tree_make_node((void*)node);
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
simple_commands declare_var_local ';' |
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
simple_commands conditional  ';'|
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
simple_commands switch |
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
TK_IDENTIFICADOR '=' expression {
  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $1;
  comp_tree_t* ident_node = tree_make_node((void*)ident);

  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ATRIBUICAO;

  $$ = tree_make_binary_node((void*)node, ident_node, $3);
}|
TK_IDENTIFICADOR '[' expression ']' '=' expression {
  ast_node_t *vetor = malloc(sizeof(ast_node_t));
  vetor->type = AST_VETOR_INDEXADO;

  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $1;
  comp_tree_t* ident_node = tree_make_node((void*)ident);

  comp_tree_t* vetor_tree_node = tree_make_binary_node((void*)vetor, ident_node, $3);

  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ATRIBUICAO;

  $$ = tree_make_binary_node((void*)node, vetor_tree_node, $6);
}|
TK_IDENTIFICADOR '.' TK_IDENTIFICADOR '=' expression {
  ast_node_t *vetor = malloc(sizeof(ast_node_t));
  vetor->type = AST_TIPO_CAMPO;

  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $1;
  comp_tree_t* ident_node = tree_make_node((void*)ident);

  ast_node_t *ident_campo = malloc(sizeof(ast_node_t));
  ident_campo->type = AST_IDENTIFICADOR;
  ident_campo->value.data = $1;
  comp_tree_t* ident_node_campo = tree_make_node((void*)ident_campo);

  comp_tree_t* vetor_tree_node = tree_make_binary_node((void*)vetor, ident_node, ident_node_campo);

  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ATRIBUICAO;

  $$ = tree_make_binary_node((void*)node, vetor_tree_node, $5);
}
;

input:
TK_PR_INPUT expression {
  ast_node_t *ast_return = malloc(sizeof(ast_node_t));
  ast_return->type = AST_INPUT;
  $$ = tree_make_unary_node((void*)ast_return, $2);
}
;

output:
TK_PR_OUTPUT list_exp {
  ast_node_t *ast_return = malloc(sizeof(ast_node_t));
  ast_return->type = AST_OUTPUT;
  $$ = tree_make_unary_node((void*)ast_return, $2);
}
;

func_call:
TK_IDENTIFICADOR '(' ')' {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_CHAMADA_DE_FUNCAO;

  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $1;

  comp_tree_t* ident_tree = tree_make_node((void*)ident);

  $$ = tree_make_unary_node((void*)node,ident_tree);
  
}|
TK_IDENTIFICADOR '(' func_params ')' {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_CHAMADA_DE_FUNCAO;

  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $1;

  comp_tree_t* ident_tree = tree_make_node((void*)ident);

  $$ = tree_make_binary_node((void*)node,ident_tree,$3);
  
}|
TK_IDENTIFICADOR '('')' TK_OC_U1 pipes_func |
TK_IDENTIFICADOR '(' func_params ')' TK_OC_U1 pipes_func |
TK_IDENTIFICADOR '('')' TK_OC_U2 pipes_func |
TK_IDENTIFICADOR '(' func_params ')' TK_OC_U2 pipes_func
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
TK_IDENTIFICADOR TK_OC_SL TK_LIT_INT {
  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $1;
  
  comp_tree_t* ident_node = tree_make_node((void*)ident);

  ast_node_t *lit = malloc(sizeof(ast_node_t));
    
  lit->type = AST_LITERAL;
  lit->value.data = $3;
  
  comp_tree_t* int_node = tree_make_node((void*)lit);

  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_SHIFT_LEFT;

  $$ = tree_make_binary_node((void*)node, ident_node, int_node);

}|
TK_IDENTIFICADOR TK_OC_SR TK_LIT_INT {
    ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $1;
  
  comp_tree_t* ident_node = tree_make_node((void*)ident);

  ast_node_t *lit = malloc(sizeof(ast_node_t));
    
  lit->type = AST_LITERAL;
  lit->value.data = $3;
  
  comp_tree_t* int_node = tree_make_node((void*)lit);

  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_SHIFT_RIGHT;

  $$ = tree_make_binary_node((void*)node, ident_node, int_node);
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
TK_PR_IF '(' expression ')' TK_PR_THEN command_block |
TK_PR_IF '(' expression ')' TK_PR_THEN command_block TK_PR_ELSE command_block
;

iterative:
TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' list_exp ')' command_block |
TK_PR_FOR '(' list_exp ':' expression ':' list_exp ')' command_block |
TK_PR_WHILE '(' expression ')' TK_PR_DO '{' simple_commands '}' {
  ast_node_t *while_value = malloc(sizeof(ast_node_t));
  while_value->type = AST_WHILE_DO;

  comp_tree_t* while_tree_node = tree_make_node((void*)while_value);
  tree_insert_node(while_tree_node, $3);
  tree_insert_node(while_tree_node, $7);

  $$ = while_tree_node;
}|
TK_PR_DO '{' simple_commands '}' TK_PR_WHILE '(' expression ')' {
  ast_node_t *while_value = malloc(sizeof(ast_node_t));
  while_value->type = AST_DO_WHILE;

  comp_tree_t* while_tree_node = tree_make_node((void*)while_value);
  tree_insert_node(while_tree_node, $3);
  tree_insert_node(while_tree_node, $7);

  $$ = while_tree_node;
}
;

switch:
TK_PR_SWITCH '(' expression ')' command_block
;

control_flow:
TK_PR_RETURN expression {
  ast_node_t *ast_return = malloc(sizeof(ast_node_t));
  ast_return->type = AST_RETURN;
  $$ = tree_make_unary_node((void*)ast_return, $2);
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
expression '*' expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ARIM_MULTIPLICACAO;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression '+' expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ARIM_SOMA;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression '-' expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ARIM_SUBTRACAO;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression '/' expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ARIM_DIVISAO;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression '>' expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_COMP_G;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression '<' expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_COMP_L;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_LE expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_COMP_LE;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_GE expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_COMP_GE;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_EQ expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_COMP_IGUAL;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_NE expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_COMP_DIF;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_AND expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_E;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_OR expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_OU;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_SL expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_SHIFT_LEFT;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_SR expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_SHIFT_RIGHT;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
TK_LIT_INT {
  
  ast_node_t *node = malloc(sizeof(ast_node_t));
    
  node->type = AST_LITERAL;
  node->value.data = $1;
  
  $$ = tree_make_node((void*)node);
}|
TK_LIT_FLOAT {
  
  ast_node_t *node = malloc(sizeof(ast_node_t));
    
  node->type = AST_LITERAL;
  node->value.data = $1;
  
  $$ = tree_make_node((void*)node);
}|
func_call {$$ = $1;}|
TK_IDENTIFICADOR {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_IDENTIFICADOR;
  node->value.data = $1;
  $$ = tree_make_node((void*)node);
}|
TK_IDENTIFICADOR '['expression']' {
    ast_node_t *ident = malloc(sizeof(ast_node_t));
    ident->type = AST_IDENTIFICADOR;
    ident->value.data = $1;
    comp_tree_t* ident_tree = tree_make_node((void*)ident);

    ast_node_t *node = malloc(sizeof(ast_node_t));
    node->type = AST_VETOR_INDEXADO;
    $$ = tree_make_binary_node((void*)node, ident_tree, $3);
}
;
%%
