.include "labels.asm"

.globl JThr_1
#THREAD CONTADORA DE 1 SEGUNDO
.data
	vetor1: .word 0
	msg1:	.asciiz "\nThread 1 (1s): "
.text
p1:

JThr_1:
		
	la		$s1, vetor1
	li		$v0,30
	syscall		#sycall 30 retorna tempo atual
	addi		$s0, $a0,1000 #adicionando 1000ms ao tempo atual e salvando em s0 PARA SER PRIMEIRA MARCA
		
loopJ1:
	li		$v0,30
	syscall
	
	blt		$a0,$s0,loopJ1
	
	#CASO CONTADOR DE TEMPO PASSE DA MARCA
	
	lw		$t0,0($s1)
	addi		$t0,$t0,1
	sw		$t0,0($s1)
	
	li		$v0, 4			# Print string
	la		$a0, msg1
	syscall
	
	li		$v0, 1			# Print integer (o contador)
	move		$a0, $t0
	syscall
	
	#definindo próxima marca de 1s
	
	li		$v0,30
	syscall
	addi		$s0, $a0,1000
	
	j		loopJ1
	
ret: 
li $v0 1
jr $ra