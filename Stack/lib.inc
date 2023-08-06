;------FLAGS FOR SYS_MMAP---------
%define PROT_EXEC  0x4          
%define PROT_READ  0x1          
%define PROT_WRITE 0x2          
%define PROT_NONE  0x0          

%define MAP_SHARED    0x1       
%define MAP_PRIVATE   0x2       
%define MAP_ANONYMOUS 0x20       
%define MAP_FIXED     0x10      
;---------------------------------


;----------------------------------------------------
global memmory_alloc
global free_memmory
global string_length
global print_string
global print_char
global print_uint
global print_int
;----------------------------------------------------


segment .text


;----------------------------------------------------
;void* memmory_alloc(size_t);
;----------------------------------------------------
;RDI -> Tamanho da memoria a ser alocada
;----------------------------------------------------
memmory_alloc:
    mov rsi, rdi
    mov rax, 9
    mov rdi, 0
    mov rdx, PROT_WRITE | PROT_READ
    mov r10, MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1
    mov r9, 0
    syscall
    ret
;----------------------------------------------------
;RAX -> ponteiro para a memoria alocada
;----------------------------------------------------


;----------------------------------------------------
;void free_memmory(int *, size_t);
;----------------------------------------------------
;RDI -> ponteiro para memoria a ser liberada
;RSI -> tamanho da memoria a ser liberada
;----------------------------------------------------
free_memmory:
    mov rax, 11
    syscall
    ret
;----------------------------------------------------


;----------------------------------------------------
;int string_length(char *);
;----------------------------------------------------
;RDI -> ponteiro para string
;----------------------------------------------------
string_length:
    xor rax, rax
    .loop:
    cmp byte[rdi + rax], 0
    je .end
    inc rax
    jmp .loop
    .end:
    ret
;----------------------------------------------------
;RAX -> valor de retorno contendo o tamanho da string
;----------------------------------------------------


;----------------------------------------------------
;void print_string(char *)
;----------------------------------------------------
;RDI -> ponteiro para uma string
;----------------------------------------------------
print_string:
    call string_length
    mov rdx, rax
    mov rsi, rdi
    mov rdi, 1
    mov rax, 1
    syscall
    ret
;----------------------------------------------------


;----------------------------------------------------
;void print_char(unsigned char);
;----------------------------------------------------
;RDI -> codigo do caractere ascii a ser impresso
;----------------------------------------------------
print_char:
    push rdi
    mov rdi, rsp
    call print_string
    add rsp, 8
    ret
;----------------------------------------------------


;----------------------------------------------------
;void print_uint(uint64_t);
;----------------------------------------------------
;RDI -> numero unsigned a ser printado na tela
;----------------------------------------------------
print_uint:
    mov rax, rdi
    mov rdi, rsp
    push 0
    sub rsp, 16
    mov r8, 10
    dec rdi

    .loop:
    xor rdx, rdx
    div r8
    add rdx, 0x30
    dec rdi
    mov [rdi], dl
    test rax, rax
    jnz .loop

    call print_string
    add rsp, 24
    ret
;----------------------------------------------------


;----------------------------------------------------
;void print_int(int64_t);
;----------------------------------------------------
;RDI -> numero a ser impresso
;----------------------------------------------------
print_int:
    test rdi, rdi
    jns print_uint
    push rdi
    mov rdi, '-'
    call print_char
    pop rdi
    neg rdi
    jmp print_uint
;----------------------------------------------------
