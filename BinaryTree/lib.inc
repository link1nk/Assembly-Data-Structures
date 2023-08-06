;-------FLAGS FOR SYS_OPEN--------
%define O_APPEND 0x1000         
%define O_CREAT  0x40           
%define O_TRUNC  0x200          
%define O_RDWR   0x2            
%define O_WRONLY 0x1            
%define O_RDONLY 0x0            
;---------------------------------


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


;---CONSTANTES SIMBOLICAS CORES---
;--------------ANSI---------------
%define TERMINAL_COLOR_BLACK   30
%define TERMINAL_COLOR_RED     31
%define TERMINAL_COLOR_GREEN   32
%define TERMINAL_COLOR_YELLOW  33
%define TERMINAL_COLOR_BLUE    34
%define TERMINAL_COLOR_MAGENTA 35
%define TERMINAL_COLOR_CYAN    36
%define TERMINAL_COLOR_WHITE   37
%define TERMINAL_COLOR_DEFAULT 39
%define TERMINAL_COLOR_RESET   0
;---------------------------------
;---------- 256 COLORS -----------
%define COLOR_GREEN 1
%define COLOR_RED   2
;---------------------------------


global exit
global string_length
global print_string
global print_char
global print_uint
global print_int
global print_newline
global get_file_size
global open_file
global fposition
global write_file
global rewind_file
global memory_alloc
global free_memory
global get_argc_argv
global argv_index
global string_equals
global set_terminal_color
global parse_uint
global print_hex
global read_file
global string_hex
global clear_buffer


struc STAT
    .st_dev         resq 1
    .st_ino         resq 1
    .st_nlink       resq 1
    .st_mode        resd 1
    .st_uid         resd 1
    .st_gid         resd 1
    .pad0           resb 4
    .st_rdev        resq 1
    .st_size        resq 1
    .st_blksize     resq 1
    .st_blocks      resq 1
    .st_atime       resq 1
    .st_atime_nsec  resq 1
    .st_mtime       resq 1
    .st_mtime_nsec  resq 1
    .st_ctime       resq 1
    .st_ctime_nsec  resq 1
endstruc

segment .bss
    stat resb 144
    argc resq 1
    argv resq 1

segment .data
    hex_values    db "0123456789abcdef", 0
    hex_prefix    db "0x", 0

    color_black   db 0x1b, "[1;30m", 0
    color_red     db 0x1b, "[1;31m", 0
    color_green   db 0x1b, "[1;32m", 0
    color_yellow  db 0x1b, "[1;33m", 0
    color_blue    db 0x1b, "[1;34m", 0
    color_magenta db 0x1b, "[1;35m", 0
    color_cyan    db 0x1b, "[1;36m", 0
    color_white   db 0x1b, "[1;37m", 0
    color_default db 0x1b, "[1;39m", 0
    color_reset   db 0x1b, "[0m", 0

    color_green_256 db 0x1b, "[38;5;46m", 0
    color_red_256   db 0x1b, "[38;5;196m", 0

segment .text

;void exit(int);
;RDI -> exit_code
exit:
    mov rax, 60
    syscall


;int string_length(char *);
;RDI -> ponteiro para string
string_length:
    xor rax, rax
    .loop:
    cmp byte[rdi + rax], 0
    je .end
    inc rax
    jmp .loop
    .end:
    ret
;RAX -> valor de retorno contendo o tamanho da string


;void print_string(char *)
;RDI -> ponteiro para uma string
print_string:
    call string_length
    mov rdx, rax
    mov rsi, rdi
    mov rdi, 1
    mov rax, 1
    syscall
    ret

;void print_char(unsigned char);
;RDI -> codigo do caracter (ascii) a ser impresso
print_char:
    push rdi
    mov rdi, rsp
    call print_string
    add rsp, 8
    ret


;void print_newline();
print_newline:
    mov rdi, 10
    jmp print_char


;void print_uint(uint64_t);
;RDI -> numero unsigned a ser printado na tela
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


;void print_int(int64_t);
;RDI -> numero a ser impresso
print_int:
    test rdi, rdi
    jns print_uint
    push rdi
    mov rdi, '-'
    call print_char
    pop rdi
    neg rdi
    jmp print_uint


;int get_file_size(char *);
;RDI -> file_path 
get_file_size:
    mov rax, 4
    mov rsi, stat
    syscall

    mov eax, [stat + STAT.st_size]
    ret
;RAX -> tamanho do arquivo


;void open_file(char *);
;RDI -> ponteiro para o nome do arquivo file_path
;RSI -> permissao
open_file:
    mov rax, 2
    mov rdx, 0
    syscall
    ret
;RAX -> retorna o File Descriptor


;void fposition(int, int);
;RDI -> File Descriptor
;RSI -> offset
fposition:
    mov rax, 8
    mov rdx, 0
    syscall
    ret


;void write_file(int, char *, int);
;RDI -> File Descriptor
;RSI -> Ponteiro para string
;RDX -> quantos bytes escrever
write_file:
    mov rax, 1
    syscall
    ret


;void file_close(int);
;RDI -> File Descriptor
file_close:
    mov rax, 2
    syscall
    ret


;void rewind_file(int);
;RDI -> File Descriptor
rewind_file:
    mov rsi, 0
    jmp fposition


;void read_file(int, int, int);
;RDI -> File Descriptor
;RSI -> Endereço a ser mapeado
;RDX -> Quantos bytes mapear
read_file:
    mov rax, 0
    syscall
    ret

;void *memory_alloc(int);
;RDI -> Tamanho da memoria a ser alocada
memory_alloc:
    mov rsi, rdi
    mov rax, 9
    mov rdi, 0
    mov rdx, PROT_WRITE | PROT_READ
    mov r10, MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1
    mov r9, 0
    syscall
    ret
;RAX -> ponteiro para a memoria alocada

;void free_memory(int *, size_t);
;RDI -> ponteiro para memoria a ser liberada
;RSI -> tamanho da memoria a ser liberada
free_memory:
    mov rax, 11
    syscall
    ret


;int get_argc(void);
;char **get_argv(void);
get_argc_argv:
    mov rdi, [rsp+8]
    lea rsi, [rsp+16]
    mov [argc], rdi
    mov [argv], rsi
    ret
;RDI -> valor de argc
;RSI -> **argv
;Valores de retorno de argc e argv em RDI RSI por causa da SYSV ABI


;int *argv(int);
;RDI -> numero do argv
argv_index:
    mov rax, rdi
    mov r8, 8
    xor rdx, rdx
    mul r8

    add rax, [argv]
    mov rax, [rax]
    ret
;RAX -> ponteiro para o argv escolhido


;int string_equals(char *, char*);
;RDI -> endereço da primeira string
;RSI -> endereço da segunda string
string_equals:
    xor rcx, rcx
    .loop:
    mov r9b, [rdi + rcx]
    cmp r9b, [rsi + rcx]
    jne .not_equal
    inc rcx
    test r9b, r9b
    jnz .loop
    mov rax, 1
    ret
    .not_equal:
    xor rax, rax
    ret
;RAX = 0 se as strings forem iguais
;RAX = 1 se as strings forem diferentes


;void set_terminal_color(char);
;RDI -> codigo ANSI da cor
set_terminal_color:
    mov rax, color_green_256
    cmp rdi, 1
    je .set_color

    mov rax, color_red_256
    cmp rdi, 2
    je .set_color

    mov rax, color_black
    cmp rdi, 30
    je .set_color

    mov rax, color_red
    cmp rdi, 31
    je .set_color

    mov rax, color_green
    cmp rdi, 32
    je .set_color

    mov rax, color_yellow
    cmp rdi, 33
    je .set_color

    mov rax, color_blue
    cmp rdi, 34
    je .set_color

    mov rax, color_magenta
    cmp rdi, 35
    je .set_color

    mov rax, color_cyan
    cmp rdi, 36
    je .set_color

    mov rax, color_white
    cmp rdi, 37
    je .set_color

    mov rax, color_default
    cmp rdi, 39
    je .set_color

    mov rax, color_reset
    cmp rdi, 0
    je .set_color
    
    mov rax, 1
    ret

    .set_color:
    mov rdi, rax
    jmp print_string
;RAX -> codigo de erro 1 em RAX caso opção de cor invalida


;int parse_uint(char *);
;RDI -> string a ser convertida para inteiro
parse_uint:
    xor rax, rax
    mov r8, 10
    .loop:
    movzx rsi, byte[rdi]
    test rsi, rsi
    jz .end
    cmp rsi, '0'
    jb .end
    cmp rsi, '9'
    ja .end
    inc rdi
    xor rdx, rdx
    mul r8
    sub rsi, 0x30
    add rax, rsi
    jmp .loop
    .end:
    ret
;RAX -> retorna o numero convertido de string para int


;void print_hex(int);
;RDI -> numero em decimal a ser printado como hexadecimal
print_hex:
    mov rax, rdi
    mov r8, 16
    xor rcx, rcx
    test rax, rax
    jz .showZeroEnd
    .loop:
    test rax, rax
    jz .end
    xor rdx, rdx
    div r8
    
    mov rdi, hex_values
    add rdi, rdx
    movzx rdi, byte[rdi]
    push rdi
    inc rcx
    jmp .loop
    
    .end:
    push rcx
    mov rdi, hex_prefix
    call print_string
    pop rcx
    .endLoop:
    pop rdi
    push rcx
    call print_char
    pop rcx
    loop .endLoop
    ret

    .showZeroEnd:
    mov rdi, hex_prefix
    call print_string
    mov rdi, '0'
    call print_char
    ret

;int string_hex(char *)
;RDI -> recebe uma "string hexadecimal" para ser convertida em hexadecimal
string_hex:
    xor rax, rax
    mov r8, 16

    cmp byte[rdi], '0'
    jne .whileLoop
    cmp byte[rdi+1], 'x'
    jne .whileLoop
    add rdi, 2

    .whileLoop:
    cmp byte[rdi], '0'
    jb .nextCMP
    cmp byte[rdi], '9'
    ja .nextCMP

    .codeInsideWhile:
    xor rdx, rdx
    mul r8
        cmp byte[rdi], '0'
	jb .else
	cmp byte[rdi], '9'
	ja .else
	    push rdi
	    movzx rdi, byte[rdi]
            add rax, rdi
	    pop rdi
	    sub rax, 0x30
	    inc rdi
	    jmp .whileLoop

	.else:
	push rdi
	movzx rdi, byte[rdi]
	add rax, rdi
	pop rdi
	sub rax, 0x57
	inc rdi
	jmp .whileLoop

    .nextCMP:
    cmp byte[rdi], 'a'
    jb .end
    cmp byte[rdi], 'f'
    ja .end
    jmp .codeInsideWhile

    .end:
    ret
;RAX -> hex value ("0x4fA" -> 4fa)


;void clear_buffer(char *, int);
;RDI -> ponteiro para o buffer
;RSI -> tamanho do buffer
clear_buffer:
    mov rax, rsi
    mov r8, 4
    xor rdx, rdx
    div r8
    mov rcx, rax
    xor rax, rax
    rep stosd
    ret






