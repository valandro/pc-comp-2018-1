#include "cc_misc.h"

comp_dict_t *symbol_table;
extern int yylineno;
extern char *yytext;

int comp_get_line_number (void)
{
  return yylineno;
}

void insert_symbol_table(int token){
  int line_number = (intptr_t) yylineno;
  char *lexeme = strdup(yytext);

  // Caso char ou string, remover aspas da string.
  if(token == TK_LIT_CHAR || token == TK_LIT_STRING) {
    memmove(lexeme, lexeme + 1, strlen(lexeme)); //Remove o primeiro caracter ' ou "
    lexeme[strlen(lexeme) - 1] = '\0'; //Remove o último caracter ' ou "
  }

  // Remoção e reinserção
  // TODO: Está utilizando ponteiro para dados como valor. Utilizar uma estrutura separada para armazenar dados.
  dict_remove(symbol_table, lexeme);
  dict_put(symbol_table, lexeme, (void*)(intptr_t) line_number);

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
}

void main_finalize (void)
{
  // Rotinas de encerramento do programa
  free(symbol_table);
}

void comp_print_table (void)
{
  int i, l;
  for (i = 0, l = symbol_table->size; i < l; ++i) {
    if (symbol_table->data[i]) {
      // TODO: Está utilizando ponteiro para dados como valor. Utilizar uma estrutura separada para armazenar os dados.
      cc_dict_etapa_1_print_entrada (symbol_table->data[i]->key, (int)(intptr_t) symbol_table->data[i]->value);
    }
  }
}
