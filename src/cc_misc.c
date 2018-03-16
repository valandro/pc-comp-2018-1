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

int keyIsChar(char* key) {
  return key[0] == '\'' && key[strlen(key) - 1] == '\'';
}

int keyIsString(char* key) {
  return key[0] == '\"' && key[strlen(key) - 1] == '\"';
}

void comp_print_table (void)
{
  int i, table_size;
  for (i = 0, table_size = symbol_table->size; i < table_size; ++i) {
    if (symbol_table->data[i]) {
      char* temp = strdup(symbol_table->data[i]->key);

      // Caso for um literal de tipo char ou string (iniciado e terminado com aspas), remover aspas.
      if(keyIsChar(temp) || keyIsString(temp)) {
        memmove(temp, temp + 1, strlen(temp)); //Remove o primeiro caracter ' ou "
        temp[strlen(temp) - 1] = '\0'; //Remove o último caracter ' ou "
      }

      // TODO: Está utilizando ponteiro para dados como valor. Utilizar uma estrutura separada para armazenar os dados.
      cc_dict_etapa_1_print_entrada (temp, (int)(intptr_t) symbol_table->data[i]->value);
    }
  }
}
