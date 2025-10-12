.data
	promptTamVet: .asciiz "Digite o tamanho do vetor: "
	printNumsVet: .asciiz "\nDigite a seguinte qtd de números para o vetor: "
	
	resultSize: .asciiz "\nO tamanho vet eh: "
	evenNum: .asciiz "\nNumeros do vetor: "
	
	size: .word
	array: .word #array tamanho size...como fazer?
	key: .word
	
	promptNumProcurar: .asciiz "\nDigite o número a procurar: "
	
	found: .word
	
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
	
	addi	$t0,$t0,1

	j	loopProcuraKey
found:
	move	$t2,$zero
	addi	$t2,$t2,1
	sw	$t2,found #move zero a t2, soma 1 e depois salva
	
fim:
	move 	$t9,$zero
	addi 	$t9,$t9,1
	beq	$t9,$t2,encontrado #pula para encontrado
	
	#caso não tenha encontrado
	li 	$v0,4
	la 	$a0,outNoEnc #imprime prompt
	syscall
	
	j	shutDown
	
encontrado:

	li 	$v0,4
	la 	$a0,outEnc #imprime prompt
	syscall
	
shutDown:
   	li   $v0, 10       # syscall para terminar a execução
   	syscall

	