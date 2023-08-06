#include <stdio.h>
#include "llist.h"

int main(void)
{
    LList* list = createList();

    addFirst(list, 1);
    addFirst(list, 3);
    addFirst(list, 5);
    addFirst(list, 4);
    addFirst(list, 9);

    printList(list);

    putchar('\n');

    selectionSortList(list);

    printList(list);

    if (searchList(list, 6))
        printf("\n6 Existe\n");
    else
        printf("\n6 não Existe\n");

    printf("%d", getValue(list, 3));

    deleteList(list);

    return 0;
}
