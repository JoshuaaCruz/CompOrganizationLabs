.data
space:      .asciiz " "
newline:    .asciiz "\n"


MAX:        .word 4         # Tamanho da Matriz (MAX x MAX)
BLOCK_SIZE: .word 2         # Tamanho do Bloco


A:    .float 1.0, 1.0, 1.0, 1.0
      .float 1.0, 1.0, 1.0, 1.0
      .float 1.0, 1.0, 1.0, 1.0
      .float 1.0, 1.0, 1.0, 1.0

B:    .float 22.0, 0.0, 0.0, 0.0
      .float 0.0, 2.0, 0.0, 0.0
      .float 0.0, 0.0, 2.0, 0.0
      .float 0.0, 0.0, 0.0, 2.0

.text
.globl main

main:
    la   $s0, A             
    la   $s1, B             
    lw   $s2, MAX           
    lw   $s3, BLOCK_SIZE    

    #  Loops Externos
    li   $t0, 0             # i = 0
LOOP_i:
    bge  $t0, $s2, PRINT_A  # if (i >= MAX) vai para PRINT_A

    li   $t1, 0             # j = 0
LOOP_j:
    bge  $t1, $s2, END_j    # if (j >= MAX) vai para END_j

    # Limites dos blocos
    # limit_i = min(i + BLOCK_SIZE, MAX)
    add  $t4, $t0, $s3      # $t4 = i + BLOCK_SIZE
    blt  $t4, $s2, set_limit_i
    move $t4, $s2           # limit_i = MAX
    j    set_ii
set_limit_i:
    move $t4, $t4           # limit_i = i + BLOCK_SIZE

set_ii:
    # limit_j = min(j + BLOCK_SIZE, MAX)  
    add  $t5, $t1, $s3      # $t5 = j + BLOCK_SIZE
    blt  $t5, $s2, set_limit_j
    move $t5, $s2           # limit_j = MAX
    j    start_inner_loops
set_limit_j:
    move $t5, $t5           # limit_j = j + BLOCK_SIZE

start_inner_loops:
    # Loops Internos (dentro do bloco)
    move $t2, $t0           # ii = i
LOOP_ii:
    bge  $t2, $t4, END_ii   # if (ii >= limit_i) vai para END_ii

    move $t3, $t1           # jj = j
LOOP_jj:
    bge  $t3, $t5, END_jj   # if (jj >= limit_j) vai para END_jj

    # A[ii,jj] = A[ii,jj] + B[jj,ii]
    
    # Calcular endereço de A[ii, jj]
    mul  $t6, $t2, $s2      # $t6 = ii * MAX
    add  $t6, $t6, $t3      # $t6 = (ii * MAX) + jj
    sll  $t6, $t6, 2        # $t6 = offset em bytes
    add  $t7, $s0, $t6      # $t7 = Endereço de A[ii, jj]
    
    # Calcular endereço de B[jj, ii]
    mul  $t6, $t3, $s2      # $t6 = jj * MAX
    add  $t6, $t6, $t2      # $t6 = (jj * MAX) + ii
    sll  $t6, $t6, 2        # $t6 = offset em bytes
    add  $t8, $s1, $t6      # $t8 = Endereço de B[jj, ii]

    # Operação com ponto flutuante
    l.s  $f0, 0($t7)        # $f0 = A[ii, jj]
    l.s  $f2, 0($t8)        # $f2 = B[jj, ii]
    add.s $f4, $f0, $f2     # $f4 = A[ii, jj] + B[jj, ii]
    s.s  $f4, 0($t7)        # A[ii, jj] = $f4

    addi $t3, $t3, 1        
    j    LOOP_jj

END_jj:
    addi $t2, $t2, 1        
    j    LOOP_ii

END_ii:
    add  $t1, $t1, $s3      # j += BLOCK_SIZE
    j    LOOP_j

END_j:
    add  $t0, $t0, $s3      # i += BLOCK_SIZE
    j    LOOP_i

# Imprimindo
PRINT_A:
    li   $t0, 0             
print_rows:
    bge  $t0, $s2, end      
    li   $t1, 0             
print_cols:
    bge  $t1, $s2, print_newline
    
    # Calcular endereço de A[i,j]
    mul  $t2, $t0, $s2      
    add  $t2, $t2, $t1      
    sll  $t2, $t2, 2        
    add  $t3, $s0, $t2      
    
    l.s  $f12, 0($t3)
    li   $v0, 2
    syscall
    
    la   $a0, space
    li   $v0, 4
    syscall
    
    addi $t1, $t1, 1        
    j    print_cols

print_newline:
    la   $a0, newline
    li   $v0, 4
    syscall
    addi $t0, $t0, 1        
    j    print_rows

end:
    li   $v0, 10
    syscall