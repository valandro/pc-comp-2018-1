#include "cc_misc.h"

extern int yylineno;
extern char *yytext;

comp_dict_t *symbol_table;
symbolArray symbol_data;

void initArray(symbolArray *a) {
  a->array = (symbol*) malloc(DICT_SIZE * sizeof(symbol));
  a->used = 0;
  a->size = DICT_SIZE;
}

int insertArray(symbolArray *a, symbol element) {
  if (a->used == a->size) {
    a->size *= 2;
    a->array = (symbol *) realloc(a->array, a->size * sizeof(symbol));
  }
  a->array[a->used++] = element;

  // index of inserted element
  return a->used - 1;
}

void freeArray(symbolArray *a) {
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

  // Caso char ou string, remover aspas da string.
  if(token == TK_LIT_CHAR || token == TK_LIT_STRING) {
    memmove(lexeme, lexeme + 1, strlen(lexeme)); //Remove o primeiro caracter ' ou "
    lexeme[strlen(lexeme) - 1] = '\0'; //Remove o último caracter ' ou "
  }

  // Procurar o token na tabela de símbolos.
  // Se encontrado, atualiza o valor da última linha encontra.
  // Se não, insere na tabela.
  symbol* found = dict_get(symbol_table, lexeme);
  if(found) {
    // Atualizar valor para valor da última linha onde lexema é encontrado
    (*found).line = yylineno;
  } else {
    // Lexema não encontrado, inserindo elemento no array de dados

    // TODO: inserir valores dos tokens
    symbol element;
    element.line = yylineno;

    switch (token) {
      case TK_LIT_INT:
        element.type = POA_LIT_INT;
        element.value.i = atoi(lexeme);
        break;
      case TK_LIT_FLOAT:
        element.type = POA_LIT_FLOAT;
        element.value.f = atof(lexeme);
        break;
      case TK_LIT_CHAR:
        element.type = POA_LIT_CHAR;
        element.value.c = (char) lexeme[0];
        break;
      case TK_LIT_STRING:
        element.type = POA_LIT_STRING;
        element.value.s = strdup(lexeme);
        break;
      case TK_IDENTIFICADOR:
        element.type = POA_IDENT;
        element.value.s = strdup(lexeme);
        break;
      default:
        // No default behavior defined.
        break;
    }

    size_t i = insertArray(&symbol_data, element);
    dict_put(symbol_table, lexeme, &symbol_data.array[i]);
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

int clearDictEntries(comp_dict_t* dict) {
  int i, finished = 1;
  for (i = 0; i < dict->size && finished; i++) {
    if (dict->data[i]) {
      dict_remove(dict, dict->data[i]->key);
    }
  }
  return dict->occupation;
}

void clearDict(comp_dict_t* dict) {
  // Liberar entradas da tabela de símbolos
  int occupation;
  do {
    // Existiam linhas na tabela com múltiplas entradas,
    // logo é necessário reiniciar o processo para eliminar as entradas restantes.
    occupation = clearDictEntries(dict);
  } while (occupation > 0);

  // Liberar dicionário da tabela de símbolos
  dict_free(symbol_table);
}

void main_finalize (void)
{
  // Rotinas de encerramento do programa

  // Liberar array de dados da tabela de símbolos
  freeArray(&symbol_data);

  // Liberar a tabela de símbolos
  clearDict(symbol_table);
}

void comp_print_table (void)
{
  int i, table_size = symbol_table->size;
  for (i = 0; i < table_size; ++i) {
    if (symbol_table->data[i]) {
      char* key;
      int* value;

      comp_dict_item_t* item = symbol_table->data[i];
      while(item) {
        key = item->key;
        value = item->value;

        cc_dict_etapa_1_print_entrada(key, *value);
        item = item->next;
      }
    }
  }
}
