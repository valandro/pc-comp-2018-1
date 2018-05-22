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
  for(size_t i = 0; i < a->used; i++) {
    if(a->array[i].type == TK_LIT_STRING || a->array[i].type == TK_IDENTIFICADOR) {
      // Liberando string duplicada caso atribuída no símbolo.
      free(a->array[i].value.s);
    }
  }

  free(a->array);
  a->array = NULL;
  a->used = a->size = 0;
}

int comp_get_line_number (void)
{
  return yylineno;
}

symbol* insert_symbol_table(int token, int type) {
  char *lexeme = strdup(yytext);
  char *entry = strdup(yytext);
  size_t i;
  // Caso char ou string, remover aspas da string.
  if(token == TK_LIT_CHAR || token == TK_LIT_STRING) {
    memmove(lexeme, lexeme + 1, strlen(lexeme)); //Remove o primeiro caracter ' ou "
    lexeme[strlen(lexeme) - 1] = '\0'; //Remove o último caracter ' ou "
  }
  // Cast do tipo do token de int para char.
  int int_value = type;
  char c[10];
  sprintf(c, "%d", int_value);
  // Combinando valor da lexema com tipo do token, com $ como separador
  strcat(entry, "$");
  strcat(entry, c);
  
  // Procurar o token na tabela de símbolos.
  // Se encontrado, atualiza o valor da última linha encontra.
  // Se não, insere na tabela.
  symbol* foundEntry = dict_get(symbol_table, entry);
  if(foundEntry) {
    // Atualizar valor para valor da última linha onde lexema é encontrado
    (*foundEntry).line = yylineno;
  } else {
    // Lexema não encontrado, inserindo elemento no array de dados
    symbol element;
    element.line = yylineno;
    element.iks_type = IKS_NOT_SET_VALUE; // O tipo da variavél ainda não foi setado.
    element.vector_size = IKS_NON_VECTOR ;

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
      case TK_LIT_TRUE:
        element.type = POA_LIT_BOOL;
        element.value.b = true;
        break;
      case TK_LIT_FALSE:
        element.type = POA_LIT_BOOL;
        element.value.b = false;
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
  
    i = insertArray(&symbol_data, element);
    foundEntry = &symbol_data.array[i];
    dict_put(symbol_table, entry, foundEntry);
  }
  free(lexeme);
  free(entry);

  // Retorna ponteiro na tabela de símbolos para a entrada.
  return foundEntry;
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
      symbol* entry;

      comp_dict_item_t* item = symbol_table->data[i];
      while(item) {
        key = item->key;
        entry = item->value;

        cc_dict_etapa_2_print_entrada(key, entry->line, entry->type);
        item = item->next;
      }
    }
  }
}
void declare_var(comp_dict_t* table, symbol* ident, int type, int vector_size){
  char* entry = dict_concat_key(ident->value.s,ident->type);
  symbol* value = dict_get(table,entry);
  if(value != NULL){
    if(value->iks_type == IKS_NOT_SET_VALUE){
      value->iks_type = type;
      value->vector_size = vector_size;
    } else {
      exit(IKS_ERROR_DECLARED);
    }
  }
  printf("%d\n",value->iks_type);
  printf("%d\n",value->vector_size);  
}
