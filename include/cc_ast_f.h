/* 
  Funções para manipulação de AST.

  GAMMA - Francisco Knebel || Lucas Valandro
  UFRGS 2018
*/

#ifndef CC_TREE_H_
#include "cc_tree.h"
#endif

#ifndef __MISC_H
#include "cc_misc.h"
#endif

#ifndef __CC_AST_FUNCTIONS_H
#define __CC_AST_FUNCTIONS_H

comp_tree_t* ast_make_tree(int type, symbol *data);
comp_tree_t* ast_make_binary_node(int type, comp_tree_t *node1, comp_tree_t *node2);
comp_tree_t* ast_make_ternary_node(int type, comp_tree_t *node1, comp_tree_t *node2, comp_tree_t *node3);
comp_tree_t* ast_make_unary_node(int type, comp_tree_t *node);
comp_tree_t* ast_dec_init(int type, symbol* node1, comp_tree_t* node2);

#endif