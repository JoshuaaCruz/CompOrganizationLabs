.data
space: .asciiz " "
newline: .asciiz "\n"
size: .word 4 # Tamanho da Matriz (MAX x MAX)

A: .float 1.0, 1.0, 1.0, 1.0
   .float 1.0, 1.0, 1.0, 1.0
   .float 1.0, 1.0, 1.0, 1.0
   .float 1.0, 1.0, 1.0, 1.0

B: .float 2.0, 0.0, 0.0, 0.0
   .float 0.0, 2.0, 0.0, 0.0
   .float 0.0, 0.0, 2.0, 0.0
   .float 0.0, 0.0, 0.0, 2.0

.text
.globl main

main:
    la $s0, A
    la $s1, B
    lw $s2, size

    li $t0, 0
LOOP_i:
    bge $t0, $s2, PRINT_A # if (i >= size) PULA PARA IMPRESSÃO


    li $t1, 0
LOOP_j:
    bge $t1, $s2, END_j # if (j >= size) vai para END_j


    # Calcula endereco de A[i,j]
    mul $t3, $t0, $s2
    add $t3, $t3, $t1
    sll $t4, $t3, 2
    add $t5, $s0, $t4

    # Carrega A[i,j] como float
    l.s $f0, 0($t5)

    # Calcula endereco de B[j,i]
    mul $t3, $t1, $s2
    add $t3, $t3, $t0
    sll $t4, $t3, 2
    add $t7, $s1, $t4

    # Carrega B[j,i] como float
    l.s $f2, 0($t7)

    # Soma floats
    add.s $f4, $f0, $f2

    # Armazena resultado
    s.s $f4, 0($t5)

    addi $t1, $t1, 1
    j LOOP_j

END_j:
    addi $t0, $t0, 1
    j LOOP_i

PRINT_A:
    li $t0, 0
print_rows:
    beq $t0, $s2, end
    li $t1, 0
print_cols:
    beq $t1, $s2, print_newline

    # Calcula endereco
    mul $t3, $t0, $s2
    add $t3, $t3, $t1
    sll $t4, $t3, 2
    add $t5, $s0, $t4

    # Imprime float
    l.s $f0, 0($t5)
    mov.s $f12, $f0
    li $v0, 2
    syscall

    # Imprime espaco
    la $a0, space
    li $v0, 4
    syscall

    addi $t1, $t1, 1
    j print_cols

print_newline:
    la $a0, newline
    li $v0, 4
    syscall
    addi $t0, $t0, 1
    j print_rows

end:
    li $v0, 10
    syscall