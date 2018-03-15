#ifndef __MISC_H
#define __MISC_H
#include <stdio.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdint.h>
#include "parser.h"
#include "cc_dict.h"

int getLineNumber (void);
void yyerror (char const *mensagem);
void main_init (int argc, char **argv);
void main_finalize (void);
void insert_stable(int token);
#endif
