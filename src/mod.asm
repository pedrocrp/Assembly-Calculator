section .data
    msg_arg1 db "Dividendo: ", 0
    tam_msg_arg1 EQU $-msg_arg1

    msg_arg2 db "Divisor: ", 0
    tam_msg_arg2 EQU $-msg_arg2

section .text
    global mod
    extern scanf_16
    extern scanf_32
    extern string_para_int
    extern printf
    extern mostra_resultado

; Função de Módulo
; Argumentos: indicador de precisao (0 para 16 bits, 1 para 32 bits)
; Retorna: Resultado do módulo em EAX
%define precisao [ebp+8]
%define aux [ebp-4]
%define arg1 [ebp-8]
%define arg2 [ebp-12]
mod:
    enter 12,0

    pusha

    ; Verifica a precisao dos operandos
    movzx ecx, byte precisao  ; Indicador de precisao (0 ou 1)
    cmp ecx, 0
    je mod_16bits
    jmp mod_32bits

mod_16bits:

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

mod_32bits:
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
    mov edx, 0                  ; Resto
    mov ebx, dword arg2          ; Divisor
    idiv ebx            ; eax = eax/ebx, edx = eax % ebx
    
    jmp end_function_32   

end_function_16:
    mov aux, dx ;o resultado que queremos está em dx -> a ser colocado em ax
    popa
    movzx ax, aux

    push eax
    call mostra_resultado
    leave
    ret 4           

end_function_32:
    mov aux, edx ;o resultado que queremos está em edx -> a ser colocado em eax
    popa
    mov eax, aux

    push eax
    call mostra_resultado
    leave
    ret 4 
    