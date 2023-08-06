#include <stdio.h>
#include "stack.h"

int main(void)
{
    Stack* pilha = createStack();

    printf("%lld", pop(pilha));

    deleteStack(pilha);

    return 0;
}
