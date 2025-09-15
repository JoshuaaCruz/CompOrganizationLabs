.data
	prompt: .asciiz "Entre com um inteiro "
	result: .asciiz "O inteiro eh: "
	resultS: .asciiz "Os inteiros somados eh: "
	newline: .asciiz "\n"
	hello: .asciiz "Oi, alunos de INE5411"
	var: .word 7 #8 BYTES
	
	
	valor1: .word 0

.text
# Início do programa
main:

	li 	$v0,4
	la 	$a0,hello
	syscall
	
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	li 	$v0,4
	la 	$a0,prompt #imprime prompt
	syscall
	

	li 	$v0,5 #pega inteiro do cara
	syscall
	move 	$t0,$v0 #salva em t0
	
	li 	$v0,4
	la 	$a0,result #fala o seu inteiro eh:
	syscall
	
	li 	$v0,1
	move	$a0,$t0
	
	syscall #imprime o primeiro inteiro do cara, endereço a0
	
	############################################################
	
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	
	li 	$v0,4
	la 	$a0,prompt #imprime prompt
	syscall
	
	
	li 	$v0,5 #pega inteiro do cara
	syscall
	move 	$t1,$v0 #salva em t0
	
	li 	$v0,4
	la 	$a0,result #fala o "seu inteiro eh:"
	syscall
	
	li 	$v0,1
	move	$a0,$t1
	
	#move	valor1,$t0
	
	syscall #imprime o segundo inteiro do cara, endereço a0 vindo t1
	
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	################################################
	#agora com os 2 endereços t0 e t1 do cara, posso somar e imprimir
	
	add $t3, $t0, $t1
	
	li 	$v0,4
	la 	$a0,resultS #fala o "seu resultado soma eh:"
	syscall
	
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	li 	$v0,1
	move	$a0,$t3
	syscall #imprime a soma inteiros do cara, endereço t3
	
	
	
	
