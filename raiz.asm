.data
	prompt: .asciiz "Entre com um inteiro "
	result: .asciiz "O inteiro eh: "
	newline: .asciiz "\n"
	var: .word 7 #8 BYTES
	
	
	valor1: .word 0

.text

main:



TAKE_NUM:

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
	
RAIZ:
	
	
