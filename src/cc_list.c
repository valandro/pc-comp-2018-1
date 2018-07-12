/*
  GAMMA - Lucas Valandro e Francisco Knebel
  UFRGS 2018
*/

#include <stdio.h>
#include <stdlib.h>
#include "cc_list.h"
#include "cc_misc.h"
#include <string.h>

ParamList* ParamList_init(int type, char* identificador) {
  ParamList* param_list = (ParamList*) malloc(sizeof(ParamList));

  if(identificador != NULL) {
    param_list->identificador = strdup(identificador);
  } else {
    param_list->identificador = NULL;
  }
  param_list->type = type;
  param_list->next = NULL;

  return param_list;
}

ParamList* ParamList_addParam(ParamList* param_list, int type, char* identificador) {
  ParamList *newItem = (ParamList*) malloc(sizeof(ParamList));

  if(newItem == NULL) { 
    fprintf(stderr, "Unable to allocate memory for new node\n");
    exit(-1);
  }

  if(identificador != NULL) {
    newItem->identificador = strdup(identificador);
  } else {
    newItem->identificador = NULL;
  }
  newItem->type = type;
  newItem->next = NULL;

  ParamList* current = param_list;
  while (current->next != NULL) {
    current = current->next;
  }
  current->next = newItem;

  return param_list;
}

int ParamList_getSize(ParamList* param_list) {
  int size = 1;

  if(param_list == NULL) {
    return -1;
  }

  ParamList* current = param_list;
  while (current->next != NULL) {
    size++;
    current = current->next;
  }
  
  return size;
}

void ParamList_debug_print(ParamList* param_list) {
  int index = 0;

  printf("Printing list.\n");
  ParamList* previous = NULL;
  ParamList* current = param_list;
  do {
    printf("i%d -> type: %d    id: %s     pointer: %p    next: %p\n",
      index, current->type, current->identificador, current, current->next
    );

    index++;
    previous = current;
    current = current->next;
  } while (previous->next != NULL);
  printf("List over.\n\n");
}

ParamList* ParamList_generate(comp_tree_t* tree){
  comp_tree_t* node = tree;
  ast_node_t* ast_node;
  symbol* dict_entry;
  ParamList* list;

  if(node != NULL){
    ast_node = node->value;
    dict_entry = ast_node->value.data;
    list = ParamList_init(dict_entry->iks_type[LOCAL_SCOPE],dict_entry->value.s);  
    node = comp_t_get_next(node);    
  }
  while(node != NULL){
    ast_node = node->value;
    dict_entry = ast_node->value.data;
    list = ParamList_addParam(list,dict_entry->iks_type[LOCAL_SCOPE],dict_entry->value.s);
    node = comp_t_get_next(node);
  }

  return list;
}

