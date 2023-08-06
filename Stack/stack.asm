;---------------------------------+
;    CREATED BY: Lincoln Dias     |
;    ------------------------     |
;                                 |
;    Dynamic Stack in Assembly    |
;---------------------------------+

default rel

%include "lib.inc"

%define nullptr 0


;---------------------------------+
;               NODE              |
;---------------------------------+
struc Node
    .data: resq 1
    .next: resq 1
    .prev: resq 1
endstruc
NodeSize: equ 24
;----------------------------------


;---------------------------------+
;          DYNAMIC STACK          |
;---------------------------------+
struc Stack
    .head: resq 1
    .tail: resq 1
endstruc
StackSize: equ 16
;----------------------------------


;------------------------------------------------+
;  USED TO REPORT THAT STACK IS NOT EXECUTABLE   |
;------------------------------------------------+
section .note.GNU-stack noalloc noexec nowrite progbits
;-------------------------------------------------


;------------------------------------------------+
;             START OF TEXT SECTION              |         
;------------------------------------------------+
section .text
;-------------------------------------------------


;------------------------------------------------+
;               EXPORTING SYMBOLS                |
;------------------------------------------------+
    global createStack
    global createNode
    global deleteStack
    global push
    global peek
    global pop
;-------------------------------------------------


;-------------------------------------------------
; DynamicStack* createStack();
;-------------------------------------------------
createStack:
    mov rdi, StackSize                      ;      
    call memmory_alloc                      ; Stack* new_stack = memmory_alloc(StackSize);

    mov qword[rax + Stack.head], nullptr    ; new_stack->head = nullptr;
    mov qword[rax + Stack.tail], nullptr    ; new_stack->tail = nullptr;

    ret                                     ; return new_stack;
;-------------------------------------------------
; RAX -> Endereço da pilha dinamica
;-------------------------------------------------


;-------------------------------------------------
; Node* createNode(int64_t);
;-------------------------------------------------
; RDI -> Data
;-------------------------------------------------
createNode:
    push rdi                                ; // Save data on stack      
    mov rdi, NodeSize                       ; // RDI = NodeSize
    call memmory_alloc                      ; Node* new_node = memmory_alloc(NodeSize);

    pop rdi                                 ; // Recover data from stack
    mov qword[rax + Node.data], rdi         ; new_node->data = data; // RDI is the data
    mov qword[rax + Node.next], nullptr     ; new_node->next = nullptr;
    mov qword[rax + Node.prev], nullptr     ; new_node->prev = nullptr;

    ret                                     ; return new_node;
;-------------------------------------------------
; RAX -> Endereço do novo nó criado
;-------------------------------------------------


;-------------------------------------------------
; void deleteStack(Stack*);
;-------------------------------------------------
; RDI -> Endereço da pilha dinamica
;-------------------------------------------------
deleteStack:
    push rdi                                ; // Save stack* address on stack
    mov rax, [rdi + Stack.head]             ; Node* temp = stack->head; // RAX is the temp node*

    .loop:                                  ; while (temp != nullptr)
    cmp rax, nullptr                        ; {
    je .end                                 ;
                                            ;
        push qword[rax + Node.next]         ;     // Save temp->next address on stack
                                            ;
        mov rdi, rax                        ;     
        mov rsi, NodeSize                   ;
        call free_memmory                   ;     free(temp);
                                            ;
        pop rax                             ;     // Recover temp->next from stack
        jmp .loop                           ; }

    .end:
    pop rdi                                 ; // Recover stack* address from stack
    mov rsi, StackSize                      ; 
    call free_memmory                       ; free(stack);

    ret                                     ; return;
;-------------------------------------------------


;-------------------------------------------------
; void push(Stack*, int64_t);
;-------------------------------------------------
; RDI -> Endereço da pilha dinamica
; RSI -> Data
;-------------------------------------------------
push:
    push rdi                                ; // Save stack* address on stack      

    mov rdi, rsi                            ; // RDI is now the data
    call createNode                         ; Node* new_node = createNode(data);

    pop rdi                                 ; // Recover to RDI the stack* address
    mov rcx, [rdi + Stack.tail]             ; // RCX is now the stack->tail

    mov qword[rax + Node.next], nullptr     ; new_node->next = nullptr;
    mov qword[rax + Node.prev], rcx         ; new_node->prev = stack->tail;

    cmp qword[rdi + Stack.head], nullptr    ; if (stack->head != nullptr)
    jnz .notEmpty                           ; {
                                            ;
    mov [rdi + Stack.head], rax             ;     stack->head = new_node;
    jmp .end                                ; }
                                            ;
    .notEmpty:                              ; else {
    mov [rcx + Node.next], rax              ;     stack->tail->next = new_node;
                                            ; }
    .end:                                   
    mov [rdi + Stack.tail], rax             ; stack->tail = new_node; 
    ret                                     ; return;
;-------------------------------------------------
; RAX -> Dado do topo da pilha
;-------------------------------------------------


;-------------------------------------------------
; int64_t peek(Stack*);
;-------------------------------------------------
; RDI -> Endereço da pilha dinamica
;-------------------------------------------------
peek:
    cmp qword[rdi + Stack.head], nullptr    ; if (stack->head == nullptr)      
    jne .notEmpty                           ; {
                                            ;
        mov rax, 60                         ;
        mov rdi, 1                          ;
        syscall                             ;     exit(1)
                                            ; }
    .notEmpty:                              
    mov rdi, [rdi + Stack.tail]             ; // RDI is now the stack->tail
    mov rax, [rdi + Node.data]              ; // RAX is the stack->tail->data
    ret                                     ; return data; // RAX
;-------------------------------------------------
; RAX -> Dado do topo da pilha
;-------------------------------------------------


;-------------------------------------------------
; int64_t pop(Stack*);
;-------------------------------------------------
; RDI -> Endereço da pilha dinamica
;-------------------------------------------------
pop:
    cmp qword[rdi + Stack.head], nullptr     ; if (stack->head == nullptr)      
    jnz .notEmpty                            ; {
                                             ;
        mov rax, 60                          ;
        mov rdi, 1                           ;     exit(1);
        syscall                              ; }
    
    .notEmpty:
    mov rsi, [rdi + Stack.tail]              ; // RSI now is stack->tail
    mov rax, [rsi + Node.data]               ; // RAX now is stack->tail->data

    cmp [rdi + Stack.head], rsi              ; if (stack->head == stack->tail)
    jne .notOne                              ; {
                                             ;
        mov qword[rdi + Stack.head], nullptr ;     stack->head = nullptr;
        mov qword[rdi + Stack.tail], nullptr ;     stack->tail = nullptr;
        jmp .end                             ; }
                                             ; else
    .notOne:                                 ; {
        mov rcx, [rdi + Stack.tail]          ;     // RCX is now the stack->tail
        mov rcx, [rcx + Node.prev]           ;     // RCX is now the stack->tail->prev
        mov qword[rcx + Node.next], nullptr  ;     stack->tail->prev = nullptr;
                                             ;
        mov [rdi + Stack.tail], rcx          ;     stack->tail = stack->tail->prev;
                                             ; }
    .end:
    push rax                                 ; // Save RAX (data) on stack
    mov rdi, rsi                             ; 
    mov rsi, NodeSize                        ; 
    call free_memmory                        ; free(stack->tail);
    pop rax                                  ; // Recover data to RAX register ---+
    ret                                      ; return data; <---------------------+
;-------------------------------------------------
