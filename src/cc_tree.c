// Copyright (c) 2016 Lucas Nodari 
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include <stdio.h>
#include <stdlib.h>

#include "cc_tree.h"
#include "cc_misc.h"


extern FILE *intfp;
void *comp_tree_last = NULL;

#define ERRO(MENSAGEM) { fprintf (stderr, "[cc_tree, %s] %s.\n", __FUNCTION__, MENSAGEM); abort(); }

comp_tree_t* tree_new(void){
	comp_tree_t *tree = tree_make_node(NULL);
	return tree;
}

void tree_free(comp_tree_t *tree){
	comp_tree_t *ptr = tree;
	do {
		if (ptr->first != NULL)
			tree_free(ptr->first);
		ptr = ptr->next;
		free(tree);
		tree = ptr;
	} while(ptr != NULL);
}

comp_tree_t* tree_make_node(void *value){
	comp_tree_t *node = malloc(sizeof(comp_tree_t));
	if (!node)
		ERRO("Failed to allocate memory for tree node");

	node->value = value;
	node->childnodes = 0;
	node->first = NULL;
	node->last = NULL;
	node->next = NULL;
	node->prev = NULL;
	return node;
}

void tree_insert_node(comp_tree_t *tree, comp_tree_t *node){
	if (tree == NULL)
		ERRO("Cannot insert node, tree is null");
	if (node == NULL)
		ERRO("Cannot insert node, node is null");

	if (tree_has_child_nodes(tree)){
		tree->first = node;
		tree->last = node;
	} else {
		node->prev = tree->last;
		tree->last->next = node;
		tree->last = node;
	}
	++tree->childnodes;
	
	ast_node_t* tree_ast = (ast_node_t*)(tree->value);
	int type = tree_ast->type;

	if (type == AST_IDENTIFICADOR || type == AST_FUNCAO || type == AST_LITERAL) {
		gv_declare(type, tree, tree_ast->value.data->value.s);
	} else {
		gv_declare(type, tree, NULL);
	}

	ast_node_t* node_ast = (ast_node_t*)(node->value);
	type = node_ast->type;
	
	if (type == AST_IDENTIFICADOR || type == AST_FUNCAO) {
		gv_declare(type, node, node_ast->value.data->value.s);
	} else if(type == AST_LITERAL) {
		switch (node_ast->value.data->type){
			case 1: {
				int Int = node_ast->value.data->value.i;
				char str[12];
				sprintf(str, "%d", Int);
				gv_declare(type, node, str);
				break;
			}
			case 2: {
				float Float = node_ast->value.data->value.f;
				char str[50];
				sprintf(str, "%f", Float);
				gv_declare(type, node, str);
				break;	
			}
			case 5: {
				if(node_ast->value.data->value.b == true){
					gv_declare(type, node, "true");
				} else {
					gv_declare(type, node, "false");					
				}
				break;
			}
			default: break;
		}		
	} else {
		gv_declare(type, node, NULL);
	}
	gv_connect(tree,node);

	comp_tree_last = tree;
}

int tree_has_child_nodes(comp_tree_t *tree){
	if (tree != NULL){
		if (tree->childnodes == 0)
			return 1;
	}
	return 0;
}

comp_tree_t* tree_make_unary_node(void *value, comp_tree_t *node){
	comp_tree_t *newnode = tree_make_node(value);
	tree_insert_node(newnode,node);
	return newnode;
}

comp_tree_t* tree_make_binary_node(void *value, comp_tree_t *node1, comp_tree_t *node2){
	comp_tree_t *newnode = tree_make_node(value);
	tree_insert_node(newnode,node1);
	tree_insert_node(newnode,node2);
	return newnode;
}

comp_tree_t* tree_make_ternary_node(void *value, comp_tree_t *node1, comp_tree_t *node2, comp_tree_t *node3){
	comp_tree_t *newnode = tree_make_node(value);
	tree_insert_node(newnode,node1);
	tree_insert_node(newnode,node2);
	tree_insert_node(newnode,node3);
	return newnode;
}

static void print_spaces(int num){
	while (num-->0)
		putc(' ',stdout);
}

static void tree_debug_print_node(comp_tree_t *tree, int spacing){
	if (tree == NULL) return;
	print_spaces(spacing);
	printf("%p(%d): %p\n",tree,tree->childnodes,tree->value);
}

static void tree_debug_print_s(comp_tree_t *tree, int spacing){
	if (tree == NULL) return;

	comp_tree_t *ptr = tree;
	do {
		tree_debug_print_node(ptr,spacing);
		if (ptr->first != NULL)
			tree_debug_print_s(ptr->first,spacing+1);
		ptr = ptr->next;
	} while(ptr != NULL);
}

void tree_debug_print(comp_tree_t *tree){
	tree_debug_print_s(tree,0);
}
