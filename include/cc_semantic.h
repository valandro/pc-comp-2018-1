#ifndef __SEMANTIC_H
#define __SEMANTIC_H

#define IKS_SUCCESS 0               //caso não houver nenhum tipo de erro

/* Verificação de declarações */
#define IKS_ERROR_UNDECLARED 1      //identificador não declarado
#define IKS_ERROR_DECLARED 2        //identificador já declarado

/* Uso correto de identificadores */
#define IKS_ERROR_VARIABLE 3        //identificador deve ser utilizado como variável
#define IKS_ERROR_VECTOR 4          //identificador deve ser utilizado como vetor
#define IKS_ERROR_FUNCTION 5        //identificador deve ser utilizado como função

/* Argumentos e parâmetros */
#define IKS_ERROR_MISSING_ARGS 9     //faltam argumentos
#define IKS_ERROR_EXCESS_ARGS 10     //sobram argumentos
#define IKS_ERROR_WRONG_TYPE_ARGS 11 //argumentos incompatíveis

#define IKS_NOT_SET_VALUE -1        // iks ainda não foi salvo na tabela

#define IKS_UNDECLARED -1
#define IKS_INT        1
#define IKS_FLOAT      2
#define IKS_CHAR       3
#define IKS_STRING     4
#define IKS_BOOL       5
#define IKS_USER_TYPE  6

#endif