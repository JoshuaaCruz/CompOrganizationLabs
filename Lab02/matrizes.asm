.data
    prompt:       .asciiz "Qual o nome de arquivo desejado? (termine com .txt) "
    newline:      .asciiz "\n"
    space:        .asciiz " "
    
    matA:         .word 1,2,3,0,1,4,0,0,1
    matB:         .word 1,-2,5,0,1,-4,0,0,1
    matBT:        .space 36 # transposta de B
    
    matResult:    .space 36 # matriz 3x3 = 9 x 4(tamanho 4bytes)=36
    
    fileName:     .space 100 # reserva 99 bytes para o nome de arquivo escolhido
    buffer:       .space 12  # buffer para conversão de um inteiro para string

.text

main:
    jal PROC_NOME
    
    # CRIANDO ARQUIVO PARA ESCRITA
    li      $v0, 13
    la      $a0, fileName
    li      $a1, 1
    li      $a2, 0
    syscall
    move    $s6, $v0             # salva o descritor do arquivo em $s6


    la $a0, matA                 # arg0: endereço de matA
    la $a1, matB                 # arg1: endereço de matB
    la $a2, matResult            # arg2: endereço para salvar o resultado final
    la $a3, matBT                # arg3: endereço para a matriz transposta temporária
    jal PROC_MUL
    
    # O endereço da matriz resultado é retornado em $v0 por PROC_MUL
    move $s7, $v0                # Salva o endereço de matResult (para usar no WRITE_FILE)

    # SALVA A MATRIZ RESULTANTE NO ARQUIVO
    move $a0, $s7                # argumento 1: endereço da matriz (retornado por PROC_MUL)
    li $a1, 3                    # argumento 2: ordem da matriz
    move $a2, $s6                # argumento 3: descritor de arquivo
    jal WRITE_FILE
    
    # FECHA O ARQUIVO
    li      $v0, 16
    move    $a0, $s6
    syscall
    
    # FINALIZA O PROGRAMA
    li $v0, 10
    syscall
        
PROC_NOME:
    li      $v0, 4
    la      $a0, prompt
    syscall
    
    li      $v0, 8
    la      $a0, fileName
    li      $a1, 100
    syscall
    
    li $t0, 0
find_newline:
    lb $t1, fileName($t0)
    beq $t1, 10, replace_newline
    beq $t1, $zero, end_replace
    addi $t0, $t0, 1
    j find_newline
replace_newline:
    sb $zero, fileName($t0)
end_replace:
    jr      $ra


PROC_TRANS:
    # Este procedimento não chama outros (é folha), então não precisa salvar $ra

    li $t0, 0           # i = 0
trans_i:
    li $t1, 0           # j = 0
trans_j:
    # Endereço do elemento B[i][j] = $a0 + (i*3 + j)*4
    mul $t2, $t0, 3
    add $t2, $t2, $t1
    sll $t2, $t2, 2
    add $t3, $a0, $t2  
    lw $t4, 0($t3)

    # Endereço do elemento BT[j][i] = $a1 + (j*3 + i)*4
    mul $t2, $t1, 3
    add $t2, $t2, $t0
    sll $t2, $t2, 2
    add $t3, $a1, $t2  
    sw $t4, 0($t3)

    addi $t1, $t1, 1
    li $t5, 3
    blt $t1, $t5, trans_j

    addi $t0, $t0, 1
    blt $t0, $t5, trans_i

    move $v0, $a1 
    jr $ra

PROC_MUL:

    addi $sp, $sp, -24
    sw $ra, 20($sp)     # Salva $ra pois esta função chama outra (não-folha)
    sw $s0, 16($sp)     # Salva registradores $s que vamos usar
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)      
    
    move $s0, $a0       # s0 = end. matA
    move $s1, $a1       # s1 = end. matB
    move $s2, $a2       # s2 = end. matResult
    move $s3, $a3       # s3 = end. matBT
    
    ### PROC_MUL chama PROC_TRANS
    move $a0, $s1       # Prepara arg0  PROC_TRANS: endereço de matB
    move $a1, $s3       # Prepara arg1  PROC_TRANS: endereço de matBT
    jal PROC_TRANS
    
    # Após PROC_TRANS retornar, $v0 contém o endereço de matBT
    move $s4, $v0       # s4 = endereço de matBT (retornado por PROC_TRANS)


    li $t0, 0           # i = 0
mul_i:
    li $t1, 0           # j = 0
mul_j:
    li $t2, 0           # k = 0
    li $t3, 0           # soma = 0

mul_k:
    li $t9, 3
    bge $t2, $t9, mul_store

    # Endereço de A[i][k] = $s0 + (i*3 + k)*4
    mul $t4, $t0, 3
    add $t4, $t4, $t2
    sll $t4, $t4, 2
    add $t5, $s0, $t4   
    lw $t6, 0($t5)      # t6 = A[i][k]

    # Endereço de BT[k][j] = $s4 + (k*3 + j)*4
    mul $t4, $t2, 3
    add $t4, $t4, $t1
    sll $t4, $t4, 2
    add $t5, $s4, $t4   ### Usa $s4 (endereço de matBT)
    lw $t7, 0($t5)      # t7 = BT[k][j]

    # soma parcial
    mul $t8, $t6, $t7
    add $t3, $t3, $t8

    addi $t2, $t2, 1
    j mul_k

mul_store:
    # armazena Result[i][j] = soma
    mul $t4, $t0, 3
    add $t4, $t4, $t1
    sll $t4, $t4, 2
    add $t5, $s2, $t4   ### (endereço de matResult)
    sw $t3, 0($t5)

    addi $t1, $t1, 1
    li $t9, 3
    blt $t1, $t9, mul_j

    addi $t0, $t0, 1
    blt $t0, $t9, mul_i

    move $v0, $s2       ### Retorna o endereço de matResult em $v0

    lw $s4, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    
    jr $ra


WRITE_FILE:
    addi $sp, $sp, -24
    sw $ra, 20($sp) 

    move $t0, $a0
    move $t1, $a1
    move $t2, $a2

    li $t3, 0
loop_linhas_escrita:
    bge $t3, $t1, fim_escrita
    li $t4, 0
loop_colunas_escrita:
    bge $t4, $t1, proxima_linha
    mul $t5, $t3, $t1   
    add $t5, $t5, $t4   
    sll $t5, $t5, 2     
    add $t5, $t0, $t5   
    lw $t6, 0($t5)

    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)

    move $a0, $t6       
    move $a1, $t2       
    jal CONVERT_AND_WRITE

    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)

    addi $t5, $t4, 1
    bge $t5, $t1, continua_loop_colunas 
    li $v0, 15
    move $a0, $t2       
    la $a1, space       
    li $a2, 1           
    syscall

continua_loop_colunas:
    addi $t4, $t4, 1
    j loop_colunas_escrita

proxima_linha:
    addi $t5, $t3, 1
    bge $t5, $t1, nao_escreve_newline
    li $v0, 15
    move $a0, $t2       
    la $a1, newline     
    li $a2, 1           
    syscall

nao_escreve_newline:
    addi $t3, $t3, 1
    j loop_linhas_escrita

fim_escrita:
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    jr $ra


CONVERT_AND_WRITE:
    addi $sp, $sp, -28
    sw $t0, 24($sp)
    sw $t1, 20($sp)
    sw $t2, 16($sp)
    sw $t3, 12($sp)
    sw $t4, 8($sp)
    sw $t5, 4($sp)
    sw $t6, 0($sp)
    move $t0, $a0
    move $t1, $a1
    bne $t0, $zero, checar_negativo
    la $t3, buffer
    li $t2, '0'
    sb $t2, 0($t3)
    li $t4, 1
    
    j escrever_no_arquivo
    
checar_negativo:

    li $t5, 0
    bge $t0, $zero, loop_conversao
    li $t5, 1
    negu $t0, $t0
    
    
loop_conversao:

    la $t3, buffer
    addi $t3, $t3, 10
    sb $zero, 1($t3)
    li $t4, 0
    li $t6, 10
    
    
div_loop:

    div $t0, $t6
    mflo $t0
    mfhi $t2
    addi $t2, $t2, '0'
    sb $t2, 0($t3)
    addi $t3, $t3, -1
    addi $t4, $t4, 1
    bne $t0, $zero, div_loop
    beq $t5, $zero, escrever_no_arquivo
    li $t2, '-'
    
    sb $t2, 0($t3)
    addi $t3, $t3, -1
    addi $t4, $t4, 1
    
    
escrever_no_arquivo:

    li $v0, 15
    move $a0, $t1
    addi $a1, $t3, 1
    move $a2, $t4
    
    syscall
    
    lw $t6, 0($sp)
    lw $t5, 4($sp)
    lw $t4, 8($sp)
    lw $t3, 12($sp)
    lw $t2, 16($sp)
    lw $t1, 20($sp)
    lw $t0, 24($sp)
    
    addi $sp, $sp, 28
    
    jr $ra