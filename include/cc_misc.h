#ifndef __MISC_H
#define __MISC_H
#include <string.h>
#include <stdint.h>
#include "parser.h"
#include "cc_dict.h"

union tValue {
  int i;
  float f;
  char c;
  char* s;
};

typedef struct {
  size_t line;
  size_t type;
  union tValue value;
} symbol;

typedef struct {
  symbol *array;
  size_t used;
  size_t size;
} symbolArray;

int getLineNumber (void);
void yyerror (char const *mensagem);
void main_init (int argc, char **argv);
void main_finalize (void);
void insert_symbol_table(int token);
#endif
