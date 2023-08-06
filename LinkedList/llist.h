#ifndef LLIST_H
#define LLIST_H

#include <stdint.h>
#include <stdbool.h>

typedef struct node
{
    int64_t data;
    struct node* next;
    struct node* prev;
} Node;

typedef struct llist
{
    Node* head;
    Node* tail;
    uint64_t size;
} LList;

#ifdef __cplusplus
extern "C"
{
#endif // __cplusplus

LList* createList(void);

Node* createNode(void);

bool isEmpty(LList* list);

void addFirst(LList* list, int64_t data);

void addLast(LList* list, int64_t data);

bool removeList(LList* list, int64_t data);

bool insertList(LList* list, uint64_t index, int64_t data);

void selectionSortList(LList* list);

void printList(LList* list);

void deleteList(LList* list);

bool searchList(LList* list, int64_t data);

int64_t getValue(LList* list, uint64_t index);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // LLIST_H
