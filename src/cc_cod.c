/*
  GAMMA - Lucas Valandro e Francisco Knebel
  UFRGS 2018
*/

#include <stdio.h>

#include "cc_cod.h"
#include "main.h"

extern CodeList* generatedILOC;
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

  int naoachou = 0;
  // Switch sobre o nodo, para cada uma das estruturas possíveis
  // Em cada caso, chamar função que gera o código para essa estrutura.

  switch (nodeType)
  {
    // case AST_IF_ELSE:
    // case AST_DO_WHILE:
    // case AST_WHILE_DO:
    // case AST_INPUT:
    // case AST_OUTPUT:
    // case AST_RETURN:
    // case AST_BLOCO:

    /* Nodos aritméticos */
    // case AST_ARIM_SOMA:
    //   cod_generate_arithmetic(node, "add");
    //   break;
    // case AST_ARIM_SUBTRACAO:
    //   cod_generate_arithmetic(node, "sub");
    //   break;
    // case AST_ARIM_MULTIPLICACAO:
    //   cod_generate_arithmetic(node, "mult");
    //   break;
    // case AST_ARIM_DIVISAO:
    //   cod_generate_arithmetic(node, "div");
    //   break;
    // case AST_ARIM_INVERSAO:
    //   cod_generate_arithmetic_invert(node);
    //   break;

    // /* Nodos de comparação lógica */
    // case AST_LOGICO_E:
    // case AST_LOGICO_OU:
    // case AST_LOGICO_COMP_DIF:
    // case AST_LOGICO_COMP_IGUAL:
    // case AST_LOGICO_COMP_LE:
    // case AST_LOGICO_COMP_GE:
    // case AST_LOGICO_COMP_L:
    // case AST_LOGICO_COMP_G:
    // case AST_LOGICO_COMP_NEGACAO:
    //   cod_generate_logic(node, type);
    //   break;
    // /* Nodos de varíaveis e valores */
    // case AST_LITERAL:
    // case AST_IDENTIFICADOR:
    /* Nodos de varíaveis e valores */
    case AST_LITERAL: cod_generate_literal(node); break;
    // case AST_VETOR_INDEXADO:
    // case AST_ATRIBUICAO:


    // case AST_CHAMADA_DE_FUNCAO:
    // case AST_SHIFT_RIGHT:
    // case AST_SHIFT_LEFT:
    // case AST_BREAK:
    // case AST_CONTINUE:
    // case AST_CASE:
    // case AST_FOR:
    // case AST_FOREACH:
    // case AST_SWITCH:
    // case AST_TIPO_CAMPO:
    // case AST_PIPE_R1:
    // case AST_PIPE_R2:
    // case AST_DEC_INIT:

    default:
      naoachou = 1;
      break;
  }

  if(naoachou == 1) {
    // FUNÇÃO DE TESTE, REMOVER ANTES DE ENVIAR A ETAPA, APENAS PARA AVISAR CASO ENTRAR EM GENERATE SEM CASE
    printf("__GENERATE CODE: Não achou case para AST tipo %d. Necessário implementar.__\n", nodeType);
  }
}

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
  CodeList_add(generatedILOC, code);
}

/*
  Criação de código para operação aritmética.
  Recebe o nodo e o operador ILOC da operação desejada.
*/
void cod_generate_arithmetic(comp_tree_t* node, char* op) {
  // Pegar valores dos registradores da operação que estão no nodo.
  int reg_1 = 0; // node->...;
  int reg_2 = 0; // node->...;

  // Gerar registrador temporário para o alvo.
  int reg_alvo = cod_generateTempRegister();

  // Gerar instrução
  char* code = malloc(COD_MAX_SIZE);
  snprintf(
    code, COD_MAX_SIZE,
    "%s r%d, r%d => r%d\n",
    op, reg_1, reg_2, reg_alvo
  );

  // Instrução gerada. Salvar na árvore junto com o restante do código gerado.
};

void cod_generate_arithmetic_invert(comp_tree_t* node) {};
