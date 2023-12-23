section .data
    msg_arg1 db "Argumento 1: ", 0
    tam_msg_arg1 EQU $-msg_arg1

    msg_arg2 db "Argumento 2: ", 0
    tam_msg_arg2 EQU $-msg_arg2

    msg_overflow db "Ocorreu overflow!", 0dH, 0ah
    tam_msg_overflow EQU $-msg_overflow

section .text
    global multiplicacao
    extern scanf_16
    extern scanf_32
    extern string_para_int
    extern printf
    extern mostra_resultado

; Função de Multiplicacao
; Argumentos: indicador de precisao (0 para 16 bits, 1 para 32 bits)
; Retorna: Resultado da multiplicacao em EAX
%define precisao [ebp+8]
%define aux [ebp-4]
%define arg1 [ebp-8]
%define arg2 [ebp-12]
multiplicacao:
    enter 12,0

    pusha

    mov esi, precisao ;aqui é [ebp+8], que é o endereço da precisao

    ; Verifica a precisao dos operandos
    movzx ecx, byte [esi]  ; Indicador de precisao (0 ou 1)
    ;aqui é o [esi], que é o conteúdo do endereço precisao
    
    cmp ecx, 0
    je multiplicacao_16bits
    jmp multiplicacao_32bits

multiplicacao_16bits:

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

    mov dx, word 0

    ; Realiza a soma de 16 bits
    movzx eax, word arg1 ; Argumento 1
    movzx ebx, word arg2 ; Argumento 2
    imul ax, bx
    jmp end_function_16   

multiplicacao_32bits:
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

    mov edx, 0

    ; Realiza a soma de 32 bits
    mov eax, arg1 ; Argumento 1
    mov ebx, arg2 ; Argumento 2
    imul eax, ebx
    jmp end_function_32   

end_function_16:
    cmp dx, 0hFFFF
    jne overflow_16

alarme_falso_16:
    mov aux, dword 0
    mov aux, ax
    popa
    movzx eax, word aux

    push eax
    call mostra_resultado
    leave
    ret 4 

overflow_16:
    cmp dx, 0h0000
    je alarme_falso_16

    push tam_msg_overflow
    push msg_overflow
    call printf

    leave
    ret 4                

end_function_32:
    cmp edx, 0hFFFFFFFF
    jne overflow_32

alarme_falso_32:
    mov aux, eax
    popa
    mov eax, aux

    push eax
    call mostra_resultado
    leave
    ret 4 

overflow_32:
    cmp edx, 0
    je alarme_falso_32

    push tam_msg_overflow
    push msg_overflow
    call printf

    leave
    ret 4       