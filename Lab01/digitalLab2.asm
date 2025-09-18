.data

segmentos:
    .byte 0x3F  # 0
    .byte 0x06  # 1
    .byte 0x5B  # 2
    .byte 0x4F  # 3
    .byte 0x66  # 4
    .byte 0x6D  # 5
    .byte 0x7D  # 6
    .byte 0x07  # 7
    .byte 0x7F  # 8
    .byte 0x6F  # 9
    .byte 0x77  # A
    .byte 0x7C  # b
    .byte 0x39  # C
    .byte 0x5E  # d
    .byte 0x79  # E
    .byte 0x71  # F
 
teclas:
    .byte 0x11, 0x21, 0x41, 0x81     # 0, 1, 2, 3
    .byte 0x12, 0x22, 0x42, 0x82     # 4, 5, 6, 7
    .byte 0x14, 0x24, 0x44, 0x84     # 8, 9, A, b
    .byte 0x18, 0x28, 0x48, 0x88     # C, d, E, F
 
.text
main:
    li $s0, 0xFFFF0012      # endereco do escrever linha do teclado
    li $s1, 0xFFFF0014      # endereco do ler tecla pressionada
    li $s2, 0xFFFF0010      # endereco do display direito
    la $s3, segmentos       
    la $s5, teclas          
 
loop:
    li $t0, 1               # linha inicial = 1
 
scan_linhas:
    sb $t0, 0($s0)          # ativa linha (1, 2, 4, 8)
    lb $t1, 0($s1)          # le valor da tecla
 
    # Verifica se alguma tecla foi pressionada (t1 != 0)
    li $t9, 0
    beq $t1, $t9, prox_linha
 
    # Se alguma tecla foi pressionada
    li $t2, 0               # indice
    li $t8, 16              # nUmero total de teclas
    la $t4, teclas          # ponteiro temporario da tabela
 
procura:
    lb $t3, 0($t4)          # carrega codigo da tecla
    beq $t1, $t3, encontrada
 
    addi $t4, $t4, 1        # proxima posicao
    addi $t2, $t2, 1        # proximo indice
    bne $t2, $t8, procura
 
    j loop                  # se nao encontrou, volta
 
encontrada:
    # t2 tem o índice da tecla (0 a 15)
    mul $t6, $t2, 1         # indice * 1
    add $t7, $s3, $t6       # endereco do padrão
    lb $t9, 0($t7)          
    sb $t9, 0($s2)          # envia para display
    j loop
 
prox_linha:
    sll $t0, $t0, 1         # proxima linha (1, 2, 4, 8)
    li $t6, 16              # ve se passou de 8
    beq $t0, $t6, loop
    j scan_linhas