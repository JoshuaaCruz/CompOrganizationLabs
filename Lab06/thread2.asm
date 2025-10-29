.include "labels.asm"

.globl JThr_2
#THREAD CONTADORA DE 3 SEGUNDO
.data
	vetor2: .word 0
	msg2:	.asciiz "\nThread 2 (3s): "
	.eqv display_dir 0xffff0010

.text

JThr_2:
	la		$s2, vetor2
	li		$v0,30
	syscall		#sycall 30 retorna tempo atual
	addi		$s3, $a0,3000 #adicionando 1000ms ao tempo atual e salvando em s3 PARA SER PRIMEIRA MARCA
		
loopJ2:
	li		$v0,30
	syscall
	
	blt		$a0,$s3,loopJ2
	
	#CASO CONTADOR DE TEMPO PASSE DA MARCA
	
	lw		$t0,0($s2)
	addi		$t0,$t0,1
	sw		$t0,0($s2)
	
	li		$v0, 4			# Print string
	la		$a0, msg2
	syscall
	
	li		$v0, 1			# Print integer (o contador)
	move		$a0, $t0
	syscall

	sb      $t0, display_dir

	#definindo próxima marca de 3s
	
	li		$v0,30
	syscall
	addi		$s3, $a0,3000
	
	j		loopJ2	
