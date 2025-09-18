.data
	varX1: .word 0
	varX2: .word 0
	
	vara: .word 1
	varb: .word -4
	varc: .word 3
	
	promptA: .asciiz "\nEntre com um inteiro para A: "
	resultA: .asciiz "O inteiro fornecido A eh: "
	
	promptB: .asciiz "\nEntre com um inteiro para B: "
	resultB: .asciiz "O inteiro fornecido B eh: "
	
	promptC: .asciiz "\nEntre com um inteiro para C: "
	resultC: .asciiz "O inteiro fornecido C eh: "
	
	toBeSqrt: .asciiz "O inteiro que vai ser sqrt eh: "
	alreadySqrt: .asciiz "O inteiro que passou por sqrt eh: "
	resultX1: .asciiz "X1 eh: "
	resultX2: .asciiz "X2 eh: "
	newline: .asciiz "\n"

.text

main:
	
	li	$t2, 2 # Carrega o valor 2 em $t2 (valor inteiro constante)
	
	#LENDO VALOR DO TECLADO A-------------------------
	
	li 	$v0,4
	la 	$a0,promptA #imprime prompt
	syscall
	

	li 	$v0,5 #pega inteiro do cara
	syscall
	move 	$t6,$v0 #salva em t6
	
	li 	$v0,4
	la 	$a0,resultA #fala o seu inteiro eh:
	syscall
	
	li 	$v0,1
	move	$a0,$t6
	
	syscall #imprime o primeiro inteiro do cara, endereço a0
	
	#LENDO VALOR DO TECLADO(FIM)-------------------------
	
	
	mul	$t2, $t2, $t6 #2A
	
	li	$t4, 4 # Carrega o valor 4 em $t4 (valor inteiro constante)
	
	#LENDO VALOR DO TECLADO B-------------------------
	
	#\N EM ASSEMBLY
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	li 	$v0,4
	la 	$a0,promptB #imprime prompt
	syscall
	

	li 	$v0,5 #pega inteiro do cara
	syscall
	move 	$t8,$v0 #salva em t8
	
	li 	$v0,4
	la 	$a0,resultB #fala o seu inteiro eh:
	syscall
	
	li 	$v0,1
	move	$a0,$t8
	
	syscall #imprime o primeiro inteiro do cara, endereço a0
	
	#LENDO VALOR DO TECLADO(FIM)-------------------------
	
	#lw	$t8, varb # Carrega o valor B em $t8 --DELETAR
	
	#LENDO VALOR DO TECLADO C-------------------------
	
	#\N EM ASSEMBLY
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	li 	$v0,4
	la 	$a0,promptC #imprime prompt
	syscall
	

	li 	$v0,5 #pega inteiro do cara
	syscall
	move 	$t9,$v0 #salva em t0
	
	li 	$v0,4
	la 	$a0,resultC #fala o seu inteiro eh:
	syscall
	
	li 	$v0,1
	move	$a0,$t9
	
	syscall #imprime o primeiro inteiro do cara, endereço a0
	
	#LENDO VALOR DO TECLADO(FIM)-------------------------
	
	#lw	$t9, varc # Carrega o valor C em $t9 -- DELETAR


	mul 	$t0, $t8, $t8 #B ao quadrado
	
	
	
	mul 	$t3, $t6, $t9 # A X C
	mul	$t3, $t3, $t4 # 4 X AC
	neg	$t3, $t3 # 4AC NEGADO
	
	neg	$t5, $t8 # -B
	
	add	$t0, $t0, $t3 #B QUADRADO - 4AC
	
	#\N EM ASSEMBLY
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	#\N EM ASSEMBLY
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	li 	$v0,4
	la 	$a0,toBeSqrt #fala o "O inteiro que vai ser sqrt eh:"
	syscall
	
	li 	$v0,1
	move	$a0,$t0
	syscall #passa o valor de t0 para o reg a0 que vai usar para imprimir
	#-------------------------------------------------------------
	
	#CONVERTER T0 EM FLOAT, PEGAR RAIZ, DEPOIS CONVERTER DE VOLTA PARA INT
	
	mtc1 	$t0, $f0 #movendo valor de t0 para f0 (reg de ponto flutuante)
	
	cvt.s.w $f0,$f0 #CONVERTENDO f0 PARA float

	sqrt.s	$f0, $f0 #RAIZ DE B QUADRADO - 4AC --- raiz do float fica dentro do f0 novamente
	
	cvt.w.s	$f0, $f0 #CONVERTE DE FLOAT PARA INTEIRO E DEIXA NOVAMENTE EM F0
	
	mfc1	$t0, $f0 #M0VE VALOR DE F0 (RAIZ CALCULADA) PARA REGISTRADOR INTEIRO T0
	
	#\N EM ASSEMBLY
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	li 	$v0,4
	la 	$a0,alreadySqrt #O inteiro que passou por sqrt eh:"
	syscall
	
	li 	$v0,1
	move	$a0,$t0
	
	syscall #passa o valor de t0 para o reg a0 que vai usar para imprimir
	
	#-------------------------------------------------------------
	
	add 	$t1, $t5, $t0 # -b + RAIZ DE B QUADRADO - 4AC
	
	sub	$t7, $t5, $t0# -b - RAIZ DE B QUADRADO - 4AC
	
	div	$s0, $t1, $t2 # (-b + RAIZ DE B QUADRADO - 4AC) / 2A
	
	div	$s1, $t7, $t2 # (-b + RAIZ DE B QUADRADO - 4AC) / 2A
	
	
	#\N EM ASSEMBLY
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	#\N EM ASSEMBLY
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	li 	$v0,4
	la 	$a0,resultX1 #X1 :"
	syscall
	
	li 	$v0,1
	move	$a0,$s0
	syscall
	
	sw 	$s0, varX1 #GUARDA VALOR X1 NA MEMÓRIA varX1
	
	#\N EM ASSEMBLY
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	li 	$v0,4
	la 	$a0,resultX2 #X2 :"
	syscall
	
	li 	$v0,1
	move	$a0,$s1
	syscall

	sw 	$s1, varX2 #GUARDA VALOR X2 NA MEMÓRIA varX2