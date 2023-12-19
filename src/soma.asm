section .text
    global soma

; Função de Soma
; Argumentos: Dois números na pilha e um indicador de largura (0 para 16 bits, 1 para 32 bits)
; Retorna: Resultado da soma em EAX
%define aux [ebp-4]
soma:
    enter 4,0

    pusha

    ; Verifica a largura dos operandos
    movzx ecx, byte [ebp+8]  ; Indicador de largura (0 ou 1)
    cmp ecx, 0
    je soma_16bits
    jmp soma_32bits

soma_16bits:
    ; Realiza a soma de 16 bits
    movzx eax, word [ebp+12] ; Argumento 1
    movzx ebx, word [ebp+16] ; Argumento 2
    add ax, bx
    jmp end_function_16          ; Pula para o final da função

soma_32bits:
    ; Realiza a soma de 32 bits
    mov eax, [ebp+12] ; Argumento 1
    mov ebx, [ebp+16] ; Argumento 2
    add eax, ebx
    jmp end_function_32          ; Pula para o final da função

end_function_16:
    mov aux, ax
    popa
    movzx ax, aux
    leave
    ret                      ; Retorna para o endereço no topo da pilha

end_function_32:
    mov aux, eax
    popa
    mov eax, aux
    leave
    ret                      ; Retorna para o endereço no topo da pilha