#ifndef __MISC_H
#define __MISC_H
#include <string.h>
#include <stdint.h>
#include "parser.h"
#include "cc_dict.h"

typedef struct {
  int line;
  int tokenType;
  int tokenValue;
} symbol;

typedef struct {
  struct symbol *array;
  size_t used;
  size_t size;
} symbolArray;

int getLineNumber (void);
void yyerror (char const *mensagem);
void main_init (int argc, char **argv);
void main_finalize (void);
void insert_symbol_table(int token);
#endif
