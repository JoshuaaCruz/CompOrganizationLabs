.data
	varX1: . word 0
	varX2: . word 0
	
	vara: . word 1
	varb: . word 3
	varc: . word 4

.text

main:
	
	li	$t2, 2 # Carrega o valor 2 em $t2 (valor inteiro constante)
	
	lw	$t6, vara
	mul	$t2, $t2, $t6 #2A
	
	
	li	$t4, 4 # Carrega o valor 4 em $t4 (valor inteiro constante)

	
	lw	$t8, varb # Carrega o valor B em $t8 
	lw	$t9, varc # Carrega o valor C em $t9


	mul 	$t0, $t8, $t8 #B ao quadrado
	
	
	
	mul 	$t3, $t6, $t9 # A X C
	mul	$t3, $t3, $t4 # 4 X AC
	neg	$t3, $t3 # 4AC NEGADO
	
	neg	$t5, $t8 # -B
	
	
	
	
	add	$t0, $t0, $t3 #B QUADRADO - 4AC
	
	sqrt.s	$t0, $t0 #RAIZ DE B QUADRADO - 4AC
	
	add 	$t1, $t5, $t0 # -b + RAIZ DE B QUADRADO - 4AC
	
	sub	$t7, $t5, $t0# -b - RAIZ DE B QUADRADO - 4AC
	
	div	$s0, $t1, $t2 # (-b + RAIZ DE B QUADRADO - 4AC) / 2A
	
	