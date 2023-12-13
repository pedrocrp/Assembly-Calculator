section .text
    global subtracao

; Função de Subtração
; Argumentos: Dois números na pilha e um indicador de largura (0 para 16 bits, 1 para 32 bits)
; Retorna: Resultado da subtração em EAX
subtracao:
    push ebp
    mov ebp, esp

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
    jmp end_function         ; Pula para o final da função

subtracao_32bits:
    ; Realiza a subtração de 32 bits
    mov eax, [ebp+12] ; Argumento 1
    mov ebx, [ebp+16] ; Argumento 2
    sub eax, ebx      ; Subtrai EBX de EAX

end_function:
    pop ebp                  ; Restaura o valor antigo de ebp
    ret                      ; Retorna para o endereço no topo da pilha
