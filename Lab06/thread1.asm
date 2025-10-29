.include "labels.asm"

.globl JThr_1
#THREAD CONTADORA DE 1 SEGUNDO
.data
	vetor1: .word 0
	msg1:	.asciiz "\nThread 1 (1s): "
	.eqv display_esq 0xffff0011
	
	tabela: .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
    	dez:    .word 10

.text

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
	lw      $t8, dez        # t8 = 10
    	divu    $t0, $t8
    	mfhi    $t0             # t0 = (counter + 1) % 10
    
    	sw      $t0, 0($s1)     # Store the new (0-9) value back
	
	li		$v0, 4			# Print string
	la		$a0, msg1
	syscall
	
	li		$v0, 1			# Print integer (o contador)
	move		$a0, $t0
	syscall
	
	la      $t4, tabela     # t4 = base address of tabela
    	add     $t1, $t0, $t4   # t1 = address of tabela[t0]
    	lb      $t3, 0($t1)     # t3 = the 8-bit pattern (e.g., 0x3F)

    	# enviando ao display
    	sb      $t3, display_esq
	
	#definindo próxima marca de 1s
	
	li		$v0,30
	syscall
	addi		$s0, $a0,1000
	
	j		loopJ1