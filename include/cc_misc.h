#ifndef __MISC_H
#define __MISC_H

#include <string.h>
#include <stdint.h>
#include <stdbool.h>

union tValue {
  int i;
  float f;
  bool b;
  char c;
  char* s;
};

typedef struct {
  size_t line;
  size_t type;
  size_t iks_type;
  size_t vector_size;
  union tValue value;
} symbol;

typedef struct {
  symbol* array;
  size_t used;
  size_t size;
} symbolArray;

typedef struct ast_node
{
  int type;
  union
  {
    symbol* data;
  } value;
} ast_node_t;

#include "parser.h"
#include "cc_dict.h"

int getLineNumber (void);
void yyerror (char const *mensagem);
void main_init (int argc, char **argv);
void main_finalize (void);
symbol* insert_symbol_table(int token, int type);
void declare_var(comp_dict_t* table, symbol* ident, int type, int vector_size);
#endif
