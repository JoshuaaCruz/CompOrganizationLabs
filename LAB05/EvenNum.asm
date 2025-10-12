.data
	prompt: .asciiz "Entre com um inteiro "
	printCount: .asciiz "\nContador: "
	result: .asciiz "O inteiro eh: "
	evenNum: .asciiz "\nNúmero par: "
	
	counter: .word 0

.text

main:
	li 	$v0,4
	la 	$a0,prompt #imprime prompt
	syscall
	
	li 	$v0,5 #pega inteiro do cara
	syscall
	move 	$s0,$v0 #salva em s0
	
	li 	$v0,4
	la 	$a0,result #fala o seu inteiro eh:
	syscall
	
	li 	$v0,1
	move	$a0,$s0
	syscall #imprime o primeiro inteiro do cara, endereço a0
	
	move	$t0,$zero #i do for ficará em t0
	
loop:
	beq	$t0,$s0,fim #compara se i == limit (s0)
	
	#divide i por 2 e vê se resto é zero
	rem	$t1,$t0,2 #salva remainder de t0/2 em t1
	beqz	$t1, counterPP #se remainder for zero ent counter++ e printa
	
	addi	$t0,$t0,1 #se não de qualquer jeito aumenta t0
	
	j	loop
	
counterPP:
	lw	$t2,counter
	addi	$t2,$t2,1
	sw	$t2,counter #load word, soma e depois salva
	
	li 	$v0,4
	la 	$a0,printCount #imprime o Counter:
	syscall
	
	li 	$v0,1
	move	$a0,$t2
	syscall #imprime counter
	
	li 	$v0,4
	la 	$a0,evenNum
	syscall
	
	li 	$v0,1
	move	$a0,$t0
	syscall #imprime i
	
	addi	$t0,$t0,1
	
	j	loop
	
fim:
   	li   $v0, 10             # syscall para terminar a execução
   	syscall