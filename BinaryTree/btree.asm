%include "lib.inc"

%define nullptr 0

;---------------------------+
;            BTree          |
;---------------------------+
struc BTree
    .root: resq 1
endstruc
BTreeSize: equ 8
;----------------------------


;---------------------------+
;            Node           |
;---------------------------+
struc Node
    .data:  resq 1
    .left:  resq 1
    .right: resq 1
endstruc
NodeSize: equ 24
;----------------------------


section .text
    global _start


;-----------------------------------------------------
; BTree* CreateTree(void);
;-----------------------------------------------------
CreateTree:
    mov rdi, BTreeSize
    call memory_alloc
    mov qword[rax + BTree.root], nullptr
    ret
;-----------------------------------------------------
; RAX -> Endereço da arvore
;-----------------------------------------------------


;-----------------------------------------------------
; Node* CreateNode(void);
;-----------------------------------------------------
CreateNode:
    mov rdi, NodeSize
    call memory_alloc
    mov qword[rax + Node.left], nullptr
    mov qword[rax + Node.right], nullptr
    ret
;-----------------------------------------------------
; RAX -> Endereço do nó
;-----------------------------------------------------


;-----------------------------------------------------
; void insert(BTree*, int64_t)
; RDI -> Endereço da arvore
; RSI -> Dado a ser inserido
;-----------------------------------------------------
insert:
    push rdi
    push rsi

    call CreateNode

    pop rsi
    mov [rax + Node.data], rsi

    pop rdi
    cmp qword[rdi + BTree.root], nullptr
    jnz .notnull

        mov [rdi + BTree.root], rax
        ret

    .notnull:
    mov r8, [rdi + BTree.root] ;Current
    mov r9, nullptr            ;Parent

    .loop:
    cmp r8, nullptr
    jz .end

        mov r9, r8
        cmp rsi, [r8 + Node.data]
        je .equal
        jg .dataMaior
        mov r8, [r8 + Node.left]
        jmp .loop
        .dataMaior:
        mov r8, [r8 + Node.right]

        jmp .loop

    .end:
    cmp rsi, [r9 + Node.data]
    jg .maior
    mov [r9 + Node.left], rax
    ret
    .maior:
    mov [r9 + Node.right], rax
    ret

    .equal:
    mov rdi, rax
    call free_memory
    ret
;-----------------------------------------------------


;-----------------------------------------------------
; void insert2(BTree*, int64_t)
; RDI -> Endereço da arvore
; RSI -> Dado a ser inserido
;-----------------------------------------------------
insert2:
    mov rax, [rdi]

    .loop:
    cmp rax, nullptr
    jz .fim
        
        cmp qword[rax + Node.data], rsi
        ja .maior
        jb .menor

        ret

        .maior:
        lea rdi, [rax + Node.right]
        jmp .continue
        
        .menor:
        lea rdi, [rax + Node.left]
        jmp .continue

        .continue:
        mov rax, [rdi]
        jmp .loop

    .fim:
    push rdi
    push rsi
    call CreateNode
    pop rsi
    pop rdi

    mov [rax + Node.data], rsi
    
    mov [rdi], rax
    ret
    

;-----------------------------------------------------
; void em_ordem(Node*);
; RDI -> Endereço da raiz 
;-----------------------------------------------------
em_ordem:
    cmp rdi, nullptr
    jz .end

        push rdi
        mov rdi, [rdi + Node.left]
        call em_ordem
    
        pop rdi
        push rdi
    
        mov rdi, [rdi + Node.data]
        call print_int
    
        mov rdi, 0x20
        call print_char

        pop rdi
        mov rdi, [rdi + Node.right]
        call em_ordem

    .end:
    ret
;-----------------------------------------------------


;-----------------------------------------------------
_start:
    mov rbp, rsp
    sub rsp, 8
    call CreateTree

    mov [rbp - 8], rax

    mov rdi, [rbp - 8]
    lea rdi, [rdi + BTree.root]
    mov rsi, 3
    call insert2
    mov rdi, [rbp - 8]
    lea rdi, [rdi + BTree.root]
    mov rsi, 3
    call insert2
    mov rdi, [rbp - 8]
    lea rdi, [rdi + BTree.root]
    mov rsi, 5
    call insert2
    mov rdi, [rbp - 8]
    lea rdi, [rdi + BTree.root]
    mov rsi, 4
    call insert2

    mov rdi, [rbp - 8]
    mov rdi, [rdi + BTree.root]
    call em_ordem
  

    mov rax, 60
    xor rdi, rdi
    syscall
;-----------------------------------------------------




