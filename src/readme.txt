O trabalho foi realizado pelos estudantes:
- Liz Carolina Jaber Costato - matrícula: 18/0022261
- Pedro Cesar Ribeiro Passos - matrícula: 18/0139312

O Sistema Operacional utilizado foi Linux (Ubuntu).
Como especificado, o montador utilizado foi o nasm e o ligador o ld.

----------------------------------------------------------------------------------------------------------------
Como o trabalho deve ser compilado:
- Deve-se montar, separadamente, todos os arquivos de extensão '.asm' (calculadora.asm, soma.asm. subtracao.asm, 
multiplicacao.asm, divisao.asm, mod.asm e exponenciacao.asm), da seguinte forma:

nasm -f elf -o nome_arq_objeto.o nome_arq_assembly.asm

Por exemplo, o arquivo soma.asm, deve ser montado como:
nasm -f elf -o soma.o soma.asm

Assumindo que foi dado aos arquivos objetos o mesmo nome do arquivo original, tem-se que o programa deve ser 
ligado da seguinte forma:

ld -m elf_i386 -o calculadora soma.o subtracao.o multiplicacao.o divisao.o mod.o exponenciacao.o calculadora.o

Para executar:

./calculadora
