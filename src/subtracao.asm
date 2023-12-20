section .data
    msg_arg1 db "Argumento 1: ", 0
    tam_msg_arg1 EQU $-msg_arg1

    msg_arg2 db "Argumento 2: ", 0
    tam_msg_arg2 EQU $-msg_arg2

section .text
    global subtracao
    extern scanf_16
    extern scanf_32
    extern string_para_int
    extern printf

; Função de Subtração
; Argumentos: indicador de precisao (0 para 16 bits, 1 para 32 bits)
; Retorna: Resultado da subtração em EAX
%define precisao [ebp+8]
%define aux [ebp-4]
%define arg1 [ebp-8]
%define arg2 [ebp-12]
subtracao:
    enter 12,0

    pusha

    ; Verifica a precisao dos operandos
    movzx ecx, byte precisao  ; Indicador de precisao (0 ou 1)
    cmp ecx, 0
    je subtracao_16bits
    jmp subtracao_32bits

subtracao_16bits:
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

    ; Subtração de 16 bits com números assinados
    movsx eax, word arg1 ; Argumento 1
    movsx ebx, word arg2 ; Argumento 2
    sub ax, bx           ; AX - BX
    jmp end_function_16   

subtracao_32bits:
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

    ; Realiza a subtração de 32 bits
    mov eax, arg1 ; Argumento 1
    mov ebx, arg2 ; Argumento 2
    sub eax, ebx      ; EAX - EBX
    jmp end_function_32  

end_function_16:
    mov aux, ax
    popa
    movzx ax, aux
    leave
    ret 12  

end_function_32:
    mov aux, eax
    popa
    mov eax, aux
    leave
    ret 12   
