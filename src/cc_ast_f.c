/*
  GAMMA - Lucas Valandro e Francisco Knebel
  UFRGS 2018
*/
#include "cc_tree.h"
#include "cc_misc.h"
#include "cc_ast.h"

comp_tree_t* ast_make_tree(int type, symbol *data)
{
  ast_node_t *nodeValue = malloc(sizeof(ast_node_t));
  nodeValue->type = type;

  if(data != NULL) {
    nodeValue->value.data = data;
  }

  comp_tree_t* newTree = tree_make_node((void *)nodeValue);
  cod_generate(newTree);

  return newTree;
}

comp_tree_t* ast_make_tree_and_insert(int type, symbol *data, comp_tree_t* insert_node)
{
  ast_node_t *nodeValue = malloc(sizeof(ast_node_t));
  nodeValue->type = type;

  if(data != NULL) {
    nodeValue->value.data = data;
  }

  comp_tree_t* newTree = tree_make_node((void *)nodeValue);
  if (insert_node != NULL) {
    tree_insert_node(newTree, insert_node);
    
    ast_node_t* node = newTree->value;
    node->reg = ast_find_return_node_reg(newTree);
  }
  cod_generate(newTree);

  return newTree;
}

comp_tree_t* ast_make_binary_node(int type, comp_tree_t *node1, comp_tree_t *node2)
{
  ast_node_t *nodeValue = malloc(sizeof(ast_node_t));
  nodeValue->type = type;

  comp_tree_t* newTree = tree_make_binary_node((void *)nodeValue, node1, node2);
  cod_generate(newTree);

  return newTree;
}

comp_tree_t* ast_make_unary_node(int type, comp_tree_t* node)
{
  ast_node_t *nodeValue = malloc(sizeof(ast_node_t));
  nodeValue->type = type;

  comp_tree_t *newTree = tree_make_unary_node((void *)nodeValue, node);
  cod_generate(newTree);

  return newTree;
}

comp_tree_t* ast_make_ternary_node(int type, comp_tree_t *node1, comp_tree_t *node2, comp_tree_t *node3) {
  ast_node_t *nodeValue = malloc(sizeof(ast_node_t));
  nodeValue->type = type;

  comp_tree_t *newTree = tree_make_ternary_node((void *)nodeValue, node1, node2, node3);
  cod_generate(newTree);

  return newTree;
}

comp_tree_t* ast_dec_init(int type, symbol* node1, comp_tree_t* node2){
  comp_tree_t* ident_node = ast_make_tree(type, node1);
  comp_tree_t* dec = NULL;

  if(node2 != NULL){
    dec = ast_make_binary_node(AST_DEC_INIT, ident_node, node2);
    return dec;
  }
  
  return dec;
}

comp_tree_t* comp_t_get_next(comp_tree_t* ptr) {
  if (ptr->first != NULL)
    return ptr->first;
  return ptr->next;
}

int ast_find_return_node_reg(comp_tree_t* node) {
  ast_node_t* ast_node;
  comp_tree_t* next_node = comp_t_get_next(node);
  while(next_node != NULL) {
    ast_node = next_node->value; 
    if(ast_node->type == AST_RETURN) {
      return ast_node->reg;
    }
    next_node = comp_t_get_next(next_node);
  }
}