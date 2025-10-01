.data
    	promptSeno:      .asciiz "Entre com um valor (em radianos) para calcular o seno: "
    	result:          .asciiz "O double digitado fornecido eh: "
    	estimativaFinal: .asciiz "\nSeno aproximado (serie) = "
   	  newline:         .asciiz "\n"

.text

main:
	    li  $v0, 4
    	la  $a0, promptSeno
    	syscall
    	
    	li  $v0, 7           # le double
    	syscall              # valor vai para f0
    	
	    # confirma valor
    	li  $v0, 4
    	la  $a0, result
    	syscall
    	li  $v0, 3
    	mov.d $f12, $f0
    	syscall
    
    	li  $v0, 4
    	la  $a0, newline
    	syscall
    	
    	mov.d   $f12, $f0    # argumento em f12
    	jal     SENO
    	mov.d   $f2, $f0     # guarda seno aproximado em f2
    	
    	# imprime resultado
    	li      $v0, 4
    	la      $a0, estimativaFinal
    	syscall
    	li      $v0, 3
    	mov.d   $f12, $f2
    	syscall
    
    	li  $v0, 4
    	la  $a0, newline
     	syscall
   	
   	
   	  li $v0, 10
    	syscall
    
# entrada: f12 = x
# saida: f0 = seno(x) aproximado
SENO:
	    li      $t0, 20          # numero de termos = 20
    	li      $t1, 0           # k = 0 (contador)
    	
    	# f0 = 0.0
    	li	$t5, 0
    	mtc1	$t5, $f0
    	cvt.d.w	$f0, $f0
    	
loop_seno:
	    bge     $t1, $t0, fim_seno   # se k >= 20 sai
    
    	# expoente = 2k + 1
    	sll     $t2, $t1, 1
    	addi    $t2, $t2, 1
    
    	# f2 = x^(2k+1)
    	li      $t5, 1
    	mtc1    $t5, $f2
    	cvt.d.w $f2, $f2
    	move    $t3, $t2
      
potencia_loop:
    	beqz    $t3, fim_potencia
    	mul.d   $f2, $f2, $f12
    	addi    $t3, $t3, -1
    	j       potencia_loop
      
fim_potencia:
    	# f4 = (2k+1)!
    	li      $t5, 1
    	mtc1    $t5, $f4
    	cvt.d.w $f4, $f4
    	move    $t3, $t2
      
fatorial_loop:
    	beqz    $t3, fim_fatorial
    	mtc1    $t3, $f6
    	cvt.d.w $f6, $f6
    	mul.d   $f4, $f4, $f6
    	addi    $t3, $t3, -1
    	j       fatorial_loop
      
fim_fatorial:
    	# f8 = (-1)^k
    	andi    $t4, $t1, 1
    	beqz    $t4, positivo
    	li      $t5, -1
    	mtc1    $t5, $f8
    	cvt.d.w $f8, $f8
    	j       sinal_ok
      
positivo:
    	li      $t5, 1
    	mtc1    $t5, $f8
   	  cvt.d.w $f8, $f8
sinal_ok:
    	# termo = ((-1)^k * x^(2k+1)) / (2k+1)!
    	mul.d   $f10, $f8, $f2
    	div.d   $f10, $f10, $f4
    
    	# soma acumulador
    	add.d   $f0, $f0, $f10
    
    	# proximo k
    	addi    $t1, $t1, 1
    	j       loop_seno
    	
fim_seno:
      jr $ra
