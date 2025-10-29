.include "labels.asm"

.globl JThr_2
#THREAD CONTADORA DE 3 SEGUNDO
.data
	vetor2: .word 0
	msg2:	.asciiz "\nThread 2 (3s): "
	.eqv display_dir 0xffff0010
	
	tabela: .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
    	dez:    .word 10

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
	lw      $t8, dez        # t8 = 10
    	divu    $t0, $t8
    	mfhi    $t0             # t0 = (counter + 1) % 10
	
	sw		$t0,0($s2)
	
	li		$v0, 4			# Print string
	la		$a0, msg2
	syscall
	
	li		$v0, 1			# Print integer (o contador)
	move		$a0, $t0
	syscall

	la      $t4, tabela     # t4 = base address of tabela
    	add     $t1, $t0, $t4   # t1 = address of tabela[t0]
    	lb      $t3, 0($t1)     # t3 = the 8-bit pattern (e.g., 0x3F)

    	# enviando ao display
    	sb      $t3, display_dir

	#definindo próxima marca de 3s
	
	li		$v0,30
	syscall
	addi		$s3, $a0,3000
	
	j		loopJ2	