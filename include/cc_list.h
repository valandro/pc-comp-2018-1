#ifndef __LIST_H
#define __LIST_H

typedef struct param_list
{
  char* identificador; 
  int type;
  struct param_list *next;
} ParamList;

ParamList* ParamList_init(int type, char* identificador);
ParamList* ParamList_addParam(ParamList* param_list, int type, char* identificador);
int ParamList_getSize(ParamList* param_list);
void ParamList_debug_print(ParamList* param_list);

#endif