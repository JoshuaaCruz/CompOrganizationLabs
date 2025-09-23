.data

	
	prompt: 	.asciiz "Qual o nome de arquivo desejado? "
	result: 	.asciiz "O inteiro eh: "
	newline:	.asciiz "\n"
	
	matA:		.word 1,2,3,0,1,4,0,0,1
	matB:		.word 1,-2,5,0,1,-4,0,0,1
	
	matResult:	.space 36 # matriz 3x3 = 9 x 4(tamanho 4bytes)=36
	
	fileNameBuffer:	.space 100 #reserva 99 bytes para o nome de arquivo escolhido pelo usuário, 0 100° é o caractere nulo '\0'

.text

main:
	jal PROC_NOME
	
	#CRIANDO ARQUIVO PARA ESCRITA (NÃO EXISTENTE)
	li	$v0,13	#COMANDO ABRIR NOVO ARQUIVO
	la	$a0,fileNameBuffer	#CARREGA NOME DO ARQUIVO A SER ABERTO
	li	$a1,1	#ABERTO PARA ESCRITA (pesquisar de flags)
	li	$a1,0	#MODO IGNORADO???PESQUISAR
	syscall
	move	$s6,$v0	#salva o descritor do arquivo para uso no fechamento
	
	#############################
	#ESCREVE NO ARQUIVO ABERTO
	
	li	$v0,15	#comando escreve arquivo
	move	$a0,$s6	#descritor do arquivo passado
	
	
	
	
	li 	$v0,10 #ENCERAR O PROGRAMA PARA EVITAR LOOP
	syscall

PROC_TRANSP: #TRANSPÕE UMA MATRIZ --FOLHA -- SIGNIFICA QUE NÃO CHAMA OUTRO PROCEDIMENTO-- É CHAMADO POR PROC_MULC

PROC_MULC: #MULTIPLICA 2 MATRIZES -- NÃO FOLHA - SIGNIFICA QUE ELE CHAMA OUTRO PROCEDIMENTO (CHAMA PROC_TRANSP)


PROC_NOME: #SOLICITAR AO USER PELO NOME DO ARQUIVO .txt
	
	li 	$v0,4
	la 	$a0,prompt #imprime prompt
	syscall
	

	li 	$v0,8 #pega inteiro do user
	
	la 	$a0, fileNameBuffer #endereço do buffer em $a0
	li	$a1,100 # Tamanho máximo da string em $a1
	syscall	# A string é lida e salva no buffer
	
	
	
	li 	$v0,4
	la	$a0,fileNameBuffer
	syscall #imprime a string do user
	
	li 	$v0,4
	la 	$a0,newline
	syscall
	
	la $v0, fileNameBuffer
	
	jr 	$ra
	
	
