;------------------------------------------------------------------------------------------------------------
;                                      -Programa Calculadora-
;-Alunos: 
;-Pedro César Ribeiro Passos - 180139312
;-Liz Carolina J Costato - 
;-----------------------------------------------------------------------------------------------------------
;Para montar o programa:
;
;nasm -f elf -o calculadora.o calculadora.asm
;------------------------------------------------------------------------------------------------------
;Para ligar o programa:
;
;ld -m elf_i386 -o calculadora calculadora.o
;----------------------------------------------------------------------------------------------------------
;Após isso é só executá-lo:
;
;./calculadora
;--------------------------------------------------------------------------------------------------------

;Definições -------------------------------------------------------------------------------------------------

%define True 1
%define False 0
%define short 2
%define number_of_initial_messages 8
global _start


;Seção de alocação de variáveis ---------------------------------------------------------------------------------
section .bss

    operation resb 2
    first_number_string resb 7 
    second_number_string resb 7
    output_number_string resb 7
    output_number_space_position resb 7
    first_number resw 1
    second_number resw 1
    number_signal resb 1
    output_number_signal resb 1
    tests resb 1


;Seção de dados ----------------------------------------------------------------------------------------
section .data


array_msgs:
    db "Bem-vindo. Digite seu nome:", 0dH, 0ah, 0dH, 0ah
    msg1_len equ $ - array_msgs
    db "Digite o numero da operacao desejada entao aperte enter:", 0dH, 0ah, 0dH, 0ah
    msg2_len equ $ - array_msgs - msg1_len
    db "1 - SOMA", 0dH, 0ah
    msg3_len equ $ - array_msgs - msg1_len - msg2_len
    db "2 - SUBTRACAO", 0dH, 0ah
    msg4_len equ $ - array_msgs - msg1_len - msg2_len - msg3_len
    db "3 - MULTIPLICACAO", 0dH, 0ah
    msg5_len equ $ - array_msgs - msg1_len - msg2_len - msg3_len - msg4_len
    db "4 - DIVISAO", 0dH, 0ah
    msg6_len equ $ - array_msgs - msg1_len - msg2_len - msg3_len - msg4_len - msg5_len
    db "5 - EXPONENCIACAO", 0dH, 0ah
    msg7_len equ $ - array_msgs - msg1_len - msg2_len - msg3_len - msg4_len - msg5_len - msg6_len
    db "6 - MOD", 0dH, 0ah
    msg8_len equ $ - array_msgs - msg1_len - msg2_len - msg3_len - msg4_len - msg5_len - msg6_len - msg7_len
    db "7 - SAIR", 0dH, 0ah, 0dH, 0ah
    msg9_len equ $ - array_msgs - msg1_len - msg2_len - msg3_len - msg4_len - msg5_len - msg6_len - msg7_len - msg8_len
    all_msgs equ $ - array_msgs

array_msgs_lengths:
    dd msg1_len, msg2_len, msg3_len, msg4_len, msg5_len, msg6_len, msg7_len, msg8_len, msg9_len

section .text

    _start:

        push array_msgs
        push all_msgs
        call _print_initial_messages
        push operation
        push WORD 2
        call _input_from_user
        and eax, 0
        mov al, [operation]
        sub al, 30h
        cmp al, 1
        jz _soma
        cmp al, 2
        jz _subtracao
        cmp al, 3
        jz _multiplicacao
        cmp al, 4
        jz _divisao
        cmp al, 5
        jz _exponenciacao
        cmp al, 6
        jz _mod
        jmp _exit
    
    _exit:

        mov eax, 1
        mov ebx, 0
        int 80h

    _print_initial_messages:

        enter 0,0
        mov edx, [EBP + 8]
        mov ecx, [EBP + 12]
        mov eax, 4
        mov ebx, 1
        int 80h
        leave
        ret 8


    ;_loop_print_init:

        ;mov eax, 4
        ;mov ebx, 1
        ;int 80h
        ;mov eax, 4
        ;mov ebx, 1

        ;add ecx, edx
        ;add ESI, 4h
        ;mov edx, [array_msgs_lengths + ESI]
        ;cmp ESI, 24h
        ;jnz _loop_print_init
        ;and ESI, 0
        ;ret


    _input_from_user:

        enter 0,0
        mov dx, [EBP + 8]
        mov cx, [EBP + 10]
        mov eax, 3
        mov ebx, 0
        int 80h
        leave
        ret 6

    _soma:

        push first_number
        push first_number_string
        call _number_input
        push second_number
        push second_number_string
        call _number_input
        mov eax, [first_number]
        mov ebx, [second_number]
        add eax, ebx
        mov byte [tests], al
        cmp eax, 0
        ja _positive_signal
        mov byte [output_number_signal], '-'
        jmp _go_to_print_output_number

    _positive_signal:
        mov byte [output_number_signal], '+'
        jmp _go_to_print_output_number

    _go_to_print_output_number:
    
        push dword output_number_signal
        push eax
        call _print_output_number
        jmp _exit

    _print_output_number:

        enter 0, 0
        mov eax, [EBP + 8]
        mov ecx, output_number_string
        mov ebx, 10
        mov [ecx], ebx
        inc ecx
        mov [output_number_string], ecx

    _loop_int_to_string:

        and edx, 0
        mov ebx, 10
        div ebx
        push eax
        add edx, 48 ; '0'
        mov ecx, [output_number_space_position]
        mov [ecx], dl
        inc ecx
        mov [output_number_space_position], ecx
        pop eax
        cmp eax, 0
        jne _loop_int_to_string
        mov ecx, [EBP + 12]
        mov eax, 4
        mov ebx, 1
        mov edx, 1
        int 80h
    _print_loop:
        mov ecx, [output_number_space_position]
        mov eax, 4
        mov ebx, 1
        mov edx, 1
        int 80h
        mov ecx, [output_number_space_position]
        dec ecx
        mov [output_number_space_position], ecx
        cmp ecx, output_number_string
        jge _print_loop
        leave
        ret
        


    _subtracao:


    _multiplicacao:


    _divisao:

    _exponenciacao:


    _mod:
    

    _number_input:

        enter 0,0
        mov ecx, [EBP + 8]
        mov eax, 3
        mov ebx, 0
        mov edx, 7
        int 80h
        and eax, 0
        mov bl, byte [ecx]
        cmp bl, '-'
        jnz _loop_string_to_int
        push number_signal
        call _negative_number
        and eax, 0
    _loop_string_to_int:
    
        movzx edx, byte [ecx];byte into dword
        inc ecx
        cmp edx, '0'
        jb _return_number_input
        cmp edx, '9'
        ja _return_number_input ;se nao esta na faixa '0' a '9' ou seja é o \n
        sub edx, 30h
        imul ah
        add eax, edx
        jmp _loop_string_to_int

        
    _return_number_input:

        mov ecx, [number_signal]
        cmp ecx, 1
        jnz _store_number
        neg eax
    _store_number:
        mov ecx, [EBP + 12]
        mov [ecx], eax
        leave
        ret 8

    _negative_number:

        enter 0, 0
        mov eax, [EBP + 8]
        mov byte [eax], 1
        leave 
        ret 4
