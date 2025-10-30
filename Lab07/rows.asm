.data

data:		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

space:		.asciiz " "
newline:	.asciiz "\n"

.text
.globl main

main:
	la   $s0, data		# carrega o endereço base da matriz em $s0
    	li   $t6, 0		# value = 0

    	li   $t1, 0		# row = 0
rows:
    	bge  $t1, 16, print_matrix	# se row >= 16 termina --> vai imprimir

    	li   $t2, 0			# col = 0
cols:
    	bge  $t2, 16, next_row	# se col >= 16 vai para prox linha

    	# calcula o endereço de data[row][col]
    	mul  $t3, $t1, 16		# t3 = row * 16
    	add  $t3, $t3, $t2		# t3 = (row * 16) + col
    	sll  $t4, $t3, 2		# t4 = offset em bytes (multiplica por 4)

    	add  $t5, $s0, $t4		# endereço final = endereço base + offset
    	sw   $t6, 0($t5)		# guarda value em data[row][col]

    	addi $t6, $t6, 1		# value++
    	addi $t2, $t2, 1		# col++
    	j    cols

next_row:
    	addi $t1, $t1, 1		# row++
    	j    rows

# Impressao da matriz

print_matrix:
    	li   $t1, 0			# row = 0
print_rows:
    	bge  $t1, 16, end		# se ja imprimiu as 16 linhas vai para end

    	li   $t2, 0			# col = 0
print_cols:
    	bge  $t2, 16, print_newline	# se ja imprimiu as 16 colunas da linha vai para print_newline

    	# calcula o endereço de data[row][col]
    	mul  $t3, $t1, 16
    	add  $t3, $t3, $t2
    	sll  $t4, $t3, 2
    	add  $t5, $s0, $t4

    	lw   $a0, 0($t5)		# carrega o valor de data[row][col] em $a0
    	li   $v0, 1
    	syscall

    	la   $a0, space
    	li   $v0, 4
    	syscall

    	addi $t2, $t2, 1		# col++
    	j    print_cols

print_newline:
    	# imprime uma quebra de linha ao final de cada linha da matriz
    	la   $a0, newline
    	li   $v0, 4
    	syscall

    	addi $t1, $t1, 1		# row++
    	j    print_rows

end:
    	li   $v0, 10
    	syscall
