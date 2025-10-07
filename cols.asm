.data
data:    .space 1024         # 16x16 palavras para a matriz
space:   .asciiz " "         # String para um espaço
newline: .asciiz "\n"        # String para uma nova linha

.text
.globl main

main:
    # -- 1. INICIALIZAÇÃO --
    la   $s0, data           # IMPORTANTE: Carrega o endereço base da matriz em $s0
    li   $t6, 0              # value = 0

    # -- 2. LAÇO DE PREENCHIMENTO DA MATRIZ --
    li   $t1, 0              # col = 0
fill_cols:
    beq  $t1, 16, print_loop # Quando terminar, PULA PARA O LAÇO DE IMPRESSÃO
    li   $t2, 0              # row = 0
fill_rows:
    beq  $t2, 16, next_fill_col
    # Calcula endereço de data[row][col]
    mul  $t3, $t2, 16        # t3 = row * 16
    add  $t3, $t3, $t1        # t3 = (row * 16) + col
    sll  $t4, $t3, 2         # t4 = offset em bytes
    add  $t5, $s0, $t4
    # Armazena o valor
    sw   $t6, 0($t5)
    # Incrementa
    addi $t6, $t6, 1
    addi $t2, $t2, 1
    j    fill_rows
next_fill_col:
    addi $t1, $t1, 1
    j    fill_cols

# -- 3. LAÇO DE IMPRESSÃO DA MATRIZ --
print_loop:
    li   $t1, 0              # row = 0
print_rows:
    beq  $t1, 16, end        # Quando terminar, PULA PARA O FIM DO PROGRAMA
    li   $t2, 0              # col = 0
print_cols:
    beq  $t2, 16, print_newline
    # Calcula endereço de data[row][col]
    mul  $t3, $t1, 16
    add  $t3, $t3, $t2
    sll  $t4, $t3, 2
    add  $t5, $s0, $t4
    # Carrega o valor e imprime
    lw   $a0, 0($t5)
    li   $v0, 1
    syscall
    # Imprime um espaço
    la   $a0, space
    li   $v0, 4
    syscall
    # Incrementa
    addi $t2, $t2, 1
    j    print_cols
print_newline:
    la   $a0, newline
    li   $v0, 4
    syscall
    addi $t1, $t1, 1
    j    print_rows

# -- 4. FIM DO PROGRAMA --
end:
    li   $v0, 10             # syscall para terminar a execução
    syscall