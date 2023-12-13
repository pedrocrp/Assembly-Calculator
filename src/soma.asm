section .text
    global soma

; Função de Soma
; Argumentos: Dois números na pilha e um indicador de largura (0 para 16 bits, 1 para 32 bits)
; Retorna: Resultado da soma em EAX
soma:
    push ebp
    mov ebp, esp

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
    jmp end_function          ; Pula para o final da função

soma_32bits:
    ; Realiza a soma de 32 bits
    mov eax, [ebp+12] ; Argumento 1
    mov ebx, [ebp+16] ; Argumento 2
    add eax, ebx

end_function:
    pop ebp                  ; Restaura o valor antigo de ebp
    ret                      ; Retorna para o endereço no topo da pilha