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

#ifndef CC_DICT_H_
#define CC_DICT_H_

/*
 * Constante: DICT_SIZE, representa o tamanho de uma tabela de símbolos
 */
#define DICT_SIZE 10240

/*
 * Tipo: comp_dict_item_t, é o tipo de uma entrada na tabela de
 * símbolos. O valor do usuário é registrado no campo _value_, de tipo
 * _void *_. Sendo assim, o usuário pode registrar um ponteiro para
 * qualquer tipo de dados, sendo efetivamente uma entrada genérica. A
 * chave _key_ é o identificador único da entrada. O ponteiro _next_ é
 * utilizado casa exista um conflito na função de hash utilizada.
 */
typedef struct comp_dict_item {
  char *key;
  void *value;
  struct comp_dict_item *next;  // ponteiro de overflow
} comp_dict_item_t;

/*
 * Tipo: comp_dict_t, é o tipo da tabela de símbolos. O campo _size_
 * indica o tamanho total, inicializado para DICT_SIZE e depois não é
 * mais mudado. O campo _occupation_ indica a ocupação atual da
 * tabela, indicando quantos elementos ela contém. O campo _data_ é
 * uma matriz de ponteiros que guarda as entradas.
 */
typedef struct comp_dict {
  int size;
  int occupation;
  comp_dict_item_t **data;
} comp_dict_t;

/* Funções: a seguir segue a lista de funções da API cc_dict */

/*
 * Função: dict_new, cria uma nova tabela de símbolos. Retorna um
 * ponteiro para a nova tabela de símbolos ou aborta a execução do
 * programa caso algum erro de alocação de memória tenha ocorrido.
 */
comp_dict_t *dict_new(void);

/*
 * Função: dict_free, libera a tabela de símbolos alocada previamente
 * com dict_new. Para evitar vazamentos de memória (verifique com
 * valgrind), é importante lembrar que todos as entradas na tabela de
 * símbolos devem ser removidas e liberadas. Caso a ocupação não seja
 * zero, esta função aborta a execução do programa.
 */
void dict_free(comp_dict_t * dict);

/*
 * Função: dict_put, insere uma nova entrada na tabela de
 * símbolos. Recebe três parâmetros: o parâmetro _dict_ é um ponteiro
 * para a tabela de símbolos na qual será inserida a nova entrada
 * (este ponteiro deve ser obrigatoriamente um retornado pela função
 * dict_new); o parâmetro _key_ é a chave da nova entrada na tabela de
 * símbolos; enfim, o parâmetro _value_ é um ponteiro para qualquer
 * tipo ou estrutura de dados, sob responsabilidade do usuário. Esse
 * ponteiro será associado a chave na tabela de símbolos. Caso
 * qualquer um dos parâmetros seja NULL, a função aborta a execução do
 * programa.
 */
void *dict_put(comp_dict_t * dict, char *key, void *value);

/*
 * Função: dict_get, obtém o valor de uma entrada na tabela de
 * símbolos. Recebe dois parâmetros: o parâmetro _dict_ é um ponteiro
 * para a tabela de símbolos da qual será obtida a entrada (este
 * ponteiro deve ser obrigatoriamente um retornado pela função
 * dict_new); o parâmetro _key_ é a chave da entrada na tabela de
 * símbolos. A função retorna um ponteiro que foi informado no momento
 * do dict_put. É normal fazer um cast para o tipo correto
 * imediatamente após essa chamada de função.  Caso qualquer um dos
 * parâmetros seja NULL, a função aborta a execução do programa.
 */
void *dict_get(comp_dict_t * dict, char *key);

/*
 * Função: dict_remove, remove o valor de uma entrada na tabela de
 * símbolos. Recebe dois parâmetros: o parâmetro _dict_ é um ponteiro
 * para a tabela de símbolos da qual será obtida a entrada (este
 * ponteiro deve ser obrigatoriamente um retornado pela função
 * dict_new); o parâmetro _key_ é a chave da entrada na tabela de
 * símbolos que será removida. O valor retorno é o ponteiro que foi
 * informado no momento do dict_put, e deve ser liberado pelo usuário.
 * Caso qualquer um dos parâmetros seja NULL, a função aborta a
 * execução do programa.
 */
void *dict_remove(comp_dict_t * dict, char *key);

/*
 * Função: dict_debug_print, usada somente para visualizar os
 * ponteiros do dict.
 */
void dict_debug_print(comp_dict_t * dict);

#endif                          //CC_DICT_H_
