/*
  GAMMA - Lucas Valandro e Francisco Knebel
  UFRGS 2018
*/
%code requires{
#include "main.h"
#include "cc_tree.h"
comp_tree_t* tree;
extern comp_dict_t* symbol_table;
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
%type <node> program
%type <node> body
%type <node> dec_func
%type <node> command_block
%type <node> simple_commands
%type <node> commands
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
%type <node> fp
%type <node> pipes

%type <valor_lexico> lit
%type <valor_lexico> TK_LIT_INT
%type <valor_lexico> TK_LIT_FLOAT
%type <valor_lexico> TK_LIT_FALSE
%type <valor_lexico> TK_LIT_TRUE
%type <valor_lexico> TK_LIT_CHAR
%type <valor_lexico> TK_LIT_STRING
%type <valor_lexico> TK_IDENTIFICADOR
%type <type> type
%type <type> param

%type <param_list> list_params
%type <param_list> list_fields

%union
{
  symbol* valor_lexico;
  comp_tree_t* node;
  int type;
  ParamList* param_list;
}

%start program
%%
/* Regras (e ações) da gramática */
/* Regras de apoio - Começo */
type:
TK_PR_INT    {$$ = IKS_INT;}  |
TK_PR_FLOAT  {$$ = IKS_FLOAT;}|
TK_PR_CHAR   {$$ = IKS_CHAR;} |
TK_PR_BOOL   {$$ = IKS_BOOL;} |
TK_PR_STRING {$$ = IKS_STRING;}
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
  if($2 != NULL && $1 != NULL){
    $$ = $1;
    tree_insert_node($$,$2);
  } else if($2 != NULL){
    $$ = $2;
  } else {
    $$ = $1;
  }
}|
/* empty */ {$$ = NULL;}
;

dec_var_new_type:
TK_PR_CLASS TK_IDENTIFICADOR '[' list_fields ']' {
  declare_class($2, $4);
}
;

list_fields:
encap type TK_IDENTIFICADOR ':' list_fields {
  // Adiciona argumentos na lista.
  $$ = ParamList_addParam($5, $2, $3->value.s);
} |
encap type TK_IDENTIFICADOR  {
  // Último parâmetro da lista, inicia lista de argumentos.
  ParamList* param_list = ParamList_init($2, $3->value.s);
  $$ = param_list;
}
;

dec_var_global:
declare |
TK_PR_STATIC declare |
TK_PR_CLASS declare |
TK_PR_STATIC TK_PR_CLASS declare
;

declare:
type TK_IDENTIFICADOR '[' TK_LIT_INT ']' {
  declare_var($2,$1,$4->value.i, GLOBAL_SCOPE);
}|
type TK_IDENTIFICADOR {
  declare_var($2,$1,IKS_NON_VECTOR, GLOBAL_SCOPE);
}|
TK_IDENTIFICADOR TK_IDENTIFICADOR {
  declare_var($2,IKS_USER_TYPE,IKS_NON_VECTOR, GLOBAL_SCOPE);   
}|
TK_IDENTIFICADOR TK_IDENTIFICADOR '[' TK_LIT_INT ']' {
  declare_var($2,IKS_USER_TYPE,$4->value.i, GLOBAL_SCOPE);   
}
;

dec_func:
TK_PR_STATIC type TK_IDENTIFICADOR '(' list_params ')' '{' commands '}' {
  $$ = ast_make_tree(AST_FUNCAO, $3);
  if ($8 != NULL)
  {
    tree_insert_node($$, $8);
  }
}|
type TK_IDENTIFICADOR '(' list_params ')' '{' commands '}' {
  $$ = ast_make_tree(AST_FUNCAO, $2);
  if ($7 != NULL)
  {
    tree_insert_node($$, $7);
  }
}
;

list_params:
param ',' list_params {
  // Adiciona argumentos na lista.
  $$ = ParamList_addParam($3, $1, NULL);
}|
param {
  // Último parâmetro da lista, inicia lista de argumentos.
  ParamList* param_list = ParamList_init($1, NULL);
  $$ = param_list;
}| {
  $$ = NULL;
}
;

param:
type TK_IDENTIFICADOR {
  $$ = $1;
}|
TK_PR_CONST type TK_IDENTIFICADOR {
  $$ = $2; 
}
;

command_block:
'{' commands '}' {
    $$ = ast_make_tree(AST_BLOCO, NULL);
    if($2 != NULL) {
      tree_insert_node($$,$2);
    }
}
;
commands: 
simple_commands commands {
  if($2 != NULL && $1 != NULL){
    $$ = $1;
    tree_insert_node($$,$2);
  } else if($2 != NULL){
    $$ = $2;
  } else {
    $$ = $1;
  }
} | {$$ = NULL;}
;
simple_commands:
command_block ';'{
  $$ = $1;
}|
declare_var_local ';' {
  $$ = $1;
}|
attribution ';' {
  $$ = $1;
}|
input ';' {
  $$ = $1;
}|
output ';' {
  $$ = $1;
}|
shift  ';' {
  $$ = $1;
}|
func_call ';' {
  $$ = $1;
}|
conditional  ';' {
  $$ = $1;
}|
iterative ';' {
  $$ = $1;
}|
switch {
  $$ = $1;
}|
control_flow ';' {
  $$ = $1;
}
;

declare_var_local:
TK_PR_STATIC TK_PR_CONST type TK_IDENTIFICADOR init{
  $$ = ast_dec_init(AST_IDENTIFICADOR,$4,$5);
  declare_var($4,$3,IKS_NON_VECTOR, LOCAL_SCOPE);  
}|
TK_PR_STATIC type TK_IDENTIFICADOR init {
  $$ = ast_dec_init(AST_IDENTIFICADOR,$3,$4);
  declare_var($3,$2,IKS_NON_VECTOR, LOCAL_SCOPE);      
}|
TK_PR_CONST type TK_IDENTIFICADOR init {
  $$ = ast_dec_init(AST_IDENTIFICADOR,$3,$4);
  declare_var($3,$2,IKS_NON_VECTOR, LOCAL_SCOPE);        
}|
type TK_IDENTIFICADOR init {
  $$ = ast_dec_init(AST_IDENTIFICADOR,$2,$3);
  declare_var($2,$1,IKS_NON_VECTOR, LOCAL_SCOPE);  
}|
TK_PR_STATIC TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR init {
  $$ = ast_dec_init(AST_IDENTIFICADOR,$4,$5);
  declare_var($4,IKS_USER_TYPE,IKS_NON_VECTOR, LOCAL_SCOPE);    
}|
TK_PR_STATIC TK_IDENTIFICADOR TK_IDENTIFICADOR init {
  $$ = ast_dec_init(AST_IDENTIFICADOR,$3,$4);
  declare_var($3,IKS_USER_TYPE,IKS_NON_VECTOR, LOCAL_SCOPE);      
}|
TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR init {
  $$ = ast_dec_init(AST_IDENTIFICADOR,$3,$4);
  declare_var($3,IKS_USER_TYPE,IKS_NON_VECTOR, LOCAL_SCOPE);        
}|
TK_IDENTIFICADOR TK_IDENTIFICADOR init {
  $$ = ast_dec_init(AST_IDENTIFICADOR,$2,$3);
  declare_var($2,IKS_USER_TYPE,IKS_NON_VECTOR, LOCAL_SCOPE);        
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

  char* key = dict_concat_key($1->value.s, $1->type);
  symbol* value = dict_get(symbol_table, key);

  int achou = 0;
  ParamList* previous = NULL;
  ParamList* current = value->field_list;
  do {
    if(strcmp(current->identificador, $3->value.s) == 0) {
      achou = 1;
    } else {
      previous = current;
      current = current->next;
    }
  } while(previous->next != NULL && achou == 0);

  if(achou == 0) {
    // Campo da classe inválido.
    exit(IKS_ERROR_CLASS_INVALID_FIELD);
  }

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
TK_IDENTIFICADOR '('')' TK_OC_U1 fp pipes {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  comp_tree_t* pipe_tree = ast_make_unary_node(AST_PIPE_R1, $5);
  if($6 != NULL){
    tree_insert_node(pipe_tree,$6);
  }
  $$ = ast_make_binary_node(AST_CHAMADA_DE_FUNCAO,ident_tree,pipe_tree);
}|
TK_IDENTIFICADOR '(' func_params ')' TK_OC_U1 fp pipes {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  comp_tree_t* pipe_tree = ast_make_unary_node(AST_PIPE_R1, $6);
  if($7 != NULL){
    tree_insert_node(pipe_tree,$7);
  }
  $$ = ast_make_ternary_node(AST_CHAMADA_DE_FUNCAO,ident_tree,$3,pipe_tree);
}|
TK_IDENTIFICADOR '('')' TK_OC_U2 fp pipes {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  comp_tree_t* pipe_tree = ast_make_unary_node(AST_PIPE_R2, $5);
  if($6 != NULL){
    tree_insert_node(pipe_tree,$6);
  }
  $$ = ast_make_binary_node(AST_CHAMADA_DE_FUNCAO,ident_tree,pipe_tree);
}|
TK_IDENTIFICADOR '(' func_params ')' TK_OC_U2 fp pipes {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  comp_tree_t* pipe_tree = ast_make_unary_node(AST_PIPE_R2, $6);
  if($7 != NULL){
    tree_insert_node(pipe_tree,$7);
  }
  $$ = ast_make_ternary_node(AST_CHAMADA_DE_FUNCAO,ident_tree,$3,pipe_tree);
}
;

func_params:
expression ',' func_params {
  // TODO: fix árvore de paramêtros da função
  // if($3 != NULL){
  //   tree_insert_node($$,$3);   
  // }

  // Adiciona argumentos na lista.
  // $$ = ParamList_addParam($3, $1, NULL);
}|
expression {
  ast_node_t* node_ast = (ast_node_t*) $1->value;
  symbol* data = node_ast->value.data;

  char key[1000]; // Magic number
  switch(data->type) {
    case POA_LIT_INT:  
      sprintf(key, "%d$%d", data->value.i, (int)data->type);
      break;
    case POA_LIT_FLOAT:
      sprintf(key, "%f$%d", data->value.f, (int)data->type);
      break;
    case POA_LIT_CHAR:
      sprintf(key, "%c$%d", data->value.c, (int)data->type);
      break;
    case POA_LIT_STRING:
      sprintf(key, "%s$%d", data->value.s, (int)data->type);
      break;
    case POA_IDENT:
      sprintf(key, "%s$%d", data->value.s, (int)data->type);
      break;
  }

  symbol* value = dict_get(symbol_table, key);
  ParamList* param_list = ParamList_init(value->iks_type[LOCAL_SCOPE], NULL);

  // $$ = param_list;
}
;

fp:
TK_IDENTIFICADOR '(' '.' ')' {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  $$ = ident_tree;

}| 
TK_IDENTIFICADOR '(' '.' ',' list_exp ')' {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  $$ = ident_tree;

  if($5 != NULL){
    tree_insert_node(ident_tree,$5);
  }
}
;
pipes:
TK_OC_U1 fp pipes {
  comp_tree_t* pipe_r1 = ast_make_unary_node(AST_PIPE_R1,$2);
  $$ = pipe_r1;
  if($3 != NULL){
    tree_insert_node(pipe_r1,$3);
  }
}|
TK_OC_U2 fp pipes {
  comp_tree_t* pipe_r2 = ast_make_unary_node(AST_PIPE_R2,$2);
  $$ = pipe_r2;
  if($3 != NULL){
    tree_insert_node(pipe_r2,$3);
  }
}|
/* empty */ {$$ = NULL;}
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
TK_IDENTIFICADOR {
  $$ = ast_make_tree(AST_IDENTIFICADOR, $1); 
  ident_verify($1,LOCAL_SCOPE,IKS_NON_VECTOR);
}|
TK_IDENTIFICADOR '['expression']' {
  comp_tree_t* ident_tree = ast_make_tree(AST_IDENTIFICADOR, $1);
  $$ = ast_make_binary_node(AST_VETOR_INDEXADO, ident_tree, $3);
  ident_verify($1,LOCAL_SCOPE,IKS_VECTOR);  
}
;
%%
