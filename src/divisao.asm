section .data
    msg_arg1 db "Dividendo: ", 0
    tam_msg_arg1 EQU $-msg_arg1

    msg_arg2 db "Divisor: ", 0
    tam_msg_arg2 EQU $-msg_arg2

section .text
    global divisao
    extern scanf_16
    extern scanf_32
    extern string_para_int
    extern printf
    extern mostra_resultado

; Função de Divisao
; Argumentos: indicador de precisao (0 para 16 bits, 1 para 32 bits)
; Retorna: Resultado da divisao em EAX
%define precisao [ebp+8]
%define aux [ebp-4]
%define arg1 [ebp-8]
%define arg2 [ebp-12]
divisao:
    enter 12,0

    pusha

    ; Verifica a precisao dos operandos
    movzx ecx, byte precisao  ; Indicador de precisao (0 ou 1)
    cmp ecx, 0
    je divisao_16bits
    jmp divisao_32bits

divisao_16bits:

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

    mov ax, word arg1    ; Dividendo 
    mov dx, word 0 
    mov bx, word arg2      ; Divisor
    idiv bx         ; ax = ax/bx, dx = ax % bx

    jmp end_function_16   

divisao_32bits:
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

    mov eax, dword arg1        ; Dividendo
    mov edx, 0          
    mov ebx, dword arg2          ; Divisor
    idiv ebx            ; eax = eax/ebx, edx = eax % ebx
    
    jmp end_function_32   

end_function_16:
    mov aux, ax
    popa
    movzx ax, aux

    push eax
    call mostra_resultado
    leave
    ret 4           

end_function_32:
    mov aux, eax
    popa
    mov eax, aux

    push eax
    call mostra_resultado
    leave
    ret 4 
    