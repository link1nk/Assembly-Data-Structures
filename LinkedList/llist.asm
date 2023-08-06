;---------------------------------+
;    CREATED BY: Lincoln Dias     |
;    ------------------------     |
;                                 |
; Doubly Linked List in Assembly  |
;---------------------------------+


BITS 64

default rel

%include "lib.inc"

%define nullptr 0


;---------------------------------+
;              NODE               |
;---------------------------------+
struc Node
    .data: resq 1
    .next: resq 1
    .prev: resq 1
endstruc
NodeSize: equ 24
;----------------------------------


;---------------------------------+
;          LINKED LIST            |
;---------------------------------+
struc LList
    .head: resq 1
    .tail: resq 1    
    .size: resq 1
endstruc
LListSize: equ 24
;----------------------------------


;------------------------------------------------+
;  USED TO REPORT THAT STACK IS NOT EXECUTABLE   |
;------------------------------------------------+
section .note.GNU-stack
;-------------------------------------------------


;------------------------------------------------+
;             START OF TEXT SECTION              |
;------------------------------------------------+
section .text
;-------------------------------------------------


;------------------------------------------------+
;               EXPORTING SYMBOLS                |
;------------------------------------------------+
    global createList
    global createNode
    global isEmpty
    global addFirst
    global addLast
    global removeList
    global insertList
    global selectionSortList
    global printList
    global deleteList
    global searchList
    global getValue
;-------------------------------------------------


;-------------------------------------------------
; LList* createList(void);
;-------------------------------------------------
createList:                  
    mov rdi, LListSize                      ; //LListSize = how many bytes to alloc a list       
    call memmory_alloc                      ; LList* list = memmory_alloc(LListSize);
    mov qword[rax + LList.size], 0          ; list->size = 0;
    mov qword[rax + LList.head], nullptr    ; list->head = nullptr;
    mov qword[rax + LList.tail], nullptr    ; llist->tail = nullptr;
    ret                                     ; return list;
;-------------------------------------------------
; RAX -> Endereço da lista
;-------------------------------------------------


;-------------------------------------------------
; Node* createNode(void);
;-------------------------------------------------
createNode:
    mov rdi, NodeSize                       ; //NodeSize = how many bytes to alloc a node
    call memmory_alloc                      ; new_node = memmory_alloc(NodeSize);

    mov qword[rax + Node.next], nullptr     ; new_node->next = nullptr;
    mov qword[rax + Node.prev], nullptr     ; new_node->prev = nullptr;

    ret                                     ; return new_node;
;-------------------------------------------------
; RAX -> Endereço do Nó
;-------------------------------------------------


;-------------------------------------------------
; bool IsEmpty(LList*);
;-------------------------------------------------
; RDI -> Endereço da lista
;-------------------------------------------------
isEmpty:
    cmp qword[rdi + LList.size], 0          ; if (list->size == 0)      
    jz .empty                               ;
    xor rax, rax                            ;
    ret                                     ; then return false;
    .empty:                                 ;
    mov rax, 1                              ;
    ret                                     ; else return true;
;-------------------------------------------------
; RAX -> 0: Lista com elementos | 1: Lista vazia
;-------------------------------------------------


;-------------------------------------------------
; void addFirst(LList*, int data);
;-------------------------------------------------
; RDI -> Endereço da Linked List
; RSI -> Dado a ser inserido 
;-------------------------------------------------
addFirst:
    push rdi                                ; // RDI is the *list*
    push rsi                                ; // RSI is the *data to insert*
    call createNode                         ; Node* new_node = createNode(); // RAX is the *new_node*

    ; Configura o novo nó criado
    pop rsi
    mov qword[rax + Node.data], rsi         ; new_node->data = RSI;
            
    pop rdi 
    mov rcx, [rdi + LList.head]             ; // RCX = list->head;
    mov qword[rax + Node.next], rcx         ; new_node->next = list->head;
    mov qword[rax + Node.prev], nullptr     ; new_node->prev = nullptr;

    ; Checa se a lista está vazia
    cmp dword[rdi + LList.size], 0          ; if (list->size == 0)
    jnz .notEmpty                           ;
                                            ;
    mov [rdi + LList.tail], rax             ; then list->tail = new_node;
    jmp .end                                ;
                                            ;
    .notEmpty:                              ;
    mov [rcx + Node.prev], rax              ; else list->head->prev = new_node;

    .end:
    inc qword[rdi + LList.size]             ; list->size++; // Incrementa o tamanho da lista
    mov [rdi + LList.head], rax             ; list->head = new_node;
    ret
;-------------------------------------------------


;-------------------------------------------------
; void addLast(LList*, int data);
;-------------------------------------------------
; RDI -> Endereço da Linked List
; RSI -> Dado a ser inserido 
;-------------------------------------------------
addLast:
    push rdi                                ; // RDI is the *list*
    push rsi                                ; // RSI is the *data to insert*
    call createNode                         ; Node* new_node = createNode(); // RAX is the *new_node*

    ; Configura o novo nó criado
    pop rsi
    mov qword[rax + Node.data], rsi         ; new_node->data = RSI;

    pop rdi
    mov rcx, [rdi + LList.tail]             ; // RCX = list->tail;
    mov qword[rax + Node.next], nullptr     ; new_node->next = nullptr;
    mov qword[rax + Node.prev], rcx         ; new_node->prev = list->tail;

    cmp qword[rdi + LList.size], 0          ; if (list->size == 0)
    jnz .notEmpty                           ;
                                            ;
    mov [rdi + LList.head], rax             ; then list->head = new_node;
    jmp .end                                ;
                                            ;
    .notEmpty:                              ;
    mov [rcx + Node.next], rax              ; else list->tail->next = new_node;

    .end:
    inc qword[rdi + LList.size]             ; list->size++;
    mov [rdi + LList.tail], rax             ; list->tail = new_node;
    ret
;-------------------------------------------------


;-------------------------------------------------
; bool removeList(LList*, int64_t data);
;-------------------------------------------------
; RDI -> Endereço da lista
; RSI -> Dado a ser removido 
;-------------------------------------------------
removeList:
    cmp qword[rdi + LList.size], 0          ; if (list->size == 0)
    jnz .listNotEmpty

        xor rax, rax                        ;
        ret                                 ; then return false

    .listNotEmpty:
    mov rax, [rdi + LList.head]             ; // RAX = list->head;
                                            ;
    mov rcx, [rdi + LList.head]             ; // RCX = list->head;
    mov rcx, [rcx + Node.data]              ; // RCX = list->head->data;
                                            ;
    cmp rcx, rsi                            ; if (list->head->data == data)
    jne .FindNode                           ;
                                            ; then {
        mov rcx, [rdi + LList.head]         ;     
        mov rcx, [rcx + Node.next]         

        mov [rdi + LList.head], rcx

        cmp qword[rdi + LList.size], 1
        jne .MoreThanOneNode 

            mov qword[rdi + LList.tail], nullptr
            jmp .return

        .MoreThanOneNode:
            
            mov rcx, [rdi + LList.head]
            mov qword[rcx + Node.prev], nullptr

        .return:
        dec qword[rdi + LList.size]
        mov rdi, rax
        mov rsi, NodeSize
        call free_memmory
        mov rax, 1
        ret

    .FindNode:
    cmp rax, nullptr
    jz .checkNull
    cmp qword[rax + Node.data], rsi
    je .checkNull

        mov rax, [rax + Node.next]
        jmp .FindNode

    .checkNull:
    cmp rax, nullptr
    jnz .remove

        xor rax, rax
        ret

    .remove:
    mov rcx, [rax + Node.next]
    mov rdx, [rax + Node.prev]
    mov [rdx + Node.next], rcx

    cmp rax, [rdi + LList.tail]
    jne .IsNotInTail
        
        mov rcx, [rax + Node.prev]
        mov [rdi + LList.tail], rcx
        jmp .end

    .IsNotInTail:
    
        mov rcx, [rax + Node.prev]
        mov rdx, [rax + Node.next]
        mov [rdx + Node.prev], rcx
    
    .end:
    dec qword[rdi + LList.size]
    mov rdi, rax
    mov rsi, NodeSize
    call free_memmory
    mov rax, 1
    ret
;-------------------------------------------------
; RAX -> 0: Dado nao existe | 1: Dado removido
;-------------------------------------------------


;-------------------------------------------------
; bool insertList(LList*, int, int64_t);
;-------------------------------------------------
; RDI -> Endereço da lista
; RSI -> Indice
; RDX -> Dado a ser inserido
;-------------------------------------------------
insertList:
    cmp qword[rdi + LList.size], rsi        ; if (list->size <= indice) // indice: RSI      
    ja .nextCheck                           ;
                                            ;
        xor rax, rax                        ; 
        ret                                 ; then return false;
                                           
    .nextCheck:                            
    cmp rsi, 0                              ; if (indice == 0) // if indice is in head
    jnz .insert                             ;
                                            ; 
        mov rsi, rdx                        ; then {
        call addFirst                       ;     addFirst(list, rdx); // RDX = Data to insert
        mov rax, 1                          ;     return true;
        ret                                 ; }

    .insert:                              
    mov rax, [rdi + LList.head]             ; Node* temp_node = list->head; // RAX = temp_node

    xor rcx, rcx                            ; 
    .loop:                                  ; for (int rcx=0; rcx < indice; rcx++)
    cmp rcx, rsi                            ; {
    je .end                                 ;
        mov rax, [rax + Node.next]          ;     temp_node = temp_node->next;
        inc rcx                             ; 
        jmp .loop                           ; }

    .end:
    push rdi                                ; // Save list pointer on stack
    push rdx                                ; // Save data to insert on stack
    push rax                                ; // Save temp_node on stack

    call createNode                         ; Node* new_node = createNode(); // RAX = new_node

    pop r8                                  ; // Get to r8 register *temp_node* from stack 

    pop rdx                                 ; // Get to rdx register *data to insert* from stack
    mov [rax + Node.data], rdx              ; new_node = rdx; // RDX = *data to insert*
    
    mov rcx, [r8 + Node.prev]               ; // RCX = temp_node->prev; // R8 is the *temp_node*
    mov [rax + Node.prev], rcx              ; new_node->prev = temp_node->prev;
    mov [rax + Node.next], r8               ; new_node->next = temp_node;

    mov [rcx + Node.next], rax              ; temp_node->prev->next = new_node; // RCX = temp_node->prev
    mov [r8 + Node.prev], rax               ; temp_node->prev = new_node;

    pop rdi                                 ; // Get to RDI register *list* pointer
    dec qword[rdi + LList.size]             ; list->size--;
    
    mov rax, 1                              ;
    ret                                     ; return true;
;-------------------------------------------------
; RAX -> 0: Index out of range | 1: Dado inserido
;-------------------------------------------------


;-------------------------------------------------
; void selectionSortList(LList*);
;-------------------------------------------------
; RDI -> Endereço da lista a ser ordenada
;-------------------------------------------------
selectionSortList:
    mov r8, [rdi + LList.head]              ; Node* temp = list->head; // R8 is a pointer to head
    
    .mainLoop:                              ; for (Node* i=temp; i != nullptr; i=i->next)
    cmp r8, nullptr                         ; {
    jz .end                                 ; 
                                            ;
        mov r9, r8                          ;     Node* menor = i;
        mov r10, [r8 + Node.next]           ;     for (Node* j=i->next; j != nullptr; j=j->next)
        .secondLoop:                        ;     {
        cmp r10, nullptr                    ;         
        je .swap                            ;         
            mov rax, [r10 + Node.data]      ;        
            cmp [r9 + Node.data], rax       ;         if (menor->data > j->data)
            jle .returnSecondLoop           ;
                                            ;    
                mov r9, r10                 ;         then menor = j;
                                            ;
            .returnSecondLoop:              ;
            mov r10, [r10 + Node.next]      ;     // update SecondFor loop with: j=j->next
            jmp .secondLoop                 ;     }
                                            ;
        .swap:                              ;     if (i != menor)
        cmp r8, r9                          ;     {
        je .returnMainLoop                  ;         
                                            ;
            mov rax, [r9 + Node.data]       ;         int64_t temp_data_menor = menor->data;
            mov rcx, [r8 + Node.data]       ;         int64_t temp_data_i = i->data;
                                            ;
            mov [r9 + Node.data], rcx       ;         menor->data = temp_data_i;
            mov [r8 + Node.data], rax       ;         i->data = temp_data_menor;
                                            ;     }
        .returnMainLoop:                    ;
        mov r8, [r8 + Node.next]            ;     // update MainFor loop with: i=i->next
        jmp .mainLoop                       ; }

    .end:
    ret                                     ; return;
;-------------------------------------------------


;-------------------------------------------------
; void printList(LList*);
;-------------------------------------------------
; RDI -> Endereço da lista a ser impressa
;-------------------------------------------------
printList:
    mov rax, [rdi + LList.head]             ; Node* temp = list->head; // RAX is temp      
    
    .loop:                                  ; while (temp != nullptr)
    cmp rax, nullptr                        ; {
    jz .end                                 ;     
                                            ;
        push qword[rax + Node.next]         ;     // Save the *temp->next* on stack
                                            ;
        mov rdi, [rax + Node.data]          ;     // RDI = temp->data
                                            ;     
        call print_int                      ;     printf("%d", rdi); // RDI is temp->data
                                            ;
        push 0x3e2d ; "->"                  ;     
        mov rdi, rsp                        ;
        call print_string                   ;     printf("->");
        add rsp, 8                          ;
                                            ;
        pop rax                             ;     // Recover from stack *temp->next* into RAX
        jmp .loop                           ; }

    .end:
    push 0x4c4c554e ; "NULL"                ;
    mov rdi, rsp                            ;
    call print_string                       ; printf("NULL");
    add rsp, 8                              ;

    ret                                     ; return;
;-------------------------------------------------


;-------------------------------------------------
; void deleteList(LList*);
;-------------------------------------------------
; RDI -> Endereço da lista
;-------------------------------------------------
deleteList:
    push rdi                                ; // Save list* on stack      
    mov rsi, [rdi + LList.head]             ; Node* temp = list->head;

    .loop:                                  ; while (temp != nullptr)
    cmp rsi, 0                              ; {
    jz .end                                 ;
                                            ;
    mov r8, [rsi + Node.next]               ;     Node* next = temp->next;
                                            ;
    mov rdi, rsi                            ;
    mov rsi, NodeSize                       ;
    call free_memmory                       ;     free(temp);
                                            ;
    mov rsi, r8                             ;     temp = next;
                                            ; 
    jmp .loop                               ; }
                                           
    .end:
    pop rdi                                 ; // Recover list* from stack
    mov rsi, LListSize                      ;
    call free_memmory                       ; free(list);

    ret                                     ; return;
;-------------------------------------------------


;-------------------------------------------------
; bool searchList(LList*, int64);
;-------------------------------------------------
; RDI -> Endereço da lista
; RSI -> Dado a ser procurado
;-------------------------------------------------
searchList:
    mov rax, [rdi + LList.head]             ; Node* temp = list->head; // RAX is the *temp*      

    .loop:                                  ; while (temp != nullptr)
    cmp rax, nullptr                        ; {
    jz .doesntExist                         ;     
                                            ;   
        cmp [rax + Node.data], rsi          ;     if (temp->data == rsi) // RSI is the data we are searching      
                                            ;     
        je .exist                           ;         then return true;  // JE .exist =---+
                                            ;                            //               |
        mov rax, [rax + Node.next]          ;     temp = temp->next;     //               |       
        jmp .loop                           ; }                          //               |
                                            ;                            //               |
    .doesntExist:                           ;                            //               |
    xor rax, rax                            ;                            //               |
    ret                                     ; return false;              //               | 
                                            ;                            //               |
    .exist:                                 ;                            //               |
    mov rax, 1                              ;                            //               |
    ret                                     ; // *return true;* <-------------------------+
;-------------------------------------------------
; RAX -> 0: Não existe | 1: Existe
;-------------------------------------------------


;-------------------------------------------------
; int64_t getValue(LList*, int);
;-------------------------------------------------
; RDI -> Endereço da lista
; RSI -> Indice da lista
;-------------------------------------------------
getValue:
    cmp rsi, [rdi + LList.size]             ; if (index >= list->size)
    jae .indexOutOfRange                    ; then exit(1); // .indexOutOfRange ---+
                                            ;                                //    |
    mov rax, [rdi + LList.head]             ; Node* temp = list->head;       //    |
                                            ;                                //    |
    xor rcx, rcx                            ;                                //    |
    .loop:                                  ; for (int i=0; i < index; i++)  //    |
    cmp rcx, rsi                            ; {                              //    |
    je .end                                 ;                                //    |
                                            ;                                //    |
        mov rax, [rax + Node.next]          ;     temp = temp->next;         //    |
        inc rcx                             ;     // update the For with i++ //    |
                                            ; }                              //    |
    jmp .loop                               ;                                //    |
                                            ;                                //    |
    .indexOutOfRange:
    push 0                       ;                                //    |
    push 0x65676E617220666F
    push 0x2074756F20786564
    push 0x6E4920726F727245

    mov rdi, rsp
    call print_string

    mov rax, 60                             ;                                //    |
    mov rdi, 1                              ;                                //    |
    syscall                                 ; exit(1); // <------------------------+

    .end:                                   ;
    mov rax, [rax + Node.data]              ;
    ret                                     ; return temp->data;

;-------------------------------------------------
; RAX -> Valor do indice
;-------------------------------------------------
