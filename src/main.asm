section .data
;variaveis globais (no contexto desse arquivo): mensagens de texto
msg_nome db "Bem-vindo. Digite seu nome:", 0dH, 0ah
tam_msg_nome EQU $-msg_nome

msg_boas_vindas_0 db "Hola, ", 0
tam_msg_boas_vindas_0 EQU $-msg_boas_vindas_0
msg_boas_vindas_1 db ", bem-vindo ao programa de CALC IA-32", 0dH, 0ah
tam_msg_boas_vindas_1 EQU $-msg_boas_vindas_1

msg_menu_0 db "ESCOLHA UMA OPCAO:", 0dH, 0ah
tam_msg_menu_0 EQU $-msg_menu_0
msg_menu_1 db "-1: SOMA", 0dH, 0ah
tam_msg_menu_1 EQU $-msg_menu_1
msg_menu_2 db "-2: SUBTRACAO", 0dH, 0ah
tam_msg_menu_2 EQU $-msg_menu_2
msg_menu_3 db "-3: MULTIPLICACAO", 0dH, 0ah
tam_msg_menu_3 EQU $-msg_menu_3
msg_menu_4 db "-4: DIVISAO", 0dH, 0ah
tam_msg_menu_4 EQU $-msg_menu_4
msg_menu_5 db "-5: EXPONENCIACAO", 0dH, 0ah
tam_msg_menu_5 EQU $-msg_menu_5
msg_menu_6 db "-6: MOD", 0dH, 0ah
tam_msg_menu_6 EQU $-msg_menu_6
msg_menu_7 db "-7: SAIR", 0dH, 0ah
tam_msg_menu_7 EQU $-msg_menu_7

msg_precisao db "Vai trabalhar com 16 ou 32 bits (digite 0 para 16, e 1 para 32)", 0dH, 0ah
tam_msg_precisao EQU $-msg_precisao

msg_resultado db "Resultado: ", 0
tam_msg_resultado EQU $-msg_resultado

; ariaveis auxiliares
;number_format db "%d", 10, 0  ; Formato para imprimir números, seguido de nova linha
;buffer db 12 dup(0)           ; Buffer para armazenar a string do número, ajuste o tamanho conforme necessário

section .bss
;variaveis globais (no contexto desse arquivo)
nome resb 50                  ; Assumindo que o nome não passará de 50 bytes
tam_nome resb 4
precisao resb 1
opcao resd 1


section .text
extern soma                   ; Assume que soma está em outro arquivo
extern subtracao              ; Assume que subtracao está em outro arquivo
global _start
global itoa                   ; Torna a função itoa global

%define tam_lido [ebp-4]
%define resultado_eax [ebp-8]
_start:
    enter 8,0
    call boas_vindas

    call pergunta_precisao

    call imprime_menu

    ;obtem a opcao
    push dword 0x04
    push dword opcao
    call scanf_s

    sub byte [opcao], 48        ; Transforma em ASCII
    cmp byte [opcao], 1
    je op_soma
    cmp byte [opcao], 2
    je op_sub

; Termina o programa
Fim:
    leave                       ; Remove as variaveis locais da pilha

    mov eax, 1
    xor ebx, ebx
    int 0x80

op_soma:
    push 20                    ; Argumento 2
    push 10                    ; Argumento 1
    push precisao
    call soma

    call mostra_resultado

    ; Exibe a mensagem
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_boas_vindas_0
    mov edx, tam_msg_boas_vindas_0 ; Tamanho da mensagem "Resultado: "
    int 0x80

    jmp Fim

op_sub:
    push 20                    ; Argumento 2
    push 10                    ; Argumento 1
    push precisao 
    call subtracao
    
    add esp, 9

    call mostra_resultado
    jmp Fim

; Função itoa: Converte um número em eax para uma string ASCII
; Recebe: eax = número, edi = endereço do buffer de saída
; Retorna: nada, mas o buffer em eax terá a string
%define buffer_arg [ebp+12]
%define numero [ebp+8]
itoa:
    push ebp
    mov ebp, esp
    mov edi, buffer_arg

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
    mov eax, buffer_arg        ; Reseta o ponteiro do buffer para o início
    cmp byte [eax], '-'        ; Verifica se o primeiro caractere é '-'
    je .done                   ; Se for, a string já está correta
    lea eax, [ecx]             ; Se não, ajusta eax para o início da string numérica
    .done:
    leave
    ret 8 ;endereco do buffer tem 4 bytes + 4 bytes do número

;Função printf: para saída de dadaos 
;Recebe: ponteiro para string e número de bytes a serem escritos
%define str dword [ebp+8]
%define num_bytes dword [ebp+12]
printf:
    push ebp
    mov ebp, esp

    mov eax, 4
    mov ebx, 1
    mov ecx, str
    mov edx, num_bytes
    int 0x80

    leave
    ret 8               ;ja desempilha os dois parametros str e num_bytes

;Função scanf_s: para leitura de string 
;Recebe: ponteiro para armazenar string e número de bytes a serem escritos
%define num_bytes dword [ebp+12]
%define str dword [ebp+8]
scanf_s:
    push ebp
    mov ebp, esp

    mov eax, 3
    mov ebx, 1
    mov ecx, str
    mov edx, num_bytes
    int 0x80

    leave
    ret 8               ;ja desempilha os dois parametros str e num_bytes

;Função imprime_menu
imprime_menu:
    push ebp
    mov ebp, esp

    push tam_msg_menu_0
    push msg_menu_0
    call printf
    push tam_msg_menu_1
    push msg_menu_1
    call printf
    push tam_msg_menu_2
    push msg_menu_2
    call printf
    push tam_msg_menu_3
    push msg_menu_3
    call printf
    push tam_msg_menu_4
    push msg_menu_4
    call printf
    push tam_msg_menu_5
    push msg_menu_5
    call printf
    push tam_msg_menu_6
    push msg_menu_6
    call printf
    push tam_msg_menu_7
    push msg_menu_7
    call printf

    leave
    ret

;Funcao boas_vindas
boas_vindas: 
    push ebp
    mov ebp, esp

    ;imprime "Bem-vindo. Digite seu nome:"
    push tam_msg_nome
    push msg_nome
    call printf

    ;salva o nome
    push byte 50
    push nome
    call scanf_s

    mov dword [tam_nome], eax
    sub dword [tam_nome], 0x1

    ;imprime "Hola, "
    push tam_msg_boas_vindas_0
    push msg_boas_vindas_0
    call printf

    ;imprime o nome pelo tamanho
    push dword [tam_nome]
    push nome
    call printf

    ;imprime o restante da mensagem de boas vindas
    push tam_msg_boas_vindas_1
    push msg_boas_vindas_1
    call printf

    leave
    ret

%define arg_precisao [ebp+8]
pergunta_precisao:
    push ebp
    mov ebp, esp

    ;imprime "Vai trabalhar com 16 ou 32 bits (digite 0 para 16, e 1 para 32)"
    push tam_msg_precisao
    push msg_precisao
    call printf

    ;salva a precisao
    push byte 2
    push dword arg_precisao
    call scanf_s

    leave
    ret

; Assume que o resultado esterá em eax, visto que as funções devem 
; retornar a saída nesse registrador
%define buffer_arg2 dword [ebp-4]
%define buffer_arg1 dword [ebp-8]
%define buffer_arg0 dword [ebp-12]
%define end_buffer ebp
mostra_resultado:
    enter 12, 0

    ; Converte o resultado em eax para string
    ;mov edi, buffer            ; Endereço do buffer para armazenar a string
    ;mov buffer_arg2, dword 0
    ;sub buffer_arg2, 30
    ;mov buffer_arg1, dword 0
    ;mov buffer_arg0, dword 0
    ;push buffer_arg2
    ;push buffer_arg1
    sub dword end_buffer, 12

    push dword end_buffer
    push eax
    call itoa                  ; Converte eax para string

    ; Exibe a mensagem
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_resultado
    mov edx, tam_msg_resultado ; Tamanho da mensagem "Resultado: "
    int 0x80

    ; Exibe a mensagem
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_boas_vindas_0
    mov edx, tam_msg_boas_vindas_0 ; Tamanho da mensagem "Resultado: "
    int 0x80

    ; Exibe o número convertido
    mov eax, 4
    mov ebx, 1
    mov ecx, end_buffer            ; Endereço do buffer com o número convertido
    mov edx, 12                ; Tamanho do buffer, ajuste conforme necessário
    int 0x80

    ; Exibe a mensagem
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_boas_vindas_1
    mov edx, tam_msg_boas_vindas_1 ; Tamanho da mensagem "Resultado: "
    int 0x80

    leave
    ret