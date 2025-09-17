.data

# Segmentos: 0bgfedcba
# 0: 0b0111111 - hexa: 0x3F
# 1: 0b0000110 - hexa: 0x06
# 2: 0b1011011 - hexa: 0x5B
# 3: 0b1001111 - hexa: 0x4F
# 4: 0b1100110 - hexa: 0x66
# 5: 0b1101101 - hexa: 0x6D
# 6: 0b1111101 - hexa: 0x7D
# 7: 0b0000111 - hexa: 0x07
# 8: 0b1111111 - hexa: 0x7F
# 9: 0b1101111 - hexa: 0x6F


.text

main:
	li $s0, 0xFFFF0010    # Endereço do display da direita
	
loop:
   	li $t0, 0x3F       # 0
   	sb $t0, 0($s0)

    	li $t0, 0x06       # 1
    	sb $t0, 0($s0)

    	li $t0, 0x5B       # 2
    	sb $t0, 0($s0)

    	li $t0, 0x4F       # 3
    	sb $t0, 0($s0)

    	li $t0, 0x66       # 4
    	sb $t0, 0($s0)

    	li $t0, 0x6D       # 5
    	sb $t0, 0($s0)

    	li $t0, 0x7D       # 6
    	sb $t0, 0($s0)

    	li $t0, 0x07       # 7
    	sb $t0, 0($s0)

    	li $t0, 0x7F       # 8
    	sb $t0, 0($s0)

    	li $t0, 0x6F       # 9
  	sb $t0, 0($s0)

    	j loop