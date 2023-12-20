section .data
    msg_arg1 db "Argumento 1: ", 0
    tam_msg_arg1 EQU $-msg_arg1

    msg_arg2 db "Argumento 2: ", 0
    tam_msg_arg2 EQU $-msg_arg2

section .text
    global soma
    extern scanf_16
    extern scanf_32
    extern string_para_int
    extern printf

; Função de Soma
; Argumentos: indicador de precisao (0 para 16 bits, 1 para 32 bits)
; Retorna: Resultado da soma em EAX
%define precisao [ebp+8]
%define aux [ebp-4]
%define arg1 [ebp-8]
%define arg2 [ebp-12]
soma:
    enter 12,0

    pusha

    ; Verifica a precisao dos operandos
    movzx ecx, byte precisao  ; Indicador de precisao (0 ou 1)
    cmp ecx, 0
    je soma_16bits
    jmp soma_32bits

soma_16bits:

    push tam_msg_arg1
    push msg_arg1
    call printf

    call scanf_16
    mov arg1, ax

    push tam_msg_arg2
    push msg_arg2
    call printf

    call scanf_16
    mov arg2, ax

    ; Realiza a soma de 16 bits
    movzx eax, word arg1 ; Argumento 1
    movzx ebx, word arg2 ; Argumento 2
    add ax, bx
    jmp end_function_16   

soma_32bits:
    push tam_msg_arg1
    push msg_arg1
    call printf

    call scanf_32
    mov arg1, eax

    push tam_msg_arg2
    push msg_arg2
    call printf

    call scanf_32
    mov arg2, eax

    ; Realiza a soma de 32 bits
    mov eax, arg1 ; Argumento 1
    mov ebx, arg2 ; Argumento 2
    add eax, ebx
    jmp end_function_32   

end_function_16:
    mov aux, ax
    popa
    movzx ax, aux
    leave
    ret 4                

end_function_32:
    mov aux, eax
    popa
    mov eax, aux
    leave
    ret 4        