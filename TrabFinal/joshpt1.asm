.data

# Preços (4 bytes cada, .float)
precos: .float 5.00, 5.20, 4.00  # [0]=comum, [1]=aditivada, [2]=alcool

# Nomes (strings)
str_comum: .asciiz "Gasolina Comum"
str_aditivada: .asciiz "Gasolina Aditivada"
str_alcool: .asciiz "Alcool"

# Tabela de ponteiros/endereços para os nomes (4 bytes cada, .word)
nomes:  .word str_comum, str_aditivada, str_alcool

#INTAKE
prompt_principal: .asciiz "\nVocê está no menu inicial, escolha uma opção:\n1 - Selecionar combustível para encher\n2 - Alterar preço de algum combustível\n3 - Abastecer combustível selecionado\n4 - Encerrar programa\n"

prompt_select_comb: .asciiz "\nSelecione o combustível: 1 - gasolina comum; 2 - Gasolina aditivada; 3 - Álcool."

prompt_preco: .asciiz "\nDigite o float desejado para mudar o preço: "

#OUTAKE
resultInt: .asciiz "\nO inteiro selecionado eh: "

resultFloat: .asciiz "\nO float fornecido eh: "

num_errado: .asciiz "\nOpção inexistente, tente novamente...\n"

gas_selected: .asciiz "\nO tipo de gasolina selecionado eh: "

preco_selected: .asciiz "\nPreço: "
novo_preco_selected: .asciiz "\nNovo preço: "

preco_negativo: .asciiz "\nErro: O preço não pode ser negativo. Tente novamente.\n"

.text

main:
    # Define "Gasolina Comum" (índice 0) como padrão para que $s1 e $s2 nunca sejam nulos.
    
    li $s0, 0           # $s0 = índice 0
    li $t0, 0           # $t0 = offset 0 (0 * 4)
    
    # Define $s1 para apontar para o preço da gas comum
    la $t1, precos
    add $s1, $t1, $t0   # $s1 = &precos[0]
    
    # Define $s2 para apontar para o nome da gas comum
    la $t1, nomes
    add $s2, $t1, $t0   # $s2 = &nomes[0]
    lw $s2, 0($s2)      # $s2 = &str_comum

loop_menu_principal:

	li 	$v0,4
	la 	$a0,prompt_principal #imprime prompt
	syscall

    li 	$v0,5 #pega inteiro / opção selecionada e guarda em v0
	syscall


    # Carrega as constantes/opções de uma vez
    li $t1, 1
    li $t2, 2
    li $t3, 3
    li $t4, 4

    beq $v0, $t1, select_combustivel # if (escolha == 1)
    beq $v0, $t2, change_preco     # if (escolha == 2) -> AINDA NÃO IMPLEMENTADO
    # beq $v0, $t3, abastecer        # if (escolha == 3) -> AINDA NÃO IMPLEMENTADO
    beq $v0, $t4, shutDown           # if (escolha == 4)

############## OPÇÃO NÚMERO ERRADO ##############################
    li 	$v0,4
	la 	$a0, num_errado #imprime prompt
	syscall

    j		loop_menu_principal				# jump to loop_menu_principal

shutDown:
   	li   $v0, 10       # syscall para terminar a execução
   	syscall

select_combustivel:
    li 	$v0,4
	la 	$a0, prompt_select_comb #imprime prompt
	syscall
	
	li 	$v0,5 
	syscall
	move 	$t0,$v0 #salva em t0

    #VERIFICAR SE DIGITOU 1/2/3
    addi	$t1, $zero, 1 			# $t1 = $zero + 1, lower bound
    addi	$t2, $zero, 3			# $t2 = $zero + 3, upper bound

    blt		$t0, $t1, select_combustivel_erro	# if $t0 < $t1 then goto select_combustivel_erro
    bgt		$t0, $t2, select_combustivel_erro	# if $t0 > $t2 then goto select_combustivel_erro
    
    #Se passar então está dentro do range estabelecido
    
	li 	    $v0,4
	la 	    $a0, resultInt #fala o seu inteiro eh:
	syscall
	
	li 	    $v0,1
	move	$a0,$t0
		
	syscall #imprime o inteiro selecionado

    # $t0 tem a escolha (1, 2 ou 3)
    addi    $s0, $t0, -1     # $s0 = indice (0, 1 ou 2)

    # Calcula o deslocamento (offset) em bytes
    sll     $t0, $s0, 2       # $t0 = offset (indice * 4)
    
    # Guarda o ENDEREÇO do preço
    la      $t1, precos        # Carrega o endereço base da tabela de preços
    add     $s1, $t1, $t0     # $s1 = &precos[indice]. Guarda isso!
    
    # Guarda o ENDEREÇO do nome
    la      $t1, nomes         # Carrega o endereço base da tabela de nomes
    add     $s2, $t1, $t0     # $s2 = &nomes[indice]. Guarda isso!
    
    # $s2 agora aponta para um ponteiro. Precisamos "dereferenciar" para pegar o endereço da string em si.
    lw      $s2, 0($s2)        # Agora $s2 = endereço da string em si (ex: &str_aditivada)

    li $v0, 4
    la $a0, gas_selected
    syscall
    
    li $v0, 4
    move $a0, $s2
    syscall

    j		loop_menu_principal				# jump to loop_menu_principal

select_combustivel_erro:
    # Se a validação falhou, imprime o erro e tenta DE NOVO
    li $v0, 4
    la $a0, num_errado
    syscall
    j select_combustivel # Pula de volta para o *início* da seleção

change_preco:

    # qual combustível alterar 
    li $v0,4
    la $a0, prompt_select_comb
    syscall
    
    # 2. Lê e valida a escolha (1-3)
    li $v0,5
    syscall
    move $t0, $v0 # $t0 = escolha (1, 2 ou 3)

    #VERIFICAR SE DIGITOU 1/2/3
    addi	$t1, $zero, 1 			# $t1 = $zero + 1, lower bound
    addi	$t2, $zero, 3			# $t2 = $zero + 3, upper bound

    blt		$t0, $t1, change_preco_erro	# if $t0 < $t1 then goto change_preco_erro
    bgt		$t0, $t2, change_preco_erro	# if $t0 > $t2 then goto change_preco_erro

    li 	    $v0,4
	la 	    $a0,gas_selected #imprime nome da gas selected
	syscall
    
    addi    $t1, $t0, -1    # $t1 = índice (0, 1 ou 2)
    sll     $t1, $t1, 2     # $t1 = offset (0, 4, ou 8)

    # Encontra e imprime o NOME
    la      $t4, nomes      # Carrega end. base da tabela de nomes
    add     $t4, $t4, $t1   # $t4 = &nomes[indice] (usando o offset $t1)
    lw      $t4, 0($t4)     # $t4 = &str_... (endereço final da string)
    
    li      $v0,4
    move    $a0, $t4
    syscall

    #Calcula o endereço DO PREÇO
    la $t2, precos
    add $t2, $t2, $t1       # $t2 = &precos[indice] (usando o MESMO offset $t1)

    #imprime preco atual
    li 	    $v0,4
	la 	    $a0,preco_selected #imprime preco da gas selected
	syscall
    
    # Carrega o VALOR do preço da memória para o registrador de float
    l.s $f12, 0($t2)        # Carrega o float de &precos[indice] para $f12
    
    # Imprime o VALOR (float) que está em $f12
    li      $v0, 2        
    syscall
    
change_preco_prompt_loop:

    li 	$v0,4
	la 	$a0,prompt_preco #imprime prompt para mudar preco
	syscall
    
    li		$v0,6   #take float to f0
    syscall
	
	mtc1	$zero,$f2 # Carrega 0.0 em $f2 para comparação

    c.lt.s $f0, $f2       # Compara: $f0 < 0.0 ?
    bc1t preco_negativo_erro # Se for menor pula para o erro

    s.s     $f0, 0($t2) #salva de volta no endereço calculado

    #PRINT DO NOVO VALOR PEGANDO DO ENDEREÇO SALVO

    li 	    $v0,4
	la 	    $a0, novo_preco_selected
	syscall

    l.s $f12, 0($t2)    # Carrega o NOVO float da memória
    li $v0, 2          # Syscall 2: print_float
    syscall

    j		loop_menu_principal				# jump to loop_menu_principal

preco_negativo_erro:
    li $v0, 4
    la $a0, preco_negativo # Imprime "Erro: O preço não pode ser negativo..."
    syscall
    j change_preco_prompt_loop # Pula de volta para pedir o preço

change_preco_erro:
    # Se a validação falhou, imprime o erro e tenta DE NOVO
    li $v0, 4
    la $a0, num_errado
    syscall
    j change_preco # Pula de volta para o *início* da seleção