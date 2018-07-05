/*
  GAMMA - Lucas Valandro e Francisco Knebel
  UFRGS 2018
*/

#include <stdio.h>

#include "cc_code_list.h"
#include "cc_cod.h"
#include "main.h"

extern CodeList* generatedILOC[10];
extern comp_dict_t* symbol_table;
extern int functionScope;

unsigned int global_offset = 0;
unsigned int local_offset = 0;

unsigned int registerIndex = 0;
unsigned int labelIndex = 0;


// Atualiza o contador de offset e retorna o valor original
unsigned int cod_offsetAndUpdate_global(int size)
{
  int returnValue = global_offset;

  global_offset += size;
  return returnValue;
}

unsigned int cod_offsetAndUpdate_local(int size)
{
  int returnValue = local_offset;

  local_offset += size;
  return returnValue;
}

unsigned int cod_generateTempRegister() {
  return registerIndex++;
}

unsigned int cod_generateLabel() {
  return labelIndex++;
}

/*
  Criação de uma string do label, ao informar um indíce.
    Entrada: 14
    Saída: "L14"
*/
char* cod_generateLabelName(int index) {
  char* label;
  label = malloc(COD_LABEL_LENGTH); // Magic number

  int check = snprintf(label, COD_LABEL_LENGTH, "L%d", index);
  if(check >= 0 && check < COD_LABEL_LENGTH) {
    return label;
  } else {
    puts("Falha ao criar nome de label.");
    free(label);

    exit(check);
  }
}

/*
  Passando o valor de tipo salvo retorna o tamanho da varíavel,
  para cálculo de endereçamento.
*/
int cod_sizeOf(int iks_type) {
  switch(iks_type) {
    case IKS_FLOAT:
    case IKS_INT:
      return 4;
    case IKS_CHAR:
    case IKS_BOOL:
      return 1;
    case IKS_STRING:
    default:
      return 0;
  }
}

/*
  Recebimento de um nodo e a geração de seu código,
  de acordo com o tipo informado.
*/
void cod_generate(comp_tree_t* node) {
  int nodeType = ((ast_node_t*) node->value)->type;

  // Switch sobre o nodo, para cada uma das estruturas possíveis
  // Em cada caso, chamar função que gera o código para essa estrutura.
  switch (nodeType)
  {
    case AST_IF_ELSE:             cod_generate_if_else(node); break;
    // case AST_DO_WHILE:
    // case AST_WHILE_DO:
    // case AST_INPUT:
    // case AST_OUTPUT:

    /* Nodos aritméticos */
    case AST_ARIM_SOMA:           cod_generate_arithmetic(node, "add"); break;
    case AST_ARIM_SUBTRACAO:      cod_generate_arithmetic(node, "sub"); break;
    case AST_ARIM_MULTIPLICACAO:  cod_generate_arithmetic(node, "mult"); break;
    case AST_ARIM_DIVISAO:        cod_generate_arithmetic(node, "div"); break;
    case AST_ARIM_INVERSAO:       cod_generate_arithmetic_invert(node); break;

    /* Shift */
    case AST_SHIFT_RIGHT:         cod_generate_arithmetic(node, "rshift"); break;
    case AST_SHIFT_LEFT:          cod_generate_arithmetic(node, "lshift"); break;

    /* Nodos de comparação lógica */
    case AST_LOGICO_E:
    case AST_LOGICO_OU:
    // Comparação booleana 
    case AST_LOGICO_COMP_DIF:
    case AST_LOGICO_COMP_IGUAL:
    case AST_LOGICO_COMP_LE:
    case AST_LOGICO_COMP_GE:
    case AST_LOGICO_COMP_L:
    case AST_LOGICO_COMP_G:
    case AST_LOGICO_COMP_NEGACAO: cod_generate_logic(node, nodeType);break;

    /* Nodos de varíaveis e valores */
    case AST_LITERAL:             cod_generate_literal(node); break;
    case AST_IDENTIFICADOR:       cod_generate_identificador(node); break;
    case AST_ATRIBUICAO:          cod_generate_atribuicao(node); break;
    case AST_DEC_INIT:            cod_generate_atribuicao(node); break;

    case AST_CHAMADA_DE_FUNCAO:   cod_generate_chamadafuncao(node); break;
    case AST_RETURN:              cod_generate_return(node); break;

    // case AST_BREAK:
    // case AST_CONTINUE:
    // case AST_CASE:
    // case AST_FOR:
    // case AST_FOREACH:
    // case AST_SWITCH:
    // case AST_TIPO_CAMPO:
    // case AST_PIPE_R1:
    // case AST_PIPE_R2:

    default:
      break;
  }
}

void cod_generate_logic(comp_tree_t *node, int op_type){
  char *op;
  comp_tree_t *exp1 = node->first;
  comp_tree_t *exp2 = node->first->next;

  ast_node_t *ast_res = node->value;
  ast_node_t *ast_exp1   = exp1->value;
  ast_node_t *ast_exp2   = exp2->value;

  switch(op_type){
    case AST_LOGICO_E:
      op = "and";
      break;
    case AST_LOGICO_OU:
      op = "or";
      break;
    case AST_LOGICO_COMP_DIF:
      op = "cmp_NE";
      break;
    case AST_LOGICO_COMP_IGUAL:
      op = "cmp_EQ";
      break;
    case AST_LOGICO_COMP_LE:
      op = "cmp_LE";    
      break;
    case AST_LOGICO_COMP_GE:
      op = "cmp_GE";    
      break;
    case AST_LOGICO_COMP_L:
      op = "cmp_LT";
      break;    
    case AST_LOGICO_COMP_G:
      op = "cmp_GT";
      break;
    case AST_LOGICO_COMP_NEGACAO:
      break;
    default:
      break;
  }

  int reg_1 = ast_exp1->reg;
  int reg_2 = ast_exp2->reg;

  // Gerar registrador temporário para o alvo.
  int reg_alvo = cod_generateTempRegister();
  
  // Gerar instrução
  char *code = malloc(COD_MAX_SIZE);
  snprintf(
    code, COD_MAX_SIZE,
    "%s r%d, r%d => r%d\n",
    op, reg_1, reg_2, reg_alvo
  );

  // Salvo registrador temporário de saída
  ast_res->reg = reg_alvo;

  CodeList_add_node(generatedILOC[functionScope], code, node->value);
};

void cod_generate_literal(comp_tree_t *node) {
  ast_node_t* ast_node = node->value;
  symbol* data = ast_node->value.data;

  char* code = malloc(COD_MAX_SIZE);
  int tempReg = cod_generateTempRegister();

  switch (data->type) {
    case POA_LIT_INT:
      snprintf(code, COD_MAX_SIZE, "loadI %d => r%d\n", data->value.i, tempReg);
      break;
    case POA_LIT_CHAR:
      snprintf(code, COD_MAX_SIZE, "loadI %d => r%d\n", data->value.c, tempReg);
      break;
    default:
      // No default behavior defined.
      break;
  }

  // Salva registrador temporário na AST e insere o código gerado na lista.
  ast_node->reg = tempReg;
  CodeList_add_node(generatedILOC[functionScope], code, ast_node);
};

void cod_generate_identificador(comp_tree_t *tree) {
  ast_node_t* node = tree->value;
  symbol* data = node->value.data;

  char* code = malloc(COD_MAX_SIZE);

  char* entry = dict_concat_key(data->value.s, data->type);
  symbol* table_data = dict_get(symbol_table, entry);

  int tempReg;
  int address_offset;
  if(table_data->iks_type[LOCAL_SCOPE] != IKS_NOT_SET_VALUE){
    // SE ESCOPO LOCAL: registrador rarp
    if(table_data->iks_reg[LOCAL_SCOPE] == IKS_NOT_SET_VALUE){
      tempReg = cod_generateTempRegister();
      table_data->iks_reg[LOCAL_SCOPE] = tempReg;
      address_offset = table_data->mem_pos[LOCAL_SCOPE];
      snprintf(code, COD_MAX_SIZE, "loadAI rarp, %d => r%d\n", address_offset, tempReg);

      node->reg = tempReg;
      node->offset = address_offset;

      CodeList_add_node(generatedILOC[functionScope], code, node);
    } else {
      node->reg = table_data->iks_reg[LOCAL_SCOPE];
      address_offset = table_data->mem_pos[LOCAL_SCOPE];
    }
  } else {
    if(table_data->iks_type[GLOBAL_SCOPE] != IKS_NOT_SET_VALUE){
      // SE ESCOPO GLOBAL: registrador rbss
      if(table_data->iks_reg[GLOBAL_SCOPE] == IKS_NOT_SET_VALUE){
        tempReg = cod_generateTempRegister();
        table_data->iks_reg[GLOBAL_SCOPE] = tempReg;
        address_offset = table_data->mem_pos[GLOBAL_SCOPE];
        snprintf(code, COD_MAX_SIZE, "loadAI rbss, %d => r%d\n", address_offset, tempReg);

        node->reg = tempReg;
        node->offset = address_offset;

        CodeList_add_node(generatedILOC[functionScope], code, node);
      } else {
        node->reg = table_data->iks_reg[GLOBAL_SCOPE];
        address_offset = table_data->mem_pos[GLOBAL_SCOPE];
      }
    }
  }
};

void cod_generate_atribuicao(comp_tree_t* node) 
{
  comp_tree_t *identificador = node->first;
  comp_tree_t *expressao = node->first->next;

  ast_node_t *ast_id    = identificador->value;
  ast_node_t *ast_exp   = expressao->value;

  char* code = malloc(COD_MAX_SIZE);

  int address_offset;
  int arrayIndex = -1;
  if(ast_id->type == AST_VETOR_INDEXADO) {
    // Identificador está aninhado no nodo, pois é um vetor.
    // Reescreve o nodo do identificador do vetor.
    ast_id = identificador->first->value;

    // Obtém valor inteiro do índice procurado, dentro do vetor.
    // TODO: não esperar valor inteiro e aceitar expressões.
    ast_node_t* indice = identificador->first->next->value;
    symbol* s_indice = indice->value.data;
    arrayIndex = s_indice->value.i;
  }

  char* entry = dict_concat_key(ast_id->value.data->value.s, ast_id->value.data->type);
  symbol* table_data = dict_get(symbol_table,entry);

  if(arrayIndex != -1) {
    // Está trabalhando com um array, logo precisa calcular o offset.
    address_offset = ast_id->offset + arrayIndex * cod_sizeOf(table_data->iks_type[GLOBAL_SCOPE]);

    if(arrayIndex >= table_data->vector_size) {
      exit(IKS_VECTOR_INDEX_OVERFLOW);
    }
  } else {
    if (table_data->iks_type[LOCAL_SCOPE] != IKS_NOT_SET_VALUE) {
      address_offset = ast_id->value.data->mem_pos[LOCAL_SCOPE];
    } else {
      address_offset = ast_id->value.data->mem_pos[GLOBAL_SCOPE];
    }
  }

  // SE ESCOPO GLOBAL: registrador rbss
  if(table_data->iks_type[GLOBAL_SCOPE] != IKS_NOT_SET_VALUE){
    snprintf(code, COD_MAX_SIZE, "storeAI r%d => rbss, %d\n", ast_exp->reg, address_offset);
    CodeList_add_node(generatedILOC[functionScope], code, node->value);
  }

  // SE ESCOPO LOCAL: registrador rarp
  if(table_data->iks_type[LOCAL_SCOPE] != IKS_NOT_SET_VALUE){
    snprintf(code, COD_MAX_SIZE, "storeAI r%d => rarp, %d\n", ast_exp->reg, address_offset);
    CodeList_add_node(generatedILOC[functionScope], code, node->value);
  }
};

void cod_generate_arithmetic(comp_tree_t * node, char *op) {
  // Pegar valores dos registradores da operação que estão no nodo.
  comp_tree_t *operador1 = node->first;
  comp_tree_t *operador2 = node->first->next;

  ast_node_t *ast_exp = node->value;
  ast_node_t *ast_op1 = operador1->value;
  ast_node_t *ast_op2 = operador2->value;

  int reg_1 = ast_op1->reg;
  int reg_2 = ast_op2->reg;

  // Gerar registrador temporário para o alvo.
  int reg_alvo = cod_generateTempRegister();

  // Gerar instrução
  char *code = malloc(COD_MAX_SIZE);
  snprintf(
    code, COD_MAX_SIZE,
    "%s r%d, r%d => r%d\n",
    op, reg_1, reg_2, reg_alvo
  );

  // Salvo registrador temporário de saída
  ast_exp->reg = reg_alvo;

  CodeList_add_node(generatedILOC[functionScope], code, node->value);
};

void cod_generate_arithmetic_invert(comp_tree_t * node){
  // Pegar valores dos registradores da operação que estão no nodo.
  ast_node_t *ast_node = node->value;
  ast_node_t *id = node->first->value;

  // Gerar registrador temporário para o alvo.
  int reg_alvo = cod_generateTempRegister();

  // Gerar instrução
  char *code = malloc(COD_MAX_SIZE);
  snprintf(
    code, COD_MAX_SIZE,
    "multI r%d, -1 => r%d\n",
    id->reg, reg_alvo
  );

  // Salvo registrador temporário de saída
  ast_node->reg = reg_alvo;

  CodeList_add_node(generatedILOC[functionScope], code, ast_node);
};

void cod_generate_if_else(comp_tree_t *tree){
  comp_tree_t *exp = tree->first;
  ast_node_t* ast_exp = exp->value;
  

  char* L1 = cod_generateLabelName(cod_generateLabel());
  char* L2 = cod_generateLabelName(cod_generateLabel());

  char* code = malloc(COD_MAX_SIZE);

  snprintf(
    code, COD_MAX_SIZE,
    "cbr r%d => %s,%s \n",
    ast_exp->reg, L1,L2
  );
  
  

  CodeList_add_node(generatedILOC[functionScope], code, tree->value);
};

void cod_generate_return(comp_tree_t* node) {
  // Retornar registrador temporário da expressão para o nodo de retorno.
  comp_tree_t* expression = node->first;
  ast_node_t* ast_return = expression->value;

  ast_node_t* returnNode = node->value;
  returnNode->reg = ast_return->reg;
}

void cod_generate_chamadafuncao(comp_tree_t* node) {
  ast_node_t* ast_node1 = node->value;
  ast_node_t* ast_node2 = node->first->value;

}

void cod_generate_funcao(symbol* s) {
  functionScope++;
  s->label = cod_generateLabel();

  char* str = malloc(COD_LABEL_LENGTH);
  snprintf(str, COD_LABEL_LENGTH, "L%d: ", s->label);
  CodeList_add(generatedILOC[functionScope], str);
}

int find_main_label() {
  // char* entry = dict_concat_key(data->value.s, data->type);
  // symbol* table_data = dict_get(symbol_table, "main$6");
  // if(table_data == NULL) {
    // printf("null");
  // }

  dict_debug_print(symbol_table);
  
  return 0;
}