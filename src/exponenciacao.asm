section .data
    msg_explicacao db "Assuma que será feito Base ^ Expoente", 0dH, 0ah
    tam_msg_explicacao EQU $-msg_explicacao

    msg_arg1 db "Base: ", 0
    tam_msg_arg1 EQU $-msg_arg1

    msg_arg2 db "Expoente: ", 0
    tam_msg_arg2 EQU $-msg_arg2

    msg_overflow db "Ocorreu overflow!", 0dH, 0ah
    tam_msg_overflow EQU $-msg_overflow

section .text
    global exponenciacao
    extern scanf_16
    extern scanf_32
    extern string_para_int
    extern printf
    extern mostra_resultado

; Função de Exponenciacao
; Argumentos: indicador de precisao (0 para 16 bits, 1 para 32 bits)
; Retorna: Resultado da exponenciacao em EAX
%define precisao [ebp+8]
%define aux [ebp-4]
%define base [ebp-8]
%define expoente [ebp-12]
exponenciacao:
    enter 12,0

    pusha

    push tam_msg_explicacao
    push msg_explicacao
    call printf

    mov esi, precisao ;aqui é [ebp+8], que é o endereço da precisao

    ; Verifica a precisao dos operandos
    movzx ecx, byte [esi]  ; Indicador de precisao (0 ou 1)
    ;aqui é o [esi], que é o conteúdo do endereço precisao
    
    cmp ecx, 0
    je exponenciacao_16bits
    jmp exponenciacao_32bits

exponenciacao_16bits:

    push tam_msg_arg1
    push msg_arg1
    call printf

    call scanf_16
    mov base, word ax

    push tam_msg_arg2
    push msg_arg2
    call printf

    call scanf_16
    mov expoente, word ax

    mov dx, word 0

    movzx ecx, word expoente
    dec ecx
    movzx eax, word base ; Argumento 1
    movzx ebx, word base ; Argumento 2

repete_16:
    imul ax, bx
    dec cx
    jnz repete_16
    jmp end_function_16   

exponenciacao_32bits:
    push tam_msg_arg1
    push msg_arg1
    call printf

    call scanf_32
    mov base, eax

    push tam_msg_arg2
    push msg_arg2
    call printf

    call scanf_32
    mov expoente, eax

    mov edx, 0

    mov ecx, expoente
    dec ecx
    mov eax, base ; Argumento 1
    mov ebx, base ; Argumento 2

repete_32:
    imul eax, ebx
    loop repete_32
    jmp end_function_32   

end_function_16:
    cmp dx, 0hFFFF
    jne overflow_16

alarme_falso_16:
    mov aux, ax
    popa
    movzx ax, aux

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