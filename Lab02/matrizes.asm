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
    li      $v0, 13              # syscall: open_file
    la      $a0, fileName        # argumento 1: endereço do nome do arquivo
    li      $a1, 1               # argumento 2: flag (1 = escrita)
    li      $a2, 0               # argumento 3: modo (padrão)
    syscall
    move    $s6, $v0             # salva o descritor do arquivo em $s6

  
    # CALCULOS DAS MATRIZES
    jal PROC_TRANS               # calcula transposta de B
    jal PROC_MUL                 # calcula matriz resultante = A * BT

    # SALVA A MATRIZ RESULTANTE NO ARQUIVO
    la $a0, matResult            # argumento 1: endereço da matriz
    li $a1, 3                    # argumento 2: ordem da matriz
    move $a2, $s6                # argumento 3: descritor de arquivo
    jal WRITE_FILE
    
    # FECHA O ARQUIVO
    li      $v0, 16              # fecha arquivo
    move    $a0, $s6             # descritor do arquivo
    syscall
    
    # FINALIZA O PROGRAMA
    li $v0, 10
    syscall
        
PROC_NOME: # SOLICITAR AO USER PELO NOME DO ARQUIVO .txt
    li      $v0, 4
    la      $a0, prompt # imprime prompt
    syscall
    
    li      $v0, 8      # pega string do user
    la      $a0, fileName # endereço do buffer em $a0
    li      $a1, 100    # Tamanho máximo da string em $a1
    syscall             # A string é lida e salva no buffer
    
    # Remove o caractere de nova linha '\n' que o syscall 8 adiciona no final
    li $t0, 0
find_newline:
    lb $t1, fileName($t0)
    beq $t1, 10, replace_newline # 10 é o ASCII para '\n'
    beq $t1, $zero, end_replace
    addi $t0, $t0, 1
    j find_newline
replace_newline:
    sb $zero, fileName($t0)
end_replace:
    
    # (Opcional) Imprime o nome do arquivo para confirmação
    li      $v0, 4
    la      $a0, fileName
    syscall 
    
    li      $v0, 4
    la      $a0, newline
    syscall

    jr      $ra


PROC_TRANS:
    li $t0, 0           # i = 0
trans_i:
    li $t1, 0           # j = 0
trans_j:
    # posicao em B: (i*3) + j
    mul $t2, $t0, 3
    add $t2, $t2, $t1
    sll $t2, $t2, 2
    la $t3, matB
    add $t3, $t3, $t2
    lw $t4, 0($t3)

    # posicao em BT: (j*3) + i  --> BT[j][i] = B[i][j]
    mul $t2, $t1, 3
    add $t2, $t2, $t0
    sll $t2, $t2, 2
    la $t3, matBT
    add $t3, $t3, $t2
    sw $t4, 0($t3)

    addi $t1, $t1, 1
    li $t5, 3
    blt $t1, $t5, trans_j

    addi $t0, $t0, 1
    blt $t0, $t5, trans_i

    jr $ra


PROC_MUL:
    li $t0, 0           # i = 0
mul_i:
    li $t1, 0           # j = 0
mul_j:
    li $t2, 0           # k = 0
    li $t3, 0           # soma = 0

mul_k:
    li $t9, 3
    bge $t2, $t9, mul_store

    # A[i][k]
    mul $t4, $t0, 3
    add $t4, $t4, $t2
    sll $t4, $t4, 2
    la $t5, matA
    add $t5, $t5, $t4
    lw $t6, 0($t5)      # t6 = A[i][k]

    # BT[k][j]
    mul $t4, $t2, 3
    add $t4, $t4, $t1
    sll $t4, $t4, 2
    la $t5, matBT
    add $t5, $t5, $t4
    lw $t7, 0($t5)      # t7 = BT[k][j]

    # soma parcial
    mul $t8, $t6, $t7
    add $t3, $t3, $t8

    addi $t2, $t2, 1
    j mul_k

mul_store:
    # armazena C[i][j] = soma
    mul $t4, $t0, 3
    add $t4, $t4, $t1
    sll $t4, $t4, 2
    la $t5, matResult
    add $t5, $t5, $t4
    sw $t3, 0($t5)

    addi $t1, $t1, 1
    li $t9, 3
    blt $t1, $t9, mul_j

    addi $t0, $t0, 1
    blt $t0, $t9, mul_i

    jr $ra


# --- VERSÃO ATUALIZADA ---
WRITE_FILE:
    # Prólogo: Salva apenas os registradores estritamente necessários
    addi $sp, $sp, -24
    sw $ra, 20($sp) 

    # Mover argumentos para registradores temporários
    move $t0, $a0       # t0 = endereço da matriz
    move $t1, $a1       # t1 = ordem da matriz
    move $t2, $a2       # t2 = descritor do arquivo

    li $t3, 0           # t3 = i (contador de linhas)
loop_linhas_escrita:
    bge $t3, $t1, fim_escrita

    li $t4, 0           # t4 = j (contador de colunas)
loop_colunas_escrita:
    bge $t4, $t1, proxima_linha

    # Calcular o endereço do elemento matResult[i][j]
    mul $t5, $t3, $t1   
    add $t5, $t5, $t4   
    sll $t5, $t5, 2     
    add $t5, $t0, $t5   
    lw $t6, 0($t5)      # t6 = matResult[i][j]

    # Salva os temporários que precisam sobreviver à chamada `jal`
    sw $t0, 0($sp)      # Salva endereço da matriz
    sw $t1, 4($sp)      # Salva ordem
    sw $t2, 8($sp)      # Salva descritor do arquivo
    sw $t3, 12($sp)     # Salva contador i
    sw $t4, 16($sp)     # Salva contador j

    # Chamar o procedimento para converter e escrever o número
    move $a0, $t6       
    move $a1, $t2       
    jal CONVER_AND_WRITE

    # Restaura os temporários
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)

    # Escrever um espaço " " se não for o último elemento da linha
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
    # Epílogo: Restaura apenas o que foi salvo
    lw $ra, 20($sp)
    addi $sp, $sp, 24

    jr $ra

#-----------------------------------------------------------------------
CONVER_AND_WRITE:
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
