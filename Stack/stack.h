#ifndef STACK_H
#define STACK_H

#include <stdint.h>

typedef struct node
{
    int64_t data;
    struct node* next;
    struct node* prev;
} Node;


typedef struct stack
{
    Node* head;
    Node* tail;
} Stack;

#ifdef __cplusplus
extern "C"
{
#endif // __cplusplus

Stack* createStack(void);

Node* createNode(int64_t data);

void deleteStack(Stack* stack);

void push(Stack* stack, int64_t data);

int64_t peek(Stack* stack);

int64_t pop(Stack* stack);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // STACK_H
