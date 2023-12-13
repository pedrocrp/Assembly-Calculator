section .data
msg db "Resultado: ", 0
number_format db "%d", 10, 0  ; Formato para imprimir números, seguido de nova linha
buffer db 12 dup(0)           ; Buffer para armazenar a string do número, ajuste o tamanho conforme necessário

section .text
extern soma                   ; Assume que soma está em outro arquivo
extern subtracao              ; Assume que subtracao está em outro arquivo
global _start
global itoa                   ; Torna a função itoa global

_start:
    ; Exemplo de chamada para a função subtração com 32 bits
    push 20                    ; Argumento 2
    push 10                    ; Argumento 1
    push 1                     ; Indicador de largura (32 bits)
    ; call subtracao
    call soma
    add esp, 12                ; Limpa a pilha após a chamada

    ; Converte o resultado em eax para string
    mov edi, buffer            ; Endereço do buffer para armazenar a string
    call itoa                  ; Converte eax para string

    ; Exibe a mensagem
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, 12                ; Tamanho da mensagem "Resultado: "
    int 0x80

    ; Exibe o número convertido
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer            ; Endereço do buffer com o número convertido
    mov edx, 12                ; Tamanho do buffer, ajuste conforme necessário
    int 0x80

    ; Termina o programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Função itoa: Converte um número em eax para uma string ASCII
; Recebe: eax = número, edi = endereço do buffer de saída
; Retorna: nada, mas o buffer em edi terá a string
itoa:
    mov ebx, 10                 ; Divisor para a conversão de base
    mov ecx, edi                ; Ponteiro para o final da string no buffer
    add ecx, 11                 ; Ajustar para o tamanho do buffer
    mov byte [ecx], 0           ; Caractere nulo no final

    ; Verifica se o número é negativo
    test eax, eax
    jge .positive               ; Se não for negativo, pula para a conversão positiva
    neg eax                     ; Negativa o número se for negativo
    mov byte [edi], '-'              ; Coloca sinal de menos no início do buffer
    inc edi                     ; Move o ponteiro do buffer para a frente

    .positive:
    ; Loop para converter o número em string
    .repeat:
        dec ecx                 ; Move para trás no buffer
        xor edx, edx            ; Limpa edx para a divisão
        div ebx                 ; Divide eax por 10, resultado em eax, resto em edx
        add dl, '0'             ; Converte o resto em caractere ASCII
        mov [ecx], dl           ; Armazena o caractere no buffer
        test eax, eax           ; Verifica se eax é zero
        jnz .repeat             ; Se não for, continua o loop

    ; Ajusta o ponteiro do buffer para o início da string
    mov edi, buffer            ; Reseta o ponteiro do buffer para o início
    cmp byte [edi], '-'        ; Verifica se o primeiro caractere é '-'
    je .done                   ; Se for, a string já está correta
    lea edi, [ecx]             ; Se não, ajusta edi para o início da string numérica
    .done:
    ret
