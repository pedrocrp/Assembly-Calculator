section .text
    global subtracao

; Função de Subtração
; Argumentos: Dois números na pilha e um indicador de largura (0 para 16 bits, 1 para 32 bits)
; Retorna: Resultado da subtração em EAX
%define aux [ebp-4]
subtracao:
    enter 4,0

    pusha

    ; Verifica a largura dos operandos
    movzx ecx, byte [ebp+8]  ; Indicador de largura (0 ou 1)
    cmp ecx, 0
    je subtracao_16bits
    jmp subtracao_32bits

subtracao_16bits:
    ; Subtração de 16 bits com números assinados
    movsx eax, word [ebp+12] ; Argumento 1
    movsx ebx, word [ebp+16] ; Argumento 2
    sub ax, bx               ; Subtrai BX de AX
    jmp end_function_16         ; Pula para o final da função

subtracao_32bits:
    ; Realiza a subtração de 32 bits
    mov eax, [ebp+12] ; Argumento 1
    mov ebx, [ebp+16] ; Argumento 2
    sub eax, ebx      ; Subtrai EBX de EAX
    jmp end_function_32         ; Pula para o final da função

end_function_16:
    mov aux, ax
    popa
    movzx ax, aux
    leave
    ret 12                     ; Retorna para o endereço no topo da pilha

end_function_32:
    mov aux, eax
    popa
    mov eax, aux
    leave
    ret 12                     ; Retorna para o endereço no topo da pilha
