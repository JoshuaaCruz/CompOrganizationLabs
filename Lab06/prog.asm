.include "labels.asm"

.globl p1, p2, p3, prog2, prog3

.data
v1: .word 0
v2: .word 0
v3: .word 0

.text

p1: 
la $t0 0x10010001
lw $t1 0($t0)
j p1

p2: j p2
p3: j p3

prog1:
li $a0 500
jal DELAY_PROC

li $v0 1
li $a0 4
syscall

j prog1

prog2:
li $a0 3000
jal DELAY_PROC

li $v0 1
li $a0 0
syscall

j prog2

prog3:
li $s0 2

loop_prog3:
li $a0 5000
jal DELAY_PROC

move $a0 $s0
jal FATORIAL_PROC
move $a0 $v0

li $v0 1
syscall

add $s0 $s0 1

j loop_prog3

######

DELAY_PROC:
move $t0 $a0
li $v0 30
syscall
add $t0 $t0 $a0

loop:
li $v0 30
syscall
blt $a0 $t0 loop

move $a0 $t0
jr $ra
######


FATORIAL_PROC:
beq $a0 1 ret

psw $ra
psw $a0
subi $a0 $a0 1
jal FATORIAL_PROC
ppw $a0
ppw $ra
mul $v0 $a0 $v0

jr $ra

ret: 
li $v0 1
jr $ra
