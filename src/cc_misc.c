#include "cc_misc.h"

comp_dict_t *dict;
extern int yylineno;
extern char *yytext;

int comp_get_line_number (void)
{
  return yylineno;
}
void insert_stable(int token){
  int line_number = (intptr_t)yylineno;
  char *lexeme = strdup(yytext);

  if(token == TK_LIT_CHAR || token == TK_LIT_STRING){
    memmove(lexeme, lexeme+1, strlen(lexeme)); //Remove o primeiro caracter ' ou "
    lexeme[strlen(lexeme) - 1] = '\0'; //Remove o último caracter ' ou "
  }
  dict_remove(dict,lexeme);
  dict_put(dict,lexeme,(void*)(intptr_t)line_number);

  free(lexeme);
}
void yyerror (char const *mensagem)
{
  fprintf (stderr, "%s\n", mensagem); //altere para que apareça a linha
}

void main_init (int argc, char **argv)
{
  //implemente esta função com rotinas de inicialização, se necessário
  dict = dict_new();
}

void main_finalize (void)
{
  //implemente esta função com rotinas de inicialização, se necessário
  free(dict);
}

void comp_print_table (void)
{
  //para cada entrada na tabela de símbolos
  //Etapa 1: chame a função cc_dict_etapa_1_print_entrada
  //implemente esta função
  int i, l;
  for (i = 0, l = dict->size; i < l; ++i) {
    if (dict->data[i]) {
      cc_dict_etapa_1_print_entrada (dict->data[i]->key, (int)(intptr_t)dict->data[i]->value);
    }
  }
}
