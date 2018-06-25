/*
  GAMMA - Lucas Valandro e Francisco Knebel
  UFRGS 2018
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cc_code_list.h"
#include "cc_misc.h"
#include "cc_tree.h"

CodeList* CodeList_init() {
  CodeList* code_list = (CodeList*) malloc(sizeof(CodeList));

  code_list->line = NULL;
  code_list->next = NULL;

  return code_list;
}

CodeList* CodeList_add(CodeList* code_list, char* line) {
  // Se for o primeiro insert.
  if(code_list->line == NULL) {
    code_list->line = line;

    return code_list;
  }

  // Insere no final da lista.
  CodeList *newLine = (CodeList*) malloc(sizeof(CodeList));
  newLine->line = line;
  newLine->next = NULL;

  CodeList* current = code_list;
  while (current->next != NULL) {
    current = current->next;
  }
  current->next = newLine;

  return code_list;
}

CodeList* CodeList_add_node(CodeList* code_list, char* line, ast_node_t* node) {
  node->code = line;
  return CodeList_add(code_list, line);
}

int CodeList_getSize(CodeList* code_list) {
  int size = 0;

  if(code_list == NULL) {
    return -1;
  }

  if(code_list->line != NULL) {
    size = 1;

    CodeList* current = code_list;
    while (current->next != NULL) {
      size++;
      current = current->next;
    }
  }
  
  return size;
}

void CodeList_print(CodeList* code_list) {
  int index = 1;

  printf("Printing code...\n\n");
  CodeList* previous = NULL;
  CodeList* current = code_list;
  do {
    printf(
      "%d: %s",
      index, current->line
    );

    index++;
    previous = current;
    current = current->next;
  } while (previous->next != NULL);
  printf("\nList over.\n\n");
}



