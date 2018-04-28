#include "cc_tree.h"
#include "cc_misc.h"

comp_tree_t* ast_make_binary_node(int type, comp_tree_t *node1, comp_tree_t *node2)
{
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = type;

  return tree_make_binary_node((void *) node, node1, node2);
}