#include "cc_misc.h"

extern int yylineno;
extern char *yytext;

comp_dict_t *symbol_table;
intArray symbol_data;

void initArray(intArray *a) {
  a->array = (int*) malloc(INIT_ARRAYSIZE * sizeof(int));
  a->used = 0;
  a->size = INIT_ARRAYSIZE;
}

int insertArray(intArray *a, int element) {
  if (a->used == a->size) {
    a->size *= 2;
    a->array = (int *) realloc(a->array, a->size * sizeof(int));
  }
  a->array[a->used++] = element;

  // index of inserted element
  return a->used - 1;
}

void freeArray(intArray *a) {
  free(a->array);
  a->array = NULL;
  a->used = a->size = 0;
}

int comp_get_line_number (void)
{
  return yylineno;
}

void insert_symbol_table(int token) {
  char *lexeme = strdup(yytext);
  size_t dataIndex;

  // Caso char ou string, remover aspas da string.
  if(token == TK_LIT_CHAR || token == TK_LIT_STRING) {
    memmove(lexeme, lexeme + 1, strlen(lexeme)); //Remove o primeiro caracter ' ou "
    lexeme[strlen(lexeme) - 1] = '\0'; //Remove o último caracter ' ou "
  }

  // Remoção e reinserção
  int* found = dict_get(symbol_table, lexeme);
  if(found) {
    // Atualizar valor para valor da última linha onde lexema é encontrado
    *found = yylineno;
  } else {
    // Lexema não encontrado, inserindo no array de dados
    dataIndex = insertArray(&symbol_data, yylineno);
    dict_put(symbol_table, lexeme, &symbol_data.array[dataIndex]);
  }
  free(lexeme);
}

void yyerror (char const *mensagem)
{
 fprintf (stderr, "%s. L: %d.\n", mensagem, comp_get_line_number());
}

void main_init (int argc, char **argv)
{
  // Rotinas de inicialização do programa
  symbol_table = dict_new();
  initArray(&symbol_data);
}

void main_finalize (void)
{
  // Rotinas de encerramento do programa
  freeArray(&symbol_data);
}

void comp_print_table (void)
{
  int i, table_size;
  for (i = 0, table_size = symbol_table->size; i < table_size; ++i) {
    if (symbol_table->data[i]) {
      char* key = symbol_table->data[i]->key;
      int* value = symbol_table->data[i]->value;

      cc_dict_etapa_1_print_entrada (key, *value);
    }
  }
}
