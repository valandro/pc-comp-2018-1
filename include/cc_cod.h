/* 
  Funções para montagem de código ILOC.

  GAMMA - Francisco Knebel || Lucas Valandro
  UFRGS 2018
*/

#ifndef __MISC_H
#include "cc_misc.h"
#endif

#ifndef __CC_COD_H
#define __CC_COD_H

#define COD_LABEL_LENGTH 10
#define COD_MAX_SIZE 30

unsigned int cod_offsetAndUpdate_global(int size);
unsigned int cod_offsetAndUpdate_local(int size);

unsigned int cod_generateTempRegister();
unsigned int cod_generateLabel();
char* cod_generateLabelName(int index);

int cod_sizeOf(int var_type);

// Funções de geração de código
void cod_generate(comp_tree_t* node);

void cod_generate_arithmetic(comp_tree_t* node, char* op);
void cod_generate_arithmetic_invert(comp_tree_t* node);

#endif