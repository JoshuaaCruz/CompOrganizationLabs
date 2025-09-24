.data
	
	
	prompt: 	.asciiz "Qual o nome de arquivo desejado? "
	result: 	.asciiz "O inteiro eh: "
	newline:	.asciiz "\n"
	space:      .asciiz " "
	
	matA:		.word 1,2,3,0,1,4,0,0,1
	matB:		.word 1,-2,5,0,1,-4,0,0,1
	matBT:     	.space 36 # transposta de B
	
	matResult:	.space 36 # matriz 3x3 = 9 x 4(tamanho 4bytes)=36
	
	fileNameBuffer:	.space 100 #reserva 99 bytes para o nome de arquivo escolhido pelo usuário, 0 100° é o caractere nulo '\0'


.text

main:

	jal PROC_NOME
	
	#CRIANDO ARQUIVO PARA ESCRITA (NÃO EXISTENTE)
	li	$v0,13	#COMANDO ABRIR NOVO ARQUIVO
	la	$a0,fileNameBuffer	#CARREGA NOME DO ARQUIVO A SER ABERTO
	li	$a1,1	#ABERTO PARA ESCRITA (pesquisar de flags)
	li	$a1,0	#MODO IGNORADO???PESQUISAR
	syscall
	move	$s6,$v0	#salva o descritor do arquivo para uso no fechamento
	
	#############################
	#ESCREVE NO ARQUIVO ABERTO
	
	li	$v0,15	#comando escreve arquivo
	move	$a0,$s6	#descritor do arquivo passado
	
	
	
	
	li 	$v0,10 #ENCERAR O PROGRAMA PARA EVITAR LOOP
	syscall
	
	
	
    	jal PROC_TRANS 	# calcula transposta de B
   	jal PROC_MUL 	# calcula matriz resultante = A * BT

    	# imprime matResult no console para verificar (depois tirar quando for pra .txt)
    	la $a0, matResult
    	li $a1, 3      # linhas
    	li $a2, 3      # colunas
    	jal PRINT_MATRIX

    	li $v0, 10
    	syscall
    	
PROC_NOME: #SOLICITAR AO USER PELO NOME DO ARQUIVO .txt
	
	li 	$v0,4
	la 	$a0,prompt #imprime prompt
	syscall
	

	li 	$v0,8 #pega inteiro do user
	
	la 	$a0, fileNameBuffer #endereço do buffer em $a0
	li	$a1,100 # Tamanho máximo da string em $a1
	syscall	# A string é lida e salva no buffer
	
	
	
	li 	$v0,4
	la	$a0,fileNameBuffer
	syscall #imprime a string do user
	
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	la $v0, fileNameBuffer
	
	jr 	$ra


PROC_TRANS:
    	li $t0, 0         # i = 0
trans_i:
    	li $t1, 0         # j = 0
trans_j:
    	# posicao em B: (i*3) + j
    	mul $t2, $t0, 3
    	add $t2, $t2, $t1
    	sll $t2, $t2, 2
    	la $t3, matB
    	add $t3, $t3, $t2
    	lw $t4, 0($t3)

    	# posicao em BT: (j*3) + i  --> BT[j][i] = B[i][j]
    	mul $t2, $t1, 3
    	add $t2, $t2, $t0
    	sll $t2, $t2, 2
    	la $t3, matBT
    	add $t3, $t3, $t2
    	sw $t4, 0($t3)

    	addi $t1, $t1, 1
    	li $t5, 3
    	blt $t1, $t5, trans_j

    	addi $t0, $t0, 1
    	blt $t0, $t5, trans_i

    	jr $ra


PROC_MUL:
    	li $t0, 0         # i = 0
mul_i:
    	li $t1, 0         # j = 0
mul_j:
   	li $t2, 0         # k = 0
    	li $t3, 0         # soma = 0

mul_k:
    	li $t9, 3
    	bge $t2, $t9, mul_store

    	# A[i][k]
    	mul $t4, $t0, 3
    	add $t4, $t4, $t2
    	sll $t4, $t4, 2
    	la $t5, matA
    	add $t5, $t5, $t4
    	lw $t6, 0($t5)     # t6 = A[i][k]

    	# BT[k][j]
    	mul $t4, $t2, 3
    	add $t4, $t4, $t1
    	sll $t4, $t4, 2
    	la $t5, matBT
    	add $t5, $t5, $t4
    	lw $t7, 0($t5)     # t7 = BT[k][j]

    	# soma parcial
    	mul $t8, $t6, $t7
    	add $t3, $t3, $t8

    	addi $t2, $t2, 1
    	j mul_k

mul_store:
    	# armazena C[i][j] = soma
    	mul $t4, $t0, 3
    	add $t4, $t4, $t1
    	sll $t4, $t4, 2
    	la $t5, matResult
   	add $t5, $t5, $t4
    	sw $t3, 0($t5)

    	addi $t1, $t1, 1
    	li $t9, 3
    	blt $t1, $t9, mul_j

    	addi $t0, $t0, 1
    	blt $t0, $t9, mul_i

    	jr $ra


# PRINT_MATRIX imprime matriz de inteiros com espaços e \n
# $a0 = endereço da matriz, $a1 = linhas, $a2 = colunas

PRINT_MATRIX:
    	move $t0, $a0      # base da matriz
    	move $t1, $a1      # linhas
    	move $t2, $a2      # colunas

    	li $t3, 0          # i = 0
print_i:
    	bge $t3, $t1, end_print
    	li $t4, 0          # j = 0
print_j:
    	bge $t4, $t2, next_print_i

    	mul $t5, $t3, $t2
    	add $t5, $t5, $t4
    	sll $t5, $t5, 2
    	add $t6, $t0, $t5
    	lw $a0, 0($t6)

    	li $v0, 1
    	syscall            # print int

    	# espaço
    	li $v0, 4
    	la $a0, space
    	syscall

    	addi $t4, $t4, 1
    	j print_j

next_print_i:
    	# nova linha
    	li $v0, 4
    	la $a0, newline
    	syscall

    	addi $t3, $t3, 1
    	j print_i

end_print:
    	jr $ra
