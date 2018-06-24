/*
  GAMMA - Lucas Valandro e Francisco Knebel
  UFRGS 2018
*/

#ifndef __CODE_LIST_H
#define __CODE_LIST_H

typedef struct code_list
{
  char* line; 
  struct code_list *next;
} CodeList;

CodeList* CodeList_init();
CodeList* CodeList_add(CodeList* code_list, char* line);
int CodeList_getSize(CodeList* code_list);
void CodeList_print(CodeList* code_list);

#endif