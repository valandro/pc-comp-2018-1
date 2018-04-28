#include "cc_tree.h"
#include "cc_misc.h"

comp_tree_t* ast_make_tree(int type, symbol *data)
{
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = type;

  if(data != NULL) {
    node->value.data = data;
  }

  return tree_make_node((void *) node);
}

comp_tree_t* ast_make_binary_node(int type, comp_tree_t *node1, comp_tree_t *node2)
{
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = type;

  return tree_make_binary_node((void *)node, node1, node2);
}

comp_tree_t* ast_make_unary_node(int type, comp_tree_t* node)
{
  ast_node_t *ast_return = malloc(sizeof(ast_node_t));
  ast_return->type = type;
  
  return tree_make_unary_node((void *) ast_return, node);
}
