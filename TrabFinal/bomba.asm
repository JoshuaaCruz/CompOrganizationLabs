#########################################################################
# Trabalho Final - INE5411						#
#									#
# Integrantes:								#
# Julia Macedo de Castro (23250860) e Joshua Cruz do Amaral (24205457)	#
#########################################################################

.data

# Preços (4 bytes cada, .float)
precos:		.float 5.00, 5.20, 4.00  # [0]=comum, [1]=aditivada, [2]=alcool

ms_por_litro: 	.float 1000.0 # 1 segundo por litro

# Nomes (strings)
str_comum: 	.asciiz "Gasolina Comum"
str_aditivada: 	.asciiz "Gasolina Aditivada"
str_alcool: 	.asciiz "Alcool"

# Cupom fiscal
file_name:	 .asciiz "cupom.txt"
texto_cupom:	 .asciiz "--- POSTO JJ ---\r\n--- CUPOM FISCAL ---\r\n\r\nCombustivel: "
str_valor_cupom: .asciiz "\r\nValor Total: R$ "
rodape_cupom:    .asciiz "\r\n\r\nAgradecemos a preferência!\r\n--------------------"
err_file:        .asciiz "Erro ao criar arquivo."

buffer_num:      .space 20    # buffer para converter numeros


# Config Digital Lab Sim

# endereços de hardware
.eqv	out_lab_addr 0xFFFF0010 	# display
.eqv	in_lab_row  0xFFFF0012  	# linhas do teclado (escrita)
.eqv	in_lab_col  0xFFFF0014  	# colunas do teclado (leitura)

# varredura do display do Digital LabSim
linha1:		.byte 1
linha2:		.byte 2
linha3: 	.byte 4

# tabela LEDs para conversao (0 a F)
tabela_leds:	.byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71

# tabela de ponteiros/endereços para os nomes (4 bytes cada, .word)
nomes:  .word str_comum, str_aditivada, str_alcool

# INTAKE
prompt_principal: 	.asciiz "\nVocê está no menu inicial, escolha uma opção:\n1 - Selecionar combustível para encher\n2 - Alterar preço de algum combustível\n3 - Abastecer combustível selecionado\n4 - Alterar Modo (Litros/Valor)\n5 - Visualizar Tabela de Preços\n6 - Encerrar programa\n"

prompt_select_comb: 	.asciiz "\nSelecione o combustível: 1 - Gasolina comum; 2 - Gasolina aditivada; 3 - Álcool."

prompt_preco: 		.asciiz "\nDigite o float desejado para mudar o preço: "

prompt_modo: 		.asciiz "\nSelecione o modo de abastecimento:\n1 - Por Litros (L)\n2 - Por Valor (R$)\n"

prompt_abastecer_litros: .asciiz "\nQuantos litros de "
prompt_abastecer_valor:  .asciiz "\nQual o valor (R$) de "

# OUTAKE
resultInt: 	.asciiz "\nO inteiro selecionado eh: "

resultFloat: 	.asciiz "\nO float fornecido eh: "

num_errado: 	.asciiz "\nOpção inexistente, tente novamente...\n"

gas_selected: 	.asciiz "\nO tipo de gasolina selecionado eh: "

preco_selected: 	.asciiz "\nPreço: "
novo_preco_selected: 	.asciiz "\nNovo preço: "

preco_negativo: 	.asciiz "\nErro: O preço não pode ser negativo. Tente novamente.\n"

str_modo_litros: 	.asciiz "\nModo alterado para: Litros (L)\n"
str_modo_valor: 	.asciiz "\nModo alterado para: Valor (R$)\n"

str_a_pagar: 		.asciiz "\nTotal a pagar: R$ "
str_a_abastecer: 	.asciiz "\nTotal a abastecer: "
str_litros: 		.asciiz " Litros"

str_abastecendo: 	.asciiz "\nAbastecendo..."
str_abastecido: 	.asciiz "\nAbastecimento concluido!\n"

str_tabela_titulo: 	.asciiz "\nTabela de Preços Atual\n"
str_colon_space:   	.asciiz ": R$ "
str_newline:       	.asciiz "\n"

.text

main:

	# define "Gasolina Comum" (índice 0) como padrão para que $s1 e $s2 nunca sejam nulos
    
    	li	$s0, 0           # $s0 = índice 0
    	li 	$t0, 0           # $t0 = offset 0 (0 * 4)
    
   	# define $s1 para apontar para o preço da gas comum
    	la 	$t1, precos
    	add 	$s1, $t1, $t0   	# $s1 = &precos[0]
    
    	# define $s2 para apontar para o nome da gas comum
    	la 	$t1, nomes
    	add 	$s2, $t1, $t0   	# $s2 = &nomes[0]
    	lw 	$s2, 0($s2)     # $s2 = &str_comum


    	li 	$s3, 1 		# s3 guardara estado global da bomba, 1 -> Litros, 2 -> Dinheiro

loop_menu_principal:

	li 	$v0,4
	la 	$a0,prompt_principal	# imprime prompt
	syscall

    	jal 	ler_teclado


    	# carrega as constantes/opções de uma vez
    	li $t1, 1
    	li $t2, 2
    	li $t3, 3
    	li $t4, 4
    	li $t5, 5
    	li $t6, 6

    	beq $v0, $t1, call_select_combustivel 
    	beq $v0, $t2, call_change_preco
    	beq $v0, $t3, call_abastecer
    	beq $v0, $t4, call_change_mode          
    	beq $v0, $t5, call_view_prices      
    	beq $v0, $t6, shutDown             

	# OPÇÃO NÚMERO ERRADO #

    	li 	$v0,4
	la 	$a0, num_errado # imprime prompt
	syscall

    	j	loop_menu_principal	# jump to loop_menu_principal

# CHAMADAS JAL #

call_view_prices:
	jal view_all_prices
	j loop_menu_principal
	
call_select_combustivel:
	jal select_combustivel
	j loop_menu_principal
	
call_change_mode:
	jal change_mode
	j loop_menu_principal

call_change_preco:
    	jal change_preco
    	j loop_menu_principal

call_abastecer:
    	jal abastecer
    	j loop_menu_principal

#############################################

shutDown:
   	li   $v0, 10       # syscall para terminar a execução
   	syscall

select_combustivel:
    	li 	$v0,4
	la 	$a0, prompt_select_comb # imprime prompt
	syscall
	
	li 	$v0,5 
	syscall
	move 	$t0,$v0		#salva em t0

    	# VERIFICAR SE DIGITOU 1/2/3
    	addi	$t1, $zero, 1		# $t1 = $zero + 1, lower bound
    	addi	$t2, $zero, 3		# $t2 = $zero + 3, upper bound

    	blt	$t0, $t1, select_combustivel_erro	# if $t0 < $t1 then goto select_combustivel_erro
    	bgt	$t0, $t2, select_combustivel_erro	# if $t0 > $t2 then goto select_combustivel_erro
    
    	# Se passar então está dentro do range estabelecido
    
	li	$v0,4
	la	$a0, resultInt # fala "o seu inteiro eh: "
	syscall
	
	li	$v0,1
	move	$a0,$t0
		
	syscall		#imprime o inteiro selecionado

    	# $t0 tem a escolha (1, 2 ou 3)
    	addi    $s0, $t0, -1     # $s0 = indice (0, 1 ou 2)

    	# calcula o deslocamento (offset) em bytes
    	sll     $t0, $s0, 2       # $t0 = offset (indice * 4)
    
    	# guarda o endereço do preço
    	la      $t1, precos       # carrega o endereço base da tabela de preços
    	add     $s1, $t1, $t0     # $s1 = &precos[indice]
    
    	# guarda o endereço do nome
    	la      $t1, nomes        # carrega o endereço base da tabela de nomes
    	add     $s2, $t1, $t0     # $s2 = &nomes[indice]
    
    	# $s2 agora aponta para um ponteiro -- precisamos "dereferenciar" para pegar o endereço da string em si
    	lw      $s2, 0($s2)       # agora $s2 = endereço da string em si (ex: &str_aditivada)

    	li 	$v0, 4
    	la 	$a0, gas_selected
    	syscall
    
    	li 	$v0, 4
    	move 	$a0, $s2
    	syscall

    	jr 	$ra

select_combustivel_erro:
    	# se a validação falhou, imprime o erro e tenta de novo
    	li 	$v0, 4
    	la 	$a0, num_errado
    	syscall
    	j 	select_combustivel # pula de volta para o início da seleção


change_mode:
    	li 	$v0, 4
    	la 	$a0, prompt_modo
    	syscall
    
    	li 	$v0, 5
    	syscall
    
    	li 	$t1, 1
    	li 	$t2, 2
    
    	beq 	$v0, $t1, set_mode_litros
    	beq 	$v0, $t2, set_mode_valor

   	# se não for 1 nem 2, é um erro
    	li 	$v0, 4
    	la 	$a0, num_errado
    	syscall
    	j change_mode

set_mode_litros:
    	li 	$s3, 1      # define o modo global
    	li 	$v0, 4
    	la 	$a0, str_modo_litros
    	syscall
    	j fim_change_mode
    
set_mode_valor:
    	li 	$s3, 2      # define o modo global
    	li 	$v0, 4
    	la 	$a0, str_modo_valor
    	syscall
    	j 	fim_change_mode

fim_change_mode:
	jr 	$ra

change_preco:
    	# qual combustível alterar 
    	li 	$v0,4
    	la 	$a0, prompt_select_comb
    	syscall
    
    	# le e valida a escolha (1-3)
    	li 	$v0,5
    	syscall
    	move 	$t0, $v0 	# $t0 = escolha (1, 2 ou 3)

    	# VERIFICAR SE DIGITOU 1/2/3
    	addi	$t1, $zero, 1 		# $t1 = $zero + 1, lower bound
    	addi	$t2, $zero, 3		# $t2 = $zero + 3, upper bound

    	blt	$t0, $t1, change_preco_erro	# if $t0 < $t1 then goto change_preco_erro
    	bgt	$t0, $t2, change_preco_erro	# if $t0 > $t2 then goto change_preco_erro

    	li	$v0,4
	la	$a0,gas_selected	# imprime nome da gas selected
	syscall
    
    	addi    $t1, $t0, -1    	# $t1 = índice (0, 1 ou 2)
    	sll     $t1, $t1, 2     	# $t1 = offset (0, 4, ou 8)

    	# encontra e imprime o NOMW
    	la      $t4, nomes      	# carrega end. base da tabela de nomes
    	add     $t4, $t4, $t1   	# $t4 = &nomes[indice] (usando o offset $t1)
    	lw      $t4, 0($t4)     	# $t4 = &str_... (endereço final da string)
    
    	li      $v0,4
    	move    $a0, $t4
    	syscall

    	# calcula o endereço DO PREÇO
    	la	$t2, precos
    	add 	$t2, $t2, $t1       	# $t2 = &precos[indice] (usando o MESMO offset $t1)

    	#imprime preco atual
    	li	$v0,4
	la	$a0,preco_selected 	# imprime preco da gas selected
	syscall
    
    	# carrega o VALOR do preço da memória para o registrador de float
    	l.s 	$f12, 0($t2)        	# carrega o float de &precos[indice] para $f12
    
    	# imprime o VALOR (float) que esta em $f12
    	li      $v0, 2        
    	syscall
    
change_preco_prompt_loop:

    	li 	$v0,4
	la 	$a0,prompt_preco # imprime prompt para mudar preco
	syscall
    
   	li	$v0,6   	# take float to f0
    	syscall
	
	mtc1	$zero,$f2 	# carrega 0.0 em $f2 para comparação

    	c.lt.s 	$f0, $f2       	# compara: $f0 < 0.0 ?
    	bc1t preco_negativo_erro # se for menor pula para o erro

    	s.s     $f0, 0($t2) 	# salva de volta no endereço calculado

    	# PRINT DO NOVO VALOR PEGANDO DO ENDEREÇO SALVO
    	li	$v0,4
	la	$a0, novo_preco_selected
	syscall

    	l.s 	$f12, 0($t2)    	# carrega o NOVO float da memória
    	li 	$v0, 2          	# syscall 2: print_float
    	syscall

    	jr	$ra

preco_negativo_erro:
    	li 	$v0, 4
    	la 	$a0, preco_negativo 	# imprime "Erro: O preço não pode ser negativo..."
    	syscall
    	j change_preco_prompt_loop 	# pula de volta para pedir o preço

change_preco_erro:
   	# se a validação falhou, imprime o erro e tenta de novo
    	li 	$v0, 4
    	la 	$a0, num_errado
    	syscall
    	j 	change_preco

abastecer:
    	# salvar retorno na pilha
    	addi 	$sp, $sp, -4
    	sw 	$ra, 0($sp)
    
   	# verifica o modo salvo em $s3
    	li 	$t0, 1
    	beq 	$s3, $t0, abastecer_litros
    
    	# se não for 1, deve ser 2 (modo abastecer por valor)
    	j 	abastecer_valor

abastecer_litros:
    	# pergunta: "Quantos litros de [tal combustivel]?"
    	li 	$v0, 4
    	la 	$a0, prompt_abastecer_litros
    	syscall
    	li 	$v0, 4
    	move 	$a0, $s2   # imprime o nome do combustível
    	syscall

    	li 	$v0, 4
    	la 	$a0, preco_selected # "\nPreço: "
    	syscall

    	# carrega o preço do combustível selecionado
    	l.s 	$f2, 0($s1) 	# $f2 = preço/litro (do endereço em $s1)
    
    	li 	$v0, 2
    	mov.s 	$f12, $f2  	# copia $f2 (o preço) para $f12 (print)
    	syscall
    
    	# le o float (litros)
    	li 	$v0, 6
    	syscall         # $f0 = litros
    
    	# calcula o total: total = litros * preco
    	mul.s 	$f4, $f0, $f2
    
    	# imprime: "Total a pagar: R$ [valor]"
    	li 	$v0, 4
    	la 	$a0, str_a_pagar
    	syscall
    
    	li 	$v0, 2
    	mov.s 	$f12, $f4 
    	syscall
    
    	# imprime "Abastecendo..."
    	li 	$v0, 4
    	la 	$a0, str_abastecendo
    	syscall
    	
    	# $f0 contém a quantidade de Litros
    
    	# carrega a constante de vazão (ms/litro)
    	l.s 	$f6, ms_por_litro
    
    	# calcula o delay total (float)
    	# $f8 = $f0 (litros) * $f6 (ms_por_litro)
    	mul.s 	$f8, $f0, $f6
    
    	# converte o delay (float) para um inteiro (word)
    	cvt.w.s $f8, $f8
    
    	# move o resultado inteiro do coprocessador (FPU) para a CPU
    	# $a0 = $f8 (agora como um inteiro)
    	mfc1 	$a0, $f8
    
    	# chama o delay com o valor em $a0
    	jal 	delay_ms
    
    	# imprime "Abastecimento concluido!"
    	li 	$v0, 4
    	la 	$a0, str_abastecido
    	syscall
    
    	# o valor total a pagar está em $f4 (float)
    	
    	# convertemos para inteiro e salvar em $s7
    	cvt.w.s $f4, $f4      # converte o float $f4 para inteiro (word)
    	mfc1    $s7, $f4      # move do processador matemático para $s7

    	# cupom fiscal
    	jal 	gerar_cupom
    
    	j 	fim_abastecer

abastecer_valor:
    	# pergunta: "Qual o valor (R$) de [tal combustivel]?"
    	li 	$v0, 4
    	la 	$a0, prompt_abastecer_valor
    	syscall
    	li 	$v0, 4
    	move 	$a0, $s2   	# imprime o nome do combustível
    	syscall
    
    	# le o float (valor)
    	li 	$v0, 6
    	syscall         # $f0 = valor
    
    	# carrega o preço do combustível selecionado
    	l.s 	$f2, 0($s1) 	# $f2 = preço/litro (do endereço em $s1)
    
    	li 	$v0, 4
    	la 	$a0, preco_selected 	# imprime "\nPreço: "
    	syscall
    
    	li 	$v0, 2
    	mov.s 	$f12, $f2  		# $f2 (o preço) vai pra $f12 (print)
    	syscall
    
    	# calcula o total: litros = valor / preco
    	div.s $f4, $f0, $f2
    
    	# imprime: "Total a abastecer: [x] Litros"
    	li 	$v0, 4
    	la 	$a0, str_a_abastecer
    	syscall
    
    	li 	$v0, 2
   	mov.s 	$f12, $f4  	# syscall 2 imprime $f12
    	syscall
    
    	li 	$v0, 4
    	la 	$a0, str_litros
    	syscall

    	li 	$v0, 4
    	la 	$a0, str_abastecendo
    	syscall
    
    	# quantidade de L está em f4

    	# carrega a constante de vazão (ms/litro)
    	l.s 	$f6, ms_por_litro      # $f6 = 1500.0
    
    	# calcula o delay total (float)
    	# $f8 = $f4 (litros) * $f6 (ms_por_litro)
    	mul.s 	$f8, $f4, $f6
    
    	# converte o delay (float) para um inteiro (word)
    	cvt.w.s $f8, $f8
    
    	# $a0 = $f8 (agora como um inteiro)
    	mfc1 	$a0, $f8
    
    	# chama o delay com o valor em $a0
    	jal 	delay_ms

    	# imprime "Abastecimento concluido!"
    	li 	$v0, 4
    	la 	$a0, str_abastecido
    	syscall
    
    	# o valor total a pagar foi digitado pelo usuário e está em $f0
    	# convertemos para inteiro e salvar em $s7
    
    	cvt.w.s $f0, $f0      # converte o float $f0 para inteiro (word)
    	mfc1    $s7, $f0      # move do processador matemático para $s7
    
    	# cupom fiscal
    	jal 	gerar_cupom

     	j 	fim_abastecer

fim_abastecer:
	lw 	$ra, 0($sp)	# pega endereço para o menu na pilha
	addi 	$sp, $sp, 4
	
	jr 	$ra		# volta para menu principal


delay_ms:
    	# é esperado que o tempo de espera seja salvo em a0 antes da chamada deste procedimento

    	move 	$t1, $a0        # $t1 = delay (ms)
    
    	li 	$v0, 30           
    	syscall              	# $a0 = tempo atual (em ms)
    
    	add 	$t0, $a0, $t1   # $t0 = tempo_alvo = tempo_atual + delay
    
delay_loop:
    	li 	$v0, 30           
    	syscall        		# $a0 = novo tempo atual
    
    	blt 	$a0, $t0, delay_loop 	# if (novo_tempo_atual < tempo_alvo), continua no loop
    
    	# se passou entao tempo alvo passou
    	jr 	$ra


view_all_prices:
    	li 	$v0, 4
    	la 	$a0, str_tabela_titulo
    	syscall

    	# COMUM
    	li 	$v0, 4
    	la 	$a0, str_comum         
    	syscall
    
    	li	$v0, 4
    	la 	$a0, str_colon_space 
    	syscall
    
    	la 	$t0, precos           # carrega o endereço base de precos
    	l.s 	$f12, 0($t0)          # carrega precos[0] (offset 0)
    	li 	$v0, 2
    	syscall                   
    
    	li 	$v0, 4
    	la 	$a0, str_newline      
    	syscall

    	# ADITIVADA 
    	li 	$v0, 4
    	la 	$a0, str_aditivada     
    	syscall
    
    	li 	$v0, 4
    	la 	$a0, str_colon_space   
    	syscall
    
    	la 	$t0, precos
    	l.s 	$f12, 4($t0)          # carrega precos[1] (offset 4)
    	li 	$v0, 2
    	syscall
    
    	li 	$v0, 4
    	la 	$a0, str_newline
    	syscall

    	# ÁLCOOL 
    	li 	$v0, 4
    	la 	$a0, str_alcool        
    	syscall
    
    	li 	$v0, 4
    	la 	$a0, str_colon_space 
    	syscall
    
    	la 	$t0, precos
    	l.s 	$f12, 8($t0)          # carrega precos[2] (offset 8)
    	li 	$v0, 2
    	syscall
    
    	li 	$v0, 4
    	la 	$a0, str_newline
    	syscall

    	jr 	$ra


# PROCEDIMENTOS DIGITAL LAB SIM #

ler_teclado:
    	addi 	$sp, $sp, -4
    	sw   	$ra, 0($sp)

scan_inicio:
    	li   	$t8, 0xFFFF0012     # row
    	li   	$t9, 0xFFFF0014     # col

    	# TESTE LINHA 1 (0, 1, 2, 3)
    	li   	$t0, 1
    	sb   	$t0, 0($t8)
    	lb   	$t1, 0($t9)
    	andi 	$t2, $t1, 0xF0      # ignora bits de linha pega só coluna
    	bnez 	$t2, achou_L1       # se t2 != 0, tem coluna apertada

    	# TESTE LINHA 2 (4, 5, 6, 7)
    	li   	$t0, 2
    	sb   	$t0, 0($t8)
    	lb   	$t1, 0($t9)
    	andi 	$t2, $t1, 0xF0
    	bnez 	$t2, achou_L2

    	# TESTE LINHA 3 (8, 9, A, B)
    	li   	$t0, 4
    	sb   	$t0, 0($t8)
    	lb   	$t1, 0($t9)
    	andi 	$t2, $t1, 0xF0
    	bnez 	$t2, achou_L3

    	j    	scan_inicio         # nenhuma tecla, scaneia novamente

achou_L1:
    	li   	$v0, 0              # base numerica da linha 1 (0)
    	move 	$t1, $t2            # move o valor para t1
    	j    	calcula_final

achou_L2:
    	li   	$v0, 4              # baseda linha 2 (4)
    	move 	$t1, $t2
    	j    	calcula_final

achou_L3:
    	li   	$v0, 8              # base da linha 3 (8)
    	move 	$t1, $t2
    	j    	calcula_final

calcula_final:
    	# verifica os bits altos (cols: 16, 32, 64, 128)
    	beq  	$t1, 16, retorno    # 0x10 -> col 1 (+0)
    	beq  	$t1, 32, soma1      # 0x20 -> col 2 (+1)
    	beq  	$t1, 64, soma2      # 0x40 -> col 3 (+2)
    	beq  	$t1, 128, soma3     # 0x80 -> col 4 (+3)
    
    	j    	scan_inicio     

soma1:
    	addi 	$v0, $v0, 1
    	j    	esperar_soltar
soma2:
    	addi 	$v0, $v0, 2
    	j    	esperar_soltar
soma3:
    	addi 	$v0, $v0, 3
    	j    	esperar_soltar
retorno:
    	j    	esperar_soltar

esperar_soltar:
    	lb   	$t5, 0xFFFF0014             # le o teclado
    	andi 	$t5, $t5, 0xF0              # aplica mascara para ver apenas as colunas
    	bnez 	$t5, esperar_soltar         # trava enquanto tiver tecla apertada
    
    	# mostra display e retorna
    	move 	$a0, $v0
    	jal  	mostrar_display     
    
    	lw   	$ra, 0($sp)
    	addi 	$sp, $sp, 4
    	jr   	$ra

# Mostrar no display
mostrar_display:
    	la   	$t0, tabela_leds     # endereço base da tabela
    	add  	$t0, $t0, $a0        # soma o offset (número a exibir)
    	lb   	$t1, 0($t0)          # carrega o padrão de bits do LED
    
    	li   	$t2, 0xFFFF0010      # endereço do display
    	sb   	$t1, 0($t2)          # escreve no display
    
    	jr   	$ra
    	

# PROCEDIMENDO CRIAR CUPORM #
gerar_cupom:
    	addi 	$sp, $sp, -4
    	sw   	$ra, 0($sp)

    	# abrir arquivo
    	li   	$v0, 13
    	la   	$a0, file_name
    	li   	$a1, 1
    	li   	$a2, 0
    	syscall
    	move 	$s6, $v0        
    	bltz 	$s6, fim_cupom_erro

    	# escrever texto
    	la   	$a0, texto_cupom
    	jal 	strlen
    	move 	$a2, $v0
    	li   	$v0, 15
    	move 	$a0, $s6
    	la 	$a1, texto_cupom
    	syscall

    	# escrever nome gasolina
   	move 	$a0, $s2
   	jal 	strlen
   	move 	$a2, $v0
    	li   	$v0, 15
    	move 	$a0, $s6
    	move 	$a1, $s2
    	syscall

    	# escrever valor
    	la   	$a0, str_valor_cupom
    	jal 	strlen
    	move 	$a2, $v0
    	li   	$v0, 15
    	move 	$a0, $s6
    	la 	$a1, str_valor_cupom
    	syscall

    	# conversao de int para string
    	move 	$t0, $s7        # pega o valor inteiro (do abastecer)
    	la   	$t1, buffer_num
    	add  	$t1, $t1, 10
    	sb   	$zero, 0($t1)   # null terminator
    	li   	$t2, 10

loop_conv:
    	div  	$t0, $t2
    	mflo 	$t0
    	mfhi 	$t3
    	add  	$t3, $t3, 48    # ASCII
    	sub  	$t1, $t1, 1
    	sb   	$t3, 0($t1)
    	bnez 	$t0, loop_conv
    
    	move 	$a0, $t1        # prepara para contar tamanho
    	move 	$s4, $t1        # salva endereço $s4
    
    	jal 	strlen
    	move 	$a2, $v0        # tamanho
    
    	li   	$v0, 15
    	move 	$a0, $s6        # file descriptor
    	move 	$a1, $s4        # usa endereço salvo em $s4
    	syscall


    	# rodape
    	la   	$a0, rodape_cupom
    	jal 	strlen
    	move	$a2, $v0
    	li   	$v0, 15
    	move 	$a0, $s6
    	la	$a1, rodape_cupom
    	syscall

    	# fechar arquivo
    	li   	$v0, 16
    	move 	$a0, $s6
    	syscall

fim_cupom_erro:
    	lw   	$ra, 0($sp)
    	addi 	$sp, $sp, 4
    	jr   	$ra

strlen:
    	move 	$t0, $a0
    	li   	$t1, 0
    	
sl_loop:
    	lb   	$t2, 0($t0)
    	beqz 	$t2, sl_end
    	addi 	$t0, $t0, 1
    	addi 	$t1, $t1, 1
    	j    	sl_loop
    	
sl_end:
    	move 	$v0, $t1
    	jr   	$ra
