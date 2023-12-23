;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIÁVEIS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

negativo_simbolo db '-'      
tam_negativo_simbolo EQU 1     

nova_linha db 0dH, 0ah
tam_nova_linha EQU $-nova_linha

section .bss
;variaveis globais (no contexto desse arquivo)
nome resb 50           ; Assumindo que o nome não passará de 50 bytes
tam_nome resb 4
precisao resb 1
opcao resd 1

section .text
extern soma                   
extern subtracao              
extern multiplicacao
extern divisao
extern mod
extern exponenciacao

global _start
global int_para_string                   
global string_para_int
global scanf_16
global scanf_32
global printf
global mostra_resultado

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;MAIN;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%define tam_lido [ebp-4]
%define resultado_eax [ebp-8]
_start:
    enter 8,0
    call boas_vindas    

    call pergunta_precisao

loop_menu:
    call imprime_menu

    push dword 0x04
    push dword opcao
    call scanf_s

    sub byte [opcao], 48        ; Transforma em ASCII
    cmp byte [opcao], 1
    je op_soma
    cmp byte [opcao], 2
    je op_sub
    cmp byte [opcao], 3
    je op_mul
    cmp byte [opcao], 4
    je op_div
    cmp byte [opcao], 5
    je op_exp
    cmp byte [opcao], 6
    je op_mod
    cmp byte [opcao], 7
    je Fim


; Termina o programa
Fim:
    leave          

    mov eax, 1
    xor ebx, ebx
    int 0x80

op_soma:
    push precisao
    call soma

    push eax
    call mostra_resultado

    call aguarda_enter
    jmp loop_menu

op_sub:
    push precisao 
    call subtracao

    push eax
    call mostra_resultado

    call aguarda_enter
    jmp loop_menu

op_mul:
    push precisao 
    call multiplicacao
    call aguarda_enter
    jmp loop_menu

op_div:
    push precisao 
    call divisao
    call aguarda_enter
    jmp loop_menu

op_exp:
    push precisao 
    call exponenciacao
    call aguarda_enter
    jmp loop_menu

op_mod:
    push precisao 
    call mod
    call aguarda_enter
    jmp loop_menu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;FUNÇÕES DE CONVERSÃO;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Função int_para_string: Converte um número em eax para uma string ASCII
; Recebe: eax = número, edi = endereço do buffer de saída
; Retorna: nada, mas o buffer em eax terá a string
%define buffer_arg [ebp+20]
%define numero [ebp+8]
%define aux [ebp-4]
int_para_string:
    enter 4,0

    pusha
    
    ;zera toda a string, inicialmente
    mov ecx, 12             ; Número de bytes a serem preenchidos
    lea edi, buffer_arg

    sub al, al              ; Valor a ser inserido (zero)
preencher_com_zeros:
    mov [edi], al               ; Preenche o byte atual com zero
    inc edi                     ; Prox byte
    loop preencher_com_zeros    ; Repete até que todos os bytes (12) sejam preenchidos

    lea edi, buffer_arg         ; Volta o edi pro começo

    mov ebx, 10                 ; Divisor 

    mov ecx, edi                ; Ponteiro para o final da string no buffer
    add ecx, 11                 ; Ajustar para o tamanho do buffer
    ;mov byte [ecx], 0           ; Caractere nulo no final

    ; Verifica se o número é negativo
    cmp [precisao], byte 1
    je caso_32
    mov ax, word numero      ; Caso 16bits
    test ax, 8000h           ; Testa o bit mais significativo de ax
    jz positive               ; Se não for negativo, pula para a conversão positiva
    neg ax                     ; Negativa o número negativo
    mov byte [edi], '-'         ; Coloca sinal de menos no início do buffer
    inc edi                     ; Move o ponteiro do buffer para a frente
    jmp positive

caso_32:
    mov eax, numero
    test eax, eax
    jge positive               ; Se não for negativo, pula para a conversão positiva
    neg eax                     ; Negativa o número negativo
    mov byte [edi], '-'         ; Coloca sinal de menos no início do buffer
    inc edi                     ; Move o ponteiro do buffer para a frente

positive:
    ; Loop para converter o número em string
    .repeat:
        dec ecx                 ; Move para trás no buffer
        sub edx, edx            ; Limpa edx para a divisão
        div ebx                 ; Divide eax por 10, resultado em eax, resto em edx
        add dl, '0'             ; Converte o resto em caractere ASCII
        mov [ecx], dl           ; Armazena o caractere no buffer
        test eax, eax           ; Verifica se eax é zero
        jnz .repeat             ; Se não for, continua o loop

    ; Ajusta o ponteiro do buffer para o início da string
    mov eax, ebp                ; Endereço inicial do buffer
    add eax, 12                 ; Esse de fato é o endereço e n o conteúdo ebp+12
    lea eax, [ecx]             ; Se não, ajusta eax para o início da string numérica
    .done:
    mov aux, eax
    popa
    mov eax, aux
    leave
    ret 8 ;endereco do buffer tem 4 bytes + 4 bytes do número

; Recebe: [ebp+8] = ponteiro para a string de dígitos
; Retorna:   eax = valor inteiro convertido
%define pont_str_int [ebp+8]
%define aux_eax [ebp-4]
%define aux_ebx [ebp-8]
%define aux_ecx [ebp-12]
%define aux_edx [ebp-16]
string_para_int:
    enter 16,0

    pusha

    mov edx, pont_str_int 

    sub eax, eax           ; Inicializa o resultado para 0
    sub ebx, ebx           ; ebx será o sinal (0 para positivo, 1 para negativo)

    movzx ecx, byte [edx]  ; Primeiro caractere da string

    cmp ecx, '-'           ; Olha o sinal
    je  caso_neg          
    jmp  prox_dig

prox_dig:
    test ecx, ecx          ; Testa se é o final da string (caractere nulo)
    jz acabou              ; Se for, termina o loop

    cmp ecx, byte 0xa            ; Testa se é o ENTER (13 ou 0x0D)
    je acabou              ; Se for, termina o loop

    sub ecx, '0'            ; Converte o caractere ASCII para o valor numérico
    
    imul eax, 10            ; faz eax = eax*10 (desconsiderando o sinal)
    add eax, ecx           ; Soma ao que já foi convertido eax = eax+ecx

    inc edx                ; Próximo char
    movzx ecx, byte [edx] 
    jmp prox_dig          

caso_neg:
    inc edx               ; Pula o '-'
    movzx ecx, byte [edx]  
    mov ebx, 1            ; Atualiza o sinal como negativo
    jmp prox_dig      

acabou:
    test ebx, ebx           ; Testa o sinal
    jnz inv_neg    ; Se for negativo, aplica o sinal

    mov aux_eax, eax
    popa
    mov eax, aux_eax
    leave
    ret 4

inv_neg:
    neg   eax               ; Inverte o sinal para negativo

    mov aux_eax, eax
    popa
    mov eax, aux_eax
    leave
    ret 4


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;FUNÇÕES DE ENTRADA E SAÍDA DE DADOS;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Função printf: para saída de dadaos 
;Recebe: ponteiro para string e número de bytes a serem escritos
;Retorna: nada
%define num_bytes dword [ebp+12]
%define str dword [ebp+8]
printf:
    push ebp
    mov ebp, esp

    pusha

    mov eax, 4
    mov ebx, 1
    mov ecx, str
    mov edx, num_bytes
    int 0x80

    popa

    leave
    ret 8               ;ja desempilha os dois parametros str e num_bytes

;Função scanf_s: para leitura de string 
;Recebe: ponteiro para armazenar string e número de bytes a serem escritos
;Retorna: em eax o número de bytes lidos
%define num_bytes dword [ebp+12]
%define str dword [ebp+8]
%define aux [ebp-4]
scanf_s:
    enter 4,0

    pusha

    mov eax, 3
    mov ebx, 1
    mov ecx, str
    mov edx, num_bytes
    int 0x80

    mov aux, eax
    popa
    mov eax, aux

    leave
    ret 8               ;ja desempilha os dois parametros str e num_bytes

; Recebe: nada
; Retorna: valor inteiro de 16bits em ax
%define aux [ebp-11]
scanf_16:
    enter 11, 0   ; Considerando 5 chars + enter + final da string + eax

    pusha

    ;zera toda a string, inicialmente
    mov ecx, 7             ; Número de bytes a serem preenchidos
    mov edi, ebp            ; Endereço inicial do buffer
    sub edi, 10             ; Esse de fato é o endereço e n o conteúdo ebp-10
    sub al, al              ; Valor a ser inserido (zero)
preencher_com_zeros_16:
    mov [edi], al               ; Preenche o byte atual com zero
    inc edi                     ; Próximo byte
    loop preencher_com_zeros_16    ; Repete até que todos os bytes (7) sejam preenchidos

    mov eax, 3       
    mov ebx, 0       
    lea ecx, [ebp-10] ; Maior número com sinal de 16bits: 32767
    mov edx, 6        ; (5 dígitos + enter)
    int 0x80

    lea eax, [ebp-10]

    push eax
    ; Converte a string para um número inteiro
    call string_para_int

    mov aux, eax
    popa
    mov eax, aux

    leave
    ret

; Recebe: nada
; Retorna: valor inteiro de 32bits em eax
%define aux [ebp-16]
scanf_32:
    enter 16, 0   ; Considerando 10 chars + enter + final da string + eax

    pusha

    ;zera toda a string, inicialmente
    mov ecx, 12             ; Número de bytes a serem preenchidos
    mov edi, ebp            ; Endereço inicial do buffer
    sub edi, 15             ; Esse de fato é o endereço e n o conteúdo ebp-15
    sub al, al              ; Valor a ser inserido (zero)
preencher_com_zeros_32:
    mov [edi], al               ; Preenche o byte atual com zero
    inc edi                     ; Próximo byte
    loop preencher_com_zeros_32    ; Repete até que todos os bytes (12) sejam preenchidos

    mov eax, 3       
    mov ebx, 0       
    lea ecx, [ebp-15] ; Maior número com sinal de 32bits: 2.147.483.647
    mov edx, 11        ; (10 dígitos + enter)
    int 0x80

    ; Converte a string para um número inteiro
    lea eax, [ebp-15]

    push eax
    call string_para_int

    mov aux, eax
    popa
    mov eax, aux

    leave
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;FUNÇÕES AUXILIARES;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Função imprime_menu
; Recebe: nada
; Retorna: nada
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
; Recebe: nada
; Retorna: nada
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

    mov dword [tam_nome], eax ;No eax tem o número de bytes lidos no scanf_s
    sub dword [tam_nome], 0x1 ;Removendo o ENTER

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

pergunta_precisao:
    enter 0,0

    pusha

    ;imprime "Vai trabalhar com 16 ou 32 bits (digite 0 para 16, e 1 para 32)"
    push tam_msg_precisao
    push msg_precisao
    call printf

    lea eax, precisao

    ;salva a precisao
    push dword 2
    push dword eax
    call scanf_s
    sub byte [precisao], 48        ; Transforma em ASCII

    cmp ecx, 0

    popa

    leave
    ret

; Recebe o valor inteiro do resultado para imprimir 
; Retorna: nada
%define buffer_arg2 dword [ebp-4]
%define buffer_arg1 dword [ebp-8]
%define buffer_arg0 dword [ebp-12]
%define pont_string [ebp-16]
%define resultado dword [ebp+8]
mostra_resultado:
    enter 16, 0

    lea esi, buffer_arg0

    push dword esi
    push resultado
    call int_para_string                   ; Converte eax para string
    mov pont_string, eax        ;salva ponteiro para string

    ; Imprime a mensagem "Resultado"
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_resultado
    mov edx, tam_msg_resultado ; Tamanho da mensagem "Resultado: "
    int 0x80

    ; Imprime número convertido
    ; Verifica se o número é negativo
    cmp [precisao], byte 1
    je caso_32_res
    mov ax, word resultado      ; Caso 16bits
    test ax, 8000h           ; Testa o bit mais significativo de ax
    jz iniciar_impressao       ; Se não for negativo, pula para a conversão positiva
    ;se for negativo, imprime o sinal
    mov eax, 4
    mov ebx, 1
    mov ecx, negativo_simbolo          ; Endereço do bsinal '-'
    mov edx, tam_negativo_simbolo      ; Tamanho do sinal - 1 byte
    int 0x80                     ; Move o ponteiro do buffer para a frente
    jmp iniciar_impressao

caso_32_res:
    mov eax, resultado
    test eax, eax
    jg iniciar_impressao
    ;se for negativo, imprime o sinal
    mov eax, 4
    mov ebx, 1
    mov ecx, negativo_simbolo          ; Endereço do bsinal '-'
    mov edx, tam_negativo_simbolo      ; Tamanho do sinal - 1 byte
    int 0x80

iniciar_impressao:
    mov ecx, pont_string  ; Endereço do início da string
imprimir_string:
    mov al, [ecx]         ; Carrega o byte da string em AL
    test al, al            ; Verifica se é o caractere nulo (fim da string)
    jz  fim_impressao     ; Se for, termina a impressão

    ; Imprime o byte atual
    mov eax, 4
    mov ebx, 1
    mov ecx, ecx          ; Endereço do buffer com o byte atual
    mov edx, 1            ; Tamanho do buffer (apenas 1 byte)
    int 0x80

    inc ecx               ; Avança para o próximo byte
    jmp imprimir_string   ; Repete o processo para o próximo byte

fim_impressao:

    push tam_nova_linha
    push nova_linha
    call printf

    leave
    ret 4                   ; resultado (numérico)

; Recebe: nada
; Retorna: nada
%define buffer [ebp-4]
aguarda_enter:
    enter 4,0
    pusha

    lea esi, buffer
tenta_de_novo:
    push 1
    push esi
    call scanf_s

    cmp buffer, byte 0xa 
    jne tenta_de_novo

    popa
    leave
    ret
