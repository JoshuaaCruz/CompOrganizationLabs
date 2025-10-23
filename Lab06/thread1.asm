.include "labels.asm"

.globl JThr_1
#THREAD CONTADORA DE 1 SEGUNDO
.data
	vetor1: .word 0

.text

JThr_1:
		
		
		
		la		$s1, vetor1
		addi		$t1,$t1,1
		sw		$t1, 0($s1)
		j		JThr_1	