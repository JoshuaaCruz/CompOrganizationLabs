.data
	promptRaiz: 	.asciiz "Entre com um inteiro para a raiz ser calculada: "
	promptN: 	.asciiz "Entre com um inteiro N para ser número de iterações: "	
	result: 	.asciiz "O double digitado fornecido eh: "
	resultReturn:	.asciiz "O valor de retorno que main recebeu eh: "
	currentLoop:	.asciiz "O n do loop atual: "
	estimativaFinal:.asciiz "\nEstimativa final= "
	resultadoSqrt:  .asciiz "Resultado oficial (sqrt.d) = "
	erroAbsoluto:   .asciiz "\nErro Absoluto = "
	
	newline:	.asciiz "\n"
	hello: 		.asciiz "Oi usuário ;D "
	var: 		.word 7 #8 BYTES
	
	estimativa:	.word 1 #estimativa inicial pedida pelo exercicio
	
	
	valor1: 	.word 0

.text
# Início do programa
main:

	jal	TAKE_NUMs
	#PASSA COMO RETORNO n em V0, e X PONTO FLUT PREC DUPLA EM F0
	
	
	move	$t7,$v0 #n
	
	#CONFIRMANDO SE RECEBEU CERTO
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	li 	$v0,4
	la 	$a0,resultReturn #fala o seu inteiro eh:
	syscall
	
	li 	$v0,1
	move	$a0,$t7
	syscall #testando vendo se o valor retorno foi certo
	
	#####
	#AGORA COM VALOR DE X E N CERTO, PODEMOS CHAMAR PROCEDIM RAIZ_QUADRADA
	#PADRÃO DIZ QUE ARGUMENTOS INTEIROS DEVEM PASSAR EM A0-A3 E DOUBLE F12-15
	
	move	$a0,$t7
	mov.d	$f10,$f0	#f10 usarei para calcular sqrt oficial
	mov.d	$f12,$f0	#f12 padrão de argumento	
	
	jal	RAIZ_QUADRADA #recebe os valores acima de argumento
	
	mov.d	$f2,$f0	#volta de novo o resultado da estimativa para f2
		
	#########################################################[
	#calculando sqrt e comparando
	
	#  Calcula a raiz usando a instrução nativa do MIPS.
    	sqrt.d  $f4, $f10   # $f4 = sqrt(x), salvei x em f10 lá inicio
    	#  Calcula o erro absoluto: abs(estimativaFinal - resultadoSqrt)
    	sub.d   $f6, $f2, $f4   # Diferença
    	abs.d   $f6, $f6        # Valor absoluto da diferença
    	
    	
    	
    	# Imprime todos os resultados.
    	# Imprime estimativa final
   	li      $v0, 4
    	la      $a0, estimativaFinal
    	syscall
    	li      $v0, 3          # Syscall para imprimir double
    	mov.d   $f12, $f2       # Argumento é o seu resultado
    	syscall
	
	li 	$v0,4
	la 	$a0,newline
	syscall
	
    	# Imprime o resultado oficial do sqrt.d
    	li      $v0, 4
    	la      $a0, resultadoSqrt
    	syscall
    	li      $v0, 3
    	mov.d   $f12, $f4       # Argumento é o resultado do sqrt.d
    	syscall

    	# Imprime o erro absoluto
    	li      $v0, 4
    	la      $a0, erroAbsoluto
    	syscall
    	li      $v0, 3
    	mov.d   $f12, $f6       # Argumento é o erro
    	syscall
    	
	###################################################
	li $v0,10 #ENCERAR O PROGRAMA
	syscall

RAIZ_QUADRADA:
	#pega os parâmetros
	move	$s0,$a0		#N em s0, como vamos usar temporários ag para as contas não faz sentido ficar usando t0
	mov.d	$f0,$f12	#x
	lwc1	$f2,estimativa
	cvt.d.w	$f2,$f2 	#pega nossa estimativa da memória e já salva em reg ponto flutuante já que vamos usar para cálculos
	#aparentemente redundante mas é o padrão, talvez não precisasse
	
verifica:
	
	bnez	$s0,loop_estim
	
	#após n loops, f2 guardará a ultima estimativa, como padrão valores retorno devem ir no f0/f1
	mov.d	$f0,$f2
	
	jr	$ra
	
loop_estim:

	li 	$v0,4
	la 	$a0,newline
	syscall
	li 	$v0,4
	la 	$a0,currentLoop #fala seu loop eh:
	syscall
	li   $v0, 1
    	move $a0, $s0
    	syscall
    	
#n em s0
#f2 estimativa atual
#f0 x
    	
    	#fazer estimativa
    	#x/estimativa
    	div.d	$f4, $f0, $f2 #armazena x/est em f4
    	#somar resultado anterior +estimativa
    	add.d	$f4,$f4,$f2
    	#dividir /2
    	li	$t0,2
    	mtc1	$t0,$f6
    	cvt.d.w	$f6,$f6
    	div.d 	$f4,$f4,$f6
    	#igualar a estimtiva
    	mov.d	$f2,$f4
    	
    	
	addi	$s0,$s0,-1
	j	verifica

TAKE_NUMs:
	li 	$v0,4
	la 	$a0,hello
	syscall
	
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	li 	$v0,4
	la 	$a0,promptRaiz #imprime prompt
	syscall
	

	li 	$v0,7 #pega double x user
	syscall
	
	li 	$v0,4
	la 	$a0,result #fala o seu double eh:
	syscall
	
	li 	$v0,3
	mov.d	$f12,$f0
	syscall #imprime o double, endereço f0
		
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	################################
	#PEGANDO N = NUM ITERAÇÕES
	
	li 	$v0,4
	la 	$a0,promptN #imprime prompt
	syscall
	
	li 	$v0,5 #pega n
	syscall
	move 	$t1,$v0 #salva em t1
	
	li 	$v0,4
	la 	$a0,result #fala o seu inteiro eh:
	syscall
	
	li 	$v0,1
	move	$a0,$t1
	syscall #imprime  n
	
	move	$v0,$t1	#usa padrão que v0/v1 retorno. poderia usar stack também
	
	jr 	$ra
	
