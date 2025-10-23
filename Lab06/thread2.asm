.include "labels.asm"

.globl JThr_2
#THREAD CONTADORA DE 3 SEGUNDO
.data
	vetor2: .word 0

.text

JThr_2:
		la		$s2, vetor2
		addi		$t1,$t1,1   #NECESSÁRIO MUDAR?
		sw		$t1, 0($s2) #NECESSÁRIO MUDAR?
		j		JThr_2	