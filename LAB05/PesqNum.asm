.data
	promptTamVet: .asciiz "Digite o tamanho do vetor: "
	printNumsVet: .asciiz "\nDigite a seguinte qtd de números para o vetor: "
	
	resultSize: .asciiz "\nO tamanho vet eh: "
	evenNum: .asciiz "\nNumeros do vetor: "
	
	size: .word 0
	array: .space 400
	key: .word
	
	promptNumProcurar: .asciiz "\nDigite o número a procurar: "
	
	#found: .word
	
	outEnc: .asciiz "\nNúmero encontrado"
	outNoEnc: .asciiz "\nNúmero não encontrado"

.text
main:
	li 	$v0,4
	la 	$a0,promptTamVet #imprime prompt
	syscall
	
	li 	$v0,5 #pega inteiro
	syscall
	move 	$s0,$v0 #salva em s0
	
	li 	$v0,4
	la 	$a0,resultSize #fala o seu tamVet eh:
	syscall
	
	li 	$v0,1
	move	$a0,$s0
	syscall #imprime o size
	
	sw	$s0,size #s0 salvando em size
	
	###########
	li 	$v0,4
	la 	$a0,printNumsVet #imprime prompt
	syscall
	
	move	$t0,$zero #definindo i para for

loopNumsVet:
	beq	$t0,$s0, procura #compara i com size 
	
	li 	$v0,5 #pega inteiro
	syscall
	move 	$t1,$v0 #salva em t1, ver jeito de 
	
	#TODO: salvar em vetor pos de t0(i)
	#############
	la   $t2, array #endereço base do vetor
	sll  $t3, $t0, 2 #deslocamento i*4
	add  $t2, $t2, $t3 #endereço do elemento
	sw   $t1, 0($t2) #salva numero no vetor
	##############
	
	addi	$t0,$t0,1
	
	j	loopNumsVet
	
procura:
	li 	$v0,4
	la 	$a0,promptNumProcurar #imprime prompt
	syscall
	
	li 	$v0,5 #pega inteiro
	syscall
	move 	$s1,$v0 #salva em s1
	
	move	$t0,$zero #definindo i para for novamente
	
loopProcuraKey:
	beq	$t0,$s0,fim
	
	#TODO: compara array[i] == key
	#se achou pula para found
	###################
	la   $t4, array
	sll  $t5, $t0, 2
	add  $t4, $t4, $t5
	lw   $t6, 0($t4)
	beq  $t6, $s1, found
	###################
	
	addi	$t0,$t0,1
	j	loopProcuraKey

found:
	# imprime mensagem de numero encontrado
	li 	$v0,4
	la 	$a0,outEnc
	syscall
	j	shutDown

fim:
	# caso nao tenha encontrado
	li 	$v0,4
	la 	$a0,outNoEnc
	syscall
	
	j	shutDown
	
shutDown:
   	li   $v0, 10 # syscall para terminar a execução
   	syscall
