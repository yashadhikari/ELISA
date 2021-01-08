# The following file will test the matrix multiplication benchmark
# We will be storing the matrix as a vector into main memory and loading in 
# value from matrix 1 into reegister 1 and value of matrix 2 into register 2.
# We will perform a multiplication operation on these two registers and store 
# the value in register 3. The last part of this matrix multiplication is to
# increment the value of register 4 by the value in register 3. 
#   Matrix: 1 [m by k], matrix 2: [k by n]
#   Loop r through m times
#       Loop c through n times
#           Loop i through k times
#               multiply value from matrix 1 at index (r-1) * m by value from matrix 2 at index (i-1) * n
#               there may be an offset in memory due to loading of instructions
#               use this value to increment the value in register 19
#               Place this value in a new matrix at index (r-1) * n + some offset
#               set the value of register 19 baak to 0

# Load data in memory location starting at X to X+m*k
# Load another set of data in memory location starting at X+m*k to (X+m*k) + k*n
# Perform matrix multiplication
# Store data in memory location X+m*k+k*n to (X+m*k+k*n) + m*n
####################### Start of Assembly #######################

        .text
main:
    
    # clear register values that will store counters to 1
    addi $r1 $r0 1                          # Store r
    addi $r2 $r0 1                          # Store c
    addi $r3 $r0 1                          # Store i
    
    add $r19 $r0 $r0                        # Store 0 into $r19 - used for final value
    
    # store matrix sizes in registers
    lw $r4 row_m                            # Store value of m+1 (constant)
    lw $r5 col_n                            # Store value of n+1 (constant)
    lw $r6 k                                # Store value of k+1 (constant)
    
    lw $r11 starting_X                      # Store starting point of data X (constant)
    lw $r12 address_factor                  # Store factor to get address (constant)
    
    addi $r7 $r4 -1                         # Store value of m
    addi $r8 $r5 -1                         # Store value of n
    addi $r9 $r6 -1                         # Store value of k
    
    mult $r7 $r9                            # m * k
    mflo $r15                               # $r15 = m * k
    add $r15 $r11 $r15                      # $r15 = X + (m * k) (constant)
    
    mult $r8 $r9                            # n * k
    mflo $r20                               # $r20 = n * k
    add $r20 $r15 $r20                      # $r20 = (X+(m*k)) + n * k (constant)

    
# perform matrix multiplication
# loop through m rows in matrix 1
loop_r:

# loop through n columns in matrix 2
loop_c:

# loop through k times to perform multiplication / addition (main calculation)
loop_i:
    
    # Get value from matrix 1 by finding the proper index
    addi $r22 $r1 -1
    
    mult $r22 $r7                           # (r-1) * m
    mflo $r13                               # $r13 = (r-1) * m
    add $r13 $r13 $r3                       # add counter i
    add $r13 $r13 $r11                      # add starting mem address
    mult $r13 $r12                          # multiply by 4 to properly index
    mflo $r13                               # $r13 = address
    lw $r14 0($r13)                         # $r14 = value from matrix 1
    
    # Get value from matrix 2 by finding the proper index
    addi $r10 $r3 -1
    mult $r10 $r8                           # (i-1) * n
    mflo $r16                               # $r16 = (i-1) * n
    add $r16 $r16 $r2                       # $r16 += c (proper relative index)
    
    add $r16 $r16 $r15                      # add starting mem address
    mult $r16 $r12                          # multiply by 4 to properly index
    mflo $r16                               # $r16 = address
    lw $r17 0($r16)                         # $r17 = value from matrix 2
    
    # multiply the two values from the matrices and increment the final value
    mult $r14 $r17
    mflo $r18
    add $r19 $r19 $r18
    
    
    # loop back to loop_i
    addi $r3 $r3 1
    bne $r3 $r6, loop_i
    addi $r3 $r0 1
    
    # Store value into matrix 3 by finding the proper index
    
    mult $r22 $r8                           # (r-1) * n
    mflo $r21                               # $r21 = (r-1) * n
    add $r21 $r21 $r2                       # $r21 += c
    
    add $r21 $r21 $r20                      # add starting mem address
    mult $r21 $r12                          # multiply by 4 to properly index
    mflo $r21                               # $r21 = address
    sw $r19 0($r21)                         # store value of calculation into matrix 3
    add $r19 $r0 $r0                        # restore $r19 to 0 - used for final value


    # loop back to loop_c   
    addi $r2 $r2 1
    bne $r2 $r5, loop_c
    addi $r2 $r0 1


    # loop back to loop_r    
    addi $r1 $r1 1
    bne $r1 $r4, loop_r
    addi $r1 $r0 1

exit:
    # Syscall to exit.
    syscall
    syscall
    syscall

# Matrix 1 of shape 5x5
# Matrix 2 of shape 5x10

.data
    starting_X: 60
    
    # must be 1 more than actual number to handle loop condition
    row_m: 51
    k: 51
    col_n: 101
    mat_1: [7, 7, 6, 1, 9, 5, 7, 7, 4, 7, 3, 9, 2, 7, 2, 6, 4, 5, 1, 5, 4, 1, 9, 6, 5, 2, 8, 1, 7, 5, 4, 3, 9, 2, 1, 5, 4, 4, 2, 3, 3, 5, 3, 4, 5, 7, 9, 6, 7, 7, 7, 8, 8, 5, 2, 2, 8, 7, 2, 1, 2, 7, 8, 6, 6, 8, 7, 9, 7, 2, 5, 2, 5, 5, 2, 1, 5, 1, 1, 8, 6, 5, 4, 9, 3, 9, 3, 1, 9, 6, 4, 3, 9, 1, 8, 9, 5, 8, 6, 6, 9, 6, 8, 4, 3, 2, 6, 7, 2, 8, 4, 9, 7, 4, 3, 8, 9, 9, 2, 2, 9, 7, 4, 6, 1, 1, 3, 6, 4, 8, 1, 3, 2, 1, 6, 6, 5, 8, 6, 3, 7, 1, 8, 9, 8, 4, 8, 6, 3, 2, 6, 1, 4, 7, 9, 5, 3, 8, 6, 6, 6, 8, 8, 6, 9, 3, 2, 2, 4, 8, 4, 5, 8, 6, 3, 3, 9, 6, 6, 9, 1, 7, 3, 1, 3, 4, 1, 2, 8, 6, 1, 6, 1, 5, 3, 3, 5, 7, 8, 6, 5, 4, 9, 8, 6, 3, 8, 7, 6, 6, 9, 2, 7, 5, 8, 6, 1, 6, 6, 6, 1, 6, 9, 3, 8, 8, 6, 2, 3, 2, 5, 5, 3, 2, 5, 3, 5, 1, 1, 9, 3, 2, 6, 1, 7, 6, 3, 9, 9, 2, 4, 7, 1, 1, 3, 7, 3, 1, 9, 5, 5, 5, 3, 4, 2, 2, 9, 4, 3, 3, 6, 3, 1, 7, 9, 6, 5, 9, 5, 4, 3, 5, 7, 5, 6, 4, 2, 9, 8, 6, 9, 4, 4, 2, 6, 2, 4, 2, 9, 5, 3, 5, 8, 1, 2, 3, 7, 7, 5, 4, 4, 2, 8, 1, 1, 6, 4, 2, 2, 2, 6, 7, 8, 8, 1, 9, 3, 2, 9, 4, 5, 7, 2, 4, 2, 4, 5, 3, 2, 5, 9, 8, 2, 6, 4, 5, 3, 4, 7, 1, 5, 4, 2, 2, 1, 2, 8, 6, 4, 3, 8, 6, 7, 1, 3, 8, 5, 7, 9, 9, 9, 1, 7, 3, 4, 2, 4, 9, 3, 5, 4, 5, 3, 7, 4, 3, 8, 1, 8, 4, 5, 6, 3, 8, 7, 7, 8, 9, 6, 2, 1, 4, 9, 4, 1, 3, 8, 3, 9, 6, 6, 7, 2, 6, 6, 7, 5, 1, 4, 4, 7, 1, 5, 2, 7, 8, 5, 5, 4, 1, 4, 2, 8, 2, 8, 3, 6, 3, 6, 6, 1, 6, 2, 3, 4, 4, 4, 6, 5, 2, 4, 5, 7, 8, 7, 1, 4, 7, 4, 5, 1, 2, 7, 3, 4, 6, 5, 2, 4, 3, 9, 7, 9, 3, 6, 4, 9, 8, 1, 2, 8, 6, 6, 4, 3, 6, 1, 3, 8, 2, 9, 9, 9, 1, 7, 8, 3, 3, 4, 4, 9, 9, 5, 2, 5, 9, 5, 4, 4, 7, 6, 6, 4, 4, 9, 8, 8, 2, 9, 5, 5, 5, 2, 6, 2, 2, 9, 9, 5, 1, 2, 9, 3, 4, 3, 6, 1, 7, 9, 1, 2, 4, 1, 2, 3, 4, 6, 5, 7, 4, 5, 9, 9, 8, 1, 2, 9, 6, 5, 8, 3, 6, 6, 4, 2, 6, 4, 6, 2, 3, 9, 5, 2, 5, 3, 2, 6, 2, 9, 4, 9, 3, 9, 8, 5, 9, 5, 3, 6, 3, 4, 8, 7, 4, 7, 8, 2, 9, 5, 8, 1, 9, 7, 9, 6, 9, 3, 6, 2, 6, 4, 4, 4, 7, 3, 3, 9, 1, 4, 6, 7, 9, 1, 8, 5, 4, 3, 8, 8, 5, 2, 5, 7, 9, 7, 5, 6, 7, 6, 2, 1, 4, 5, 4, 7, 3, 8, 7, 5, 7, 6, 5, 9, 8, 2, 3, 8, 8, 8, 8, 5, 9, 7, 1, 2, 2, 2, 9, 2, 2, 1, 2, 9, 7, 4, 2, 9, 5, 5, 6, 8, 4, 9, 5, 9, 9, 6, 6, 2, 4, 6, 7, 3, 3, 5, 8, 3, 8, 7, 5, 3, 9, 2, 8, 7, 2, 9, 7, 4, 9, 9, 3, 8, 8, 3, 9, 7, 2, 4, 6, 1, 3, 8, 2, 1, 8, 6, 4, 2, 6, 3, 8, 1, 8, 3, 7, 2, 9, 6, 8, 4, 9, 6, 1, 3, 2, 6, 6, 5, 6, 7, 6, 9, 1, 1, 3, 3, 8, 5, 2, 5, 3, 1, 6, 9, 9, 6, 7, 3, 1, 9, 3, 2, 8, 4, 6, 6, 1, 8, 2, 4, 7, 5, 3, 4, 7, 5, 6, 8, 3, 9, 6, 2, 4, 2, 4, 9, 7, 7, 3, 1, 9, 9, 2, 4, 3, 7, 3, 6, 1, 2, 6, 7, 3, 4, 9, 1, 5, 3, 4, 8, 4, 7, 4, 9, 2, 2, 7, 5, 4, 7, 5, 6, 1, 8, 2, 5, 7, 1, 9, 4, 2, 6, 3, 9, 5, 7, 5, 9, 5, 7, 7, 4, 6, 6, 8, 1, 3, 4, 6, 9, 3, 4, 2, 2, 6, 5, 3, 9, 3, 2, 8, 2, 6, 3, 5, 9, 2, 5, 4, 8, 5, 1, 7, 8, 8, 2, 1, 6, 8, 6, 7, 5, 6, 5, 3, 5, 1, 1, 5, 4, 3, 1, 2, 5, 4, 7, 8, 1, 7, 3, 2, 6, 5, 4, 5, 8, 7, 3, 4, 5, 2, 5, 6, 3, 3, 5, 4, 1, 1, 1, 5, 5, 9, 9, 2, 9, 6, 7, 4, 6, 5, 7, 3, 1, 2, 1, 4, 6, 3, 9, 9, 4, 8, 8, 4, 8, 8, 5, 3, 3, 8, 5, 4, 4, 9, 9, 3, 7, 3, 2, 5, 9, 9, 5, 8, 5, 8, 1, 6, 5, 9, 2, 4, 7, 5, 1, 2, 5, 3, 3, 4, 6, 1, 3, 1, 5, 8, 3, 4, 2, 2, 6, 8, 6, 5, 7, 1, 2, 1, 1, 6, 1, 4, 7, 6, 8, 7, 2, 6, 8, 4, 5, 2, 4, 3, 8, 8, 5, 9, 8, 8, 6, 4, 4, 8, 3, 9, 3, 2, 3, 5, 2, 5, 9, 2, 9, 8, 3, 9, 6, 2, 3, 2, 2, 5, 7, 6, 7, 6, 4, 6, 9, 8, 6, 8, 2, 2, 4, 5, 9, 4, 7, 1, 8, 8, 6, 3, 4, 4, 8, 1, 4, 3, 7, 6, 3, 1, 6, 3, 3, 2, 8, 3, 7, 1, 5, 2, 5, 9, 1, 3, 4, 5, 9, 4, 5, 6, 5, 2, 6, 8, 4, 1, 6, 7, 2, 8, 6, 7, 7, 7, 1, 1, 9, 8, 2, 9, 5, 3, 7, 4, 9, 2, 2, 1, 4, 6, 3, 7, 6, 3, 9, 4, 9, 9, 3, 6, 5, 3, 8, 5, 5, 2, 6, 2, 6, 5, 6, 1, 2, 5, 7, 8, 2, 4, 1, 5, 8, 2, 4, 3, 2, 7, 3, 8, 3, 6, 8, 9, 8, 9, 2, 8, 5, 6, 8, 5, 4, 7, 5, 1, 3, 7, 4, 3, 5, 8, 5, 4, 5, 8, 1, 1, 9, 6, 3, 9, 5, 9, 4, 7, 8, 4, 7, 9, 1, 4, 6, 2, 9, 5, 6, 3, 6, 7, 4, 6, 7, 5, 4, 1, 6, 7, 4, 4, 1, 5, 5, 3, 6, 1, 8, 7, 2, 8, 2, 2, 2, 6, 9, 8, 5, 7, 7, 3, 2, 9, 8, 6, 8, 1, 3, 5, 3, 9, 1, 9, 4, 4, 4, 3, 4, 9, 5, 6, 7, 6, 2, 8, 9, 7, 2, 9, 3, 1, 3, 1, 8, 1, 6, 8, 2, 6, 8, 8, 4, 8, 7, 2, 6, 6, 2, 1, 9, 7, 2, 2, 5, 1, 5, 6, 4, 8, 3, 7, 8, 6, 4, 7, 6, 7, 5, 3, 7, 8, 9, 3, 2, 8, 9, 6, 8, 4, 3, 3, 9, 4, 3, 3, 8, 1, 1, 6, 7, 1, 6, 8, 3, 9, 1, 9, 4, 9, 4, 8, 7, 9, 7, 8, 4, 4, 8, 3, 4, 6, 6, 6, 6, 5, 9, 2, 2, 9, 5, 1, 3, 8, 3, 2, 1, 1, 3, 3, 8, 8, 7, 6, 1, 1, 6, 6, 2, 3, 5, 9, 6, 3, 7, 5, 5, 3, 4, 9, 7, 9, 8, 4, 6, 9, 7, 6, 6, 4, 2, 9, 2, 2, 9, 4, 4, 1, 6, 6, 1, 7, 4, 9, 6, 6, 1, 1, 5, 3, 9, 9, 1, 8, 3, 8, 5, 4, 2, 9, 4, 8, 1, 3, 5, 6, 9, 4, 3, 5, 8, 7, 3, 9, 8, 6, 9, 4, 1, 2, 9, 6, 3, 8, 1, 7, 6, 6, 7, 3, 7, 4, 3, 3, 3, 8, 3, 7, 5, 9, 8, 2, 2, 8, 3, 3, 8, 8, 2, 6, 7, 7, 9, 6, 6, 3, 3, 7, 3, 7, 3, 9, 4, 1, 1, 2, 6, 9, 4, 4, 8, 3, 4, 8, 4, 5, 7, 1, 7, 7, 4, 6, 7, 2, 1, 7, 2, 8, 7, 6, 7, 7, 2, 4, 3, 1, 5, 6, 7, 1, 7, 8, 6, 5, 5, 6, 8, 9, 9, 5, 7, 5, 5, 3, 2, 9, 9, 2, 7, 6, 5, 5, 8, 5, 5, 8, 2, 1, 5, 3, 6, 2, 1, 9, 2, 7, 4, 5, 2, 8, 2, 2, 6, 5, 4, 4, 9, 8, 1, 3, 9, 6, 8, 8, 1, 4, 6, 9, 8, 8, 6, 7, 2, 9, 9, 8, 5, 9, 7, 3, 6, 5, 1, 8, 3, 6, 8, 3, 9, 8, 2, 5, 6, 5, 8, 7, 4, 8, 7, 2, 5, 5, 3, 4, 6, 2, 6, 7, 9, 4, 7, 8, 7, 5, 4, 4, 6, 9, 4, 5, 9, 6, 5, 9, 9, 6, 3, 1, 4, 1, 5, 4, 1, 1, 5, 5, 8, 6, 1, 5, 4, 4, 4, 4, 6, 6, 4, 9, 3, 6, 9, 8, 1, 2, 9, 8, 5, 4, 4, 3, 7, 9, 9, 6, 5, 3, 1, 5, 7, 1, 9, 2, 8, 1, 9, 8, 3, 9, 3, 2, 5, 8, 2, 7, 5, 2, 1, 7, 3, 4, 1, 7, 1, 5, 4, 8, 2, 3, 3, 5, 5, 6, 2, 9, 4, 4, 8, 3, 5, 8, 9, 4, 6, 7, 1, 5, 3, 8, 5, 6, 5, 6, 2, 7, 8, 5, 1, 7, 5, 4, 3, 5, 2, 1, 8, 5, 5, 2, 4, 9, 7, 3, 4, 8, 2, 6, 3, 7, 2, 3, 3, 5, 3, 2, 9, 8, 3, 7, 4, 5, 7, 1, 1, 7, 3, 1, 1, 6, 4, 9, 6, 1, 4, 5, 9, 5, 4, 9, 3, 1, 3, 9, 8, 5, 3, 1, 7, 1, 3, 3, 7, 7, 4, 4, 8, 7, 7, 1, 2, 9, 4, 2, 9, 1, 3, 6, 2, 7, 4, 7, 1, 1, 3, 2, 4, 9, 9, 8, 3, 8, 1, 7, 7, 3, 7, 8, 9, 2, 2, 2, 2, 2, 6, 4, 7, 4, 5, 3, 8, 8, 6, 5, 4, 6, 2, 9, 9, 6, 7, 6, 1, 2, 5, 1, 1, 6, 9, 7, 8, 1, 3, 1, 2, 9, 6, 1, 5, 4, 2, 5, 2, 7, 4, 9, 4, 3, 3, 6, 3, 8, 6, 5, 6, 1, 4, 8, 4, 7, 3, 9, 7, 7, 7, 7, 3, 6, 4, 5, 7, 6, 1, 6, 7, 5, 7, 5, 2, 2, 8, 7, 5, 4, 6, 1, 2, 2, 5, 4, 3, 7, 6, 1, 1, 3, 1, 1, 2, 2, 4, 3, 7, 5, 4, 8, 6, 4, 4, 2, 9, 1, 2, 1, 8, 7, 9, 7, 5, 3, 9, 6, 6, 9, 1, 1, 4, 4, 1, 3, 6, 3, 7, 5, 9, 5, 7, 7, 8, 7, 4, 2, 9, 4, 2, 7, 7, 4, 9, 3, 4, 9, 6, 9, 3, 6, 9, 2, 7, 8, 7, 1, 3, 6, 7, 5, 1, 1, 7, 5, 9, 4, 5, 6, 1, 7, 5, 7, 6, 6, 6, 8, 7, 9, 5, 3, 8, 9, 7, 8, 1, 2, 6, 4, 6, 6, 9, 3, 8, 8, 6, 8, 6, 9, 6, 9, 9, 8, 1, 2, 3, 7, 1, 7, 6, 7, 7, 2, 6, 8, 1, 5, 6, 4, 2, 9, 5, 8, 3, 7, 7, 9, 6, 6, 8, 5, 7, 5, 5, 3, 2, 3, 2, 4, 7, 3, 6, 5, 6, 1, 5, 3, 5, 4, 8, 9, 9, 9, 7, 3, 1, 8, 2, 1, 1, 6, 9, 1, 1, 4, 8, 5, 8, 1, 3, 1, 1, 6, 2, 5, 3, 3, 2, 8, 1, 2, 5, 1, 1, 9, 1, 5, 1, 6, 3, 9, 2, 3, 9, 3, 9, 3, 4, 3, 3, 7, 7, 9, 7, 6, 9, 4, 7, 6, 8, 9, 5, 6, 2, 7, 8, 8, 2, 3, 6, 9, 3, 9, 9, 6, 1, 7, 5, 7, 7, 1, 3, 6, 1, 7, 4, 3, 9, 7, 4, 9, 1, 1, 2, 5, 9, 3, 7, 6, 4, 5, 7, 1, 2, 3, 7, 4, 8, 1, 6, 6, 7, 4, 2, 7, 7, 4, 9, 5, 9, 6, 8, 5, 5, 2, 3, 6, 3, 3, 5, 2, 8, 2, 6, 5, 9, 1, 2, 2, 1, 7, 5, 4, 4, 4, 2, 6, 5, 1, 7, 6, 8, 1, 1, 9, 5, 4, 1, 1, 3, 7, 1, 8, 6, 5, 6, 1, 4, 2, 4, 3, 1, 8, 8, 6, 8, 6, 4, 4, 3, 4, 6, 6, 6, 7, 7, 7, 5, 2, 2, 9, 6, 1, 1, 6, 6, 6, 7, 6, 9, 3, 9, 7, 4, 6, 7, 6, 8, 7, 1, 3, 9, 5, 1, 5, 8, 7, 6, 7, 6, 2, 3, 8, 5, 6, 2, 7, 8, 3, 8, 9, 4, 3, 2, 2, 9, 1, 6, 3, 8, 6, 2, 5, 9, 9, 1, 9, 4, 5, 5, 7, 3, 7, 7, 1, 8, 9, 5, 5, 1, 3, 4, 4, 3, 2, 6, 4, 9, 7, 3, 6, 9, 5, 8, 4, 9, 9, 6, 7, 9, 3, 6, 6, 7, 4, 9, 5, 4, 1, 9, 7, 1, 2, 9, 1, 7, 1, 4, 9, 8, 6, 4, 8, 8, 7, 2, 2, 2, 5, 1, 3, 4, 1, 5, 1, 8, 5, 3, 3, 7, 9, 4, 8, 4, 5, 5, 1, 6, 2, 3, 8, 9, 7, 1, 2, 9, 5, 2, 5, 3, 8, 1, 3, 2, 4, 1, 4, 2, 1, 7, 3, 2, 1, 4, 6, 5, 7, 9, 3, 9, 1, 8, 3, 3, 4, 1, 3, 3, 4, 4, 6, 5, 6, 1, 7, 9, 7, 3, 8, 4, 6, 6, 9]
    mat_2: [5, 7, 6, 3, 4, 3, 7, 9, 5, 4, 1, 7, 3, 1, 9, 2, 8, 3, 9, 6, 5, 6, 4, 1, 6, 5, 4, 2, 1, 6, 7, 6, 5, 4, 7, 6, 8, 4, 1, 6, 4, 1, 9, 9, 6, 1, 1, 3, 1, 2, 6, 7, 5, 5, 8, 1, 4, 6, 3, 2, 5, 8, 6, 1, 8, 5, 7, 5, 3, 7, 9, 2, 2, 7, 5, 3, 6, 7, 2, 3, 9, 7, 9, 6, 6, 9, 5, 7, 2, 8, 2, 7, 1, 8, 1, 1, 8, 9, 6, 4, 9, 8, 8, 1, 1, 8, 3, 3, 4, 6, 4, 1, 7, 7, 9, 4, 3, 2, 8, 6, 3, 7, 8, 9, 3, 7, 9, 9, 1, 7, 5, 4, 5, 1, 1, 1, 8, 7, 6, 2, 7, 2, 6, 2, 7, 9, 9, 4, 9, 3, 7, 9, 7, 7, 7, 6, 6, 3, 3, 9, 7, 7, 2, 1, 6, 3, 3, 2, 5, 7, 8, 9, 2, 1, 1, 8, 7, 2, 1, 7, 2, 6, 9, 9, 5, 3, 4, 5, 8, 5, 6, 6, 8, 6, 2, 9, 1, 2, 1, 9, 6, 8, 5, 8, 1, 4, 6, 9, 8, 3, 5, 9, 4, 6, 4, 4, 7, 6, 8, 1, 5, 8, 9, 1, 3, 3, 6, 3, 2, 4, 7, 4, 7, 7, 5, 3, 7, 2, 6, 8, 2, 3, 4, 1, 2, 6, 4, 2, 7, 9, 9, 8, 1, 6, 8, 6, 4, 7, 9, 8, 2, 9, 7, 2, 8, 9, 3, 3, 5, 7, 3, 7, 8, 9, 3, 4, 4, 3, 4, 4, 6, 7, 8, 6, 2, 8, 4, 1, 6, 6, 6, 5, 9, 1, 4, 5, 3, 8, 2, 4, 9, 9, 4, 5, 5, 3, 3, 1, 7, 1, 2, 9, 5, 6, 9, 4, 4, 6, 1, 1, 1, 2, 7, 6, 8, 3, 5, 2, 7, 9, 2, 5, 5, 7, 5, 5, 1, 8, 2, 2, 3, 7, 5, 3, 6, 2, 9, 3, 5, 6, 9, 8, 8, 2, 7, 2, 6, 5, 4, 7, 3, 3, 5, 4, 4, 7, 1, 6, 8, 2, 5, 6, 8, 2, 1, 1, 3, 1, 9, 8, 9, 1, 6, 2, 8, 6, 5, 6, 6, 6, 6, 8, 4, 7, 1, 8, 8, 7, 4, 3, 5, 2, 2, 4, 5, 1, 6, 1, 4, 1, 1, 6, 5, 9, 3, 7, 8, 8, 1, 9, 3, 5, 1, 5, 4, 5, 4, 9, 8, 3, 8, 8, 5, 5, 3, 3, 4, 5, 9, 5, 3, 3, 1, 2, 4, 3, 1, 5, 7, 3, 7, 1, 9, 8, 8, 1, 2, 5, 7, 1, 1, 9, 4, 7, 2, 5, 5, 5, 8, 9, 7, 2, 8, 3, 7, 7, 1, 4, 7, 1, 1, 1, 6, 8, 9, 7, 7, 5, 7, 5, 4, 8, 6, 5, 3, 6, 9, 2, 2, 6, 2, 2, 1, 8, 8, 4, 2, 2, 2, 1, 6, 1, 8, 2, 6, 9, 4, 4, 4, 2, 3, 7, 2, 3, 1, 6, 5, 6, 7, 3, 7, 7, 7, 2, 3, 5, 1, 8, 9, 3, 5, 5, 6, 6, 8, 5, 3, 5, 8, 8, 8, 3, 6, 4, 6, 7, 3, 2, 6, 1, 2, 9, 1, 1, 8, 8, 4, 2, 5, 7, 4, 8, 2, 7, 9, 6, 5, 9, 5, 7, 1, 1, 7, 9, 9, 4, 2, 6, 1, 1, 2, 6, 3, 2, 2, 9, 7, 6, 1, 2, 3, 9, 2, 9, 7, 3, 1, 1, 6, 6, 5, 8, 2, 7, 9, 6, 3, 3, 6, 1, 8, 2, 8, 2, 7, 2, 5, 8, 7, 6, 9, 1, 8, 2, 5, 8, 4, 2, 3, 9, 8, 8, 4, 5, 6, 5, 8, 2, 6, 3, 9, 4, 4, 2, 1, 2, 7, 4, 9, 2, 8, 1, 8, 9, 2, 4, 5, 4, 7, 9, 5, 5, 9, 3, 9, 8, 2, 5, 3, 9, 5, 5, 5, 2, 9, 6, 2, 5, 2, 2, 4, 6, 1, 6, 1, 9, 1, 7, 9, 7, 4, 7, 6, 9, 2, 4, 7, 6, 6, 9, 1, 2, 3, 9, 8, 9, 9, 6, 3, 4, 3, 9, 1, 7, 6, 4, 5, 2, 1, 7, 5, 4, 3, 9, 4, 5, 8, 6, 2, 7, 7, 7, 5, 5, 9, 2, 4, 4, 8, 9, 4, 9, 1, 7, 9, 9, 7, 1, 9, 9, 2, 1, 2, 5, 4, 7, 4, 8, 9, 9, 3, 9, 6, 2, 3, 9, 2, 7, 2, 7, 8, 4, 5, 2, 1, 7, 1, 1, 3, 9, 5, 5, 7, 6, 3, 9, 1, 8, 3, 3, 9, 5, 1, 3, 4, 5, 9, 7, 4, 7, 3, 1, 2, 6, 2, 6, 3, 6, 6, 4, 9, 2, 8, 6, 7, 4, 7, 9, 9, 9, 7, 2, 9, 9, 1, 2, 1, 4, 5, 8, 4, 1, 6, 7, 9, 7, 4, 9, 1, 1, 2, 6, 9, 6, 9, 6, 5, 2, 7, 1, 2, 6, 4, 4, 5, 4, 1, 7, 1, 7, 8, 6, 2, 3, 8, 2, 4, 2, 6, 3, 3, 6, 4, 2, 8, 9, 7, 3, 7, 1, 2, 5, 1, 6, 1, 6, 8, 8, 3, 7, 1, 1, 8, 1, 6, 2, 9, 6, 1, 8, 6, 3, 6, 5, 7, 4, 4, 6, 1, 2, 9, 5, 3, 6, 9, 5, 9, 7, 1, 8, 1, 5, 8, 7, 2, 3, 3, 7, 6, 7, 1, 5, 8, 8, 5, 9, 7, 2, 9, 3, 1, 6, 7, 4, 6, 1, 6, 7, 8, 8, 2, 6, 8, 1, 2, 8, 4, 6, 6, 3, 9, 3, 3, 5, 5, 4, 8, 9, 4, 9, 8, 6, 6, 9, 4, 2, 8, 3, 2, 7, 2, 3, 8, 1, 9, 2, 2, 2, 2, 3, 2, 4, 6, 9, 7, 2, 6, 4, 2, 7, 4, 7, 9, 9, 9, 6, 9, 3, 2, 5, 4, 1, 1, 1, 1, 3, 4, 2, 4, 2, 4, 4, 1, 7, 7, 8, 8, 6, 6, 2, 2, 5, 7, 7, 6, 7, 6, 9, 2, 5, 5, 2, 8, 5, 2, 4, 4, 4, 1, 5, 8, 9, 1, 6, 5, 6, 7, 5, 3, 8, 6, 9, 3, 2, 1, 3, 9, 2, 1, 1, 2, 5, 2, 6, 9, 5, 3, 6, 4, 2, 4, 2, 6, 7, 7, 3, 9, 4, 4, 6, 9, 7, 7, 9, 6, 2, 6, 8, 4, 9, 2, 6, 1, 7, 7, 7, 4, 1, 5, 7, 1, 3, 5, 8, 7, 2, 9, 5, 5, 2, 3, 5, 7, 1, 2, 8, 3, 5, 6, 7, 6, 4, 3, 3, 2, 7, 8, 9, 4, 5, 6, 4, 8, 4, 7, 6, 4, 8, 9, 8, 7, 8, 3, 5, 2, 6, 9, 9, 8, 2, 5, 3, 5, 4, 2, 8, 6, 5, 9, 8, 2, 8, 3, 8, 3, 2, 1, 7, 5, 9, 5, 1, 5, 8, 4, 4, 5, 2, 2, 9, 7, 9, 6, 7, 3, 1, 1, 5, 5, 7, 6, 1, 4, 6, 3, 2, 9, 7, 7, 1, 9, 2, 9, 3, 2, 4, 9, 7, 9, 7, 9, 8, 2, 2, 4, 9, 1, 3, 1, 1, 7, 3, 7, 6, 9, 6, 9, 7, 8, 7, 9, 2, 5, 2, 4, 9, 9, 4, 4, 2, 2, 5, 2, 3, 5, 1, 7, 5, 6, 1, 9, 5, 1, 7, 3, 3, 8, 1, 4, 2, 4, 8, 4, 7, 6, 4, 6, 3, 5, 8, 8, 4, 4, 3, 5, 2, 3, 8, 3, 4, 5, 4, 2, 6, 8, 4, 3, 2, 7, 7, 1, 4, 9, 6, 9, 4, 9, 3, 6, 8, 2, 4, 8, 4, 3, 8, 3, 8, 9, 1, 2, 4, 1, 2, 9, 8, 5, 5, 6, 3, 1, 3, 9, 5, 9, 4, 1, 5, 4, 5, 1, 5, 1, 2, 4, 8, 8, 8, 3, 7, 6, 6, 5, 7, 5, 8, 7, 9, 6, 2, 1, 1, 6, 7, 4, 2, 9, 9, 3, 6, 8, 9, 8, 9, 3, 8, 7, 7, 4, 6, 4, 8, 6, 1, 9, 4, 7, 5, 9, 3, 2, 7, 5, 8, 8, 8, 3, 4, 2, 7, 9, 8, 6, 8, 5, 7, 7, 8, 1, 1, 5, 2, 7, 4, 5, 1, 6, 1, 9, 4, 7, 3, 6, 9, 5, 9, 1, 9, 7, 4, 4, 3, 5, 7, 7, 7, 5, 5, 4, 4, 4, 4, 3, 2, 9, 7, 7, 6, 9, 1, 5, 2, 3, 4, 2, 4, 5, 1, 3, 3, 8, 3, 3, 3, 7, 6, 9, 7, 1, 9, 6, 7, 8, 4, 2, 3, 7, 9, 3, 9, 1, 4, 3, 9, 3, 3, 4, 7, 4, 1, 7, 6, 2, 1, 4, 4, 5, 5, 9, 8, 1, 1, 5, 8, 6, 8, 4, 1, 3, 4, 2, 7, 9, 1, 9, 6, 7, 4, 7, 6, 4, 9, 9, 4, 7, 5, 7, 6, 3, 7, 7, 9, 7, 7, 8, 6, 9, 6, 9, 7, 9, 5, 8, 1, 8, 5, 4, 7, 2, 9, 5, 1, 4, 7, 8, 3, 6, 4, 3, 1, 3, 1, 2, 8, 9, 4, 7, 8, 2, 3, 4, 5, 2, 1, 3, 1, 1, 6, 8, 8, 2, 4, 3, 4, 8, 5, 4, 2, 9, 7, 9, 6, 8, 5, 3, 4, 2, 3, 3, 7, 1, 5, 1, 7, 6, 3, 7, 8, 6, 9, 6, 9, 1, 4, 2, 4, 2, 9, 8, 7, 7, 4, 9, 5, 1, 3, 8, 9, 6, 2, 8, 6, 5, 9, 2, 2, 8, 4, 4, 4, 7, 1, 5, 7, 8, 5, 1, 1, 5, 8, 5, 9, 6, 4, 3, 6, 1, 2, 6, 4, 1, 9, 2, 9, 1, 7, 2, 7, 8, 8, 2, 8, 3, 1, 9, 5, 1, 2, 8, 8, 3, 6, 6, 4, 5, 6, 3, 9, 9, 7, 3, 9, 5, 6, 4, 8, 5, 4, 7, 9, 7, 6, 2, 4, 6, 7, 9, 7, 8, 2, 4, 5, 5, 2, 7, 7, 1, 7, 1, 6, 5, 7, 7, 8, 3, 1, 7, 7, 2, 8, 1, 5, 8, 1, 3, 7, 3, 7, 6, 6, 4, 6, 9, 5, 1, 6, 1, 3, 1, 9, 7, 3, 9, 1, 8, 9, 4, 1, 7, 8, 1, 6, 4, 9, 9, 4, 7, 7, 6, 2, 8, 9, 3, 6, 8, 7, 5, 2, 8, 6, 4, 7, 7, 4, 7, 3, 1, 5, 7, 3, 7, 2, 4, 6, 4, 2, 1, 9, 3, 8, 3, 4, 9, 5, 6, 9, 1, 6, 1, 8, 8, 7, 6, 4, 6, 6, 1, 3, 1, 9, 4, 7, 6, 9, 1, 9, 4, 9, 3, 2, 7, 1, 8, 9, 7, 2, 3, 2, 3, 7, 9, 7, 9, 9, 9, 6, 2, 3, 2, 3, 8, 8, 4, 6, 5, 5, 2, 1, 4, 4, 5, 2, 6, 8, 4, 4, 7, 5, 7, 7, 8, 2, 3, 3, 4, 5, 3, 9, 9, 2, 7, 8, 4, 7, 3, 4, 3, 6, 5, 6, 3, 2, 5, 7, 6, 8, 4, 7, 3, 1, 7, 1, 7, 4, 2, 5, 6, 8, 4, 8, 2, 3, 8, 5, 8, 9, 1, 9, 7, 1, 1, 8, 7, 8, 8, 7, 3, 1, 8, 2, 5, 2, 1, 4, 2, 1, 9, 3, 1, 2, 6, 2, 1, 7, 8, 2, 6, 3, 5, 5, 4, 2, 6, 1, 6, 4, 1, 3, 1, 5, 7, 8, 4, 4, 6, 2, 2, 8, 5, 1, 8, 6, 9, 5, 4, 9, 4, 2, 4, 6, 3, 2, 1, 2, 8, 1, 6, 7, 7, 2, 4, 3, 4, 8, 1, 1, 4, 4, 9, 6, 7, 5, 3, 6, 1, 7, 2, 9, 8, 2, 7, 8, 4, 9, 9, 5, 3, 6, 9, 6, 5, 4, 2, 5, 8, 6, 1, 9, 9, 8, 9, 9, 2, 9, 1, 5, 6, 6, 2, 7, 2, 7, 5, 8, 6, 5, 4, 8, 6, 1, 5, 8, 1, 7, 6, 1, 1, 6, 5, 2, 2, 5, 4, 2, 7, 4, 4, 6, 5, 7, 2, 7, 3, 8, 1, 5, 3, 7, 5, 8, 6, 8, 6, 3, 8, 5, 4, 7, 8, 8, 5, 8, 8, 7, 9, 3, 4, 4, 5, 9, 5, 9, 6, 1, 7, 9, 5, 2, 4, 3, 6, 9, 2, 7, 1, 5, 1, 2, 4, 8, 8, 6, 9, 5, 3, 2, 4, 2, 6, 5, 1, 1, 9, 6, 8, 5, 1, 8, 2, 1, 8, 3, 5, 7, 3, 1, 5, 7, 7, 8, 3, 7, 1, 8, 9, 2, 1, 3, 3, 7, 9, 4, 5, 8, 2, 5, 8, 7, 4, 6, 1, 1, 6, 3, 8, 2, 1, 2, 2, 2, 6, 3, 2, 6, 9, 6, 9, 1, 3, 5, 4, 8, 4, 1, 1, 8, 9, 6, 4, 9, 6, 2, 4, 5, 1, 2, 5, 6, 4, 8, 7, 9, 6, 8, 2, 5, 3, 3, 5, 2, 6, 7, 1, 2, 9, 6, 3, 5, 8, 6, 5, 7, 8, 8, 4, 3, 4, 2, 3, 2, 7, 1, 8, 7, 7, 5, 3, 4, 1, 7, 9, 3, 9, 6, 1, 6, 1, 2, 1, 5, 9, 1, 6, 8, 6, 8, 1, 9, 2, 4, 5, 2, 2, 3, 7, 9, 3, 8, 8, 9, 9, 6, 6, 5, 7, 4, 4, 4, 3, 7, 2, 1, 9, 6, 3, 4, 9, 1, 1, 3, 5, 2, 2, 3, 3, 8, 7, 9, 2, 7, 3, 7, 5, 5, 9, 1, 6, 8, 5, 8, 5, 4, 5, 9, 4, 1, 2, 8, 9, 6, 7, 1, 1, 1, 9, 6, 8, 2, 3, 9, 7, 4, 3, 3, 4, 5, 1, 7, 1, 4, 8, 9, 4, 9, 6, 8, 1, 8, 9, 5, 9, 8, 2, 4, 8, 1, 1, 9, 6, 1, 4, 4, 1, 4, 1, 6, 3, 3, 4, 8, 2, 8, 3, 4, 2, 4, 5, 8, 8, 2, 8, 3, 8, 1, 8, 4, 6, 8, 6, 8, 5, 2, 5, 5, 6, 4, 9, 3, 7, 3, 4, 4, 3, 1, 6, 8, 2, 5, 1, 8, 6, 8, 6, 6, 8, 1, 3, 7, 5, 1, 8, 3, 9, 6, 1, 7, 5, 3, 5, 6, 5, 5, 8, 5, 4, 1, 8, 6, 7, 1, 3, 8, 4, 1, 1, 8, 9, 3, 7, 1, 6, 1, 9, 2, 5, 4, 3, 7, 8, 8, 3, 4, 6, 3, 5, 8, 9, 2, 7, 1, 5, 9, 1, 6, 4, 5, 2, 5, 3, 7, 6, 5, 6, 4, 7, 4, 8, 9, 9, 2, 4, 6, 6, 4, 9, 1, 2, 4, 7, 1, 3, 7, 1, 6, 5, 1, 4, 3, 8, 7, 5, 7, 5, 4, 2, 1, 8, 1, 7, 1, 5, 4, 3, 4, 1, 7, 3, 7, 7, 3, 9, 9, 9, 1, 9, 7, 8, 8, 7, 7, 8, 5, 6, 4, 3, 2, 6, 5, 8, 7, 2, 2, 5, 6, 6, 4, 1, 5, 9, 9, 1, 8, 4, 5, 9, 8, 6, 6, 8, 1, 2, 6, 8, 4, 5, 5, 8, 9, 4, 6, 1, 2, 5, 6, 6, 7, 8, 3, 6, 1, 9, 8, 4, 5, 7, 8, 7, 7, 3, 8, 7, 8, 3, 3, 5, 8, 3, 1, 7, 7, 3, 2, 3, 9, 7, 6, 7, 7, 1, 4, 7, 6, 3, 4, 7, 3, 7, 8, 6, 8, 7, 4, 5, 5, 9, 6, 2, 4, 5, 3, 7, 6, 3, 1, 8, 4, 2, 9, 8, 8, 1, 9, 3, 9, 9, 4, 7, 4, 1, 6, 4, 7, 7, 1, 9, 1, 6, 8, 9, 3, 8, 3, 3, 5, 4, 9, 2, 2, 5, 3, 1, 1, 9, 6, 4, 9, 3, 7, 4, 3, 3, 8, 2, 7, 4, 2, 9, 3, 7, 4, 8, 2, 1, 3, 2, 7, 9, 6, 1, 5, 1, 1, 5, 1, 9, 5, 9, 2, 9, 8, 8, 3, 5, 2, 5, 4, 1, 4, 7, 9, 5, 2, 1, 8, 8, 1, 4, 4, 2, 4, 3, 2, 5, 5, 9, 8, 4, 9, 2, 5, 7, 7, 2, 2, 6, 2, 6, 5, 9, 5, 9, 3, 1, 2, 8, 5, 7, 9, 8, 7, 6, 5, 1, 5, 4, 3, 2, 3, 9, 1, 8, 7, 7, 1, 7, 4, 5, 9, 2, 9, 9, 3, 4, 8, 3, 5, 9, 6, 8, 2, 9, 1, 1, 3, 5, 1, 2, 5, 3, 5, 8, 9, 2, 2, 1, 1, 3, 3, 7, 2, 8, 3, 3, 9, 6, 7, 5, 9, 1, 6, 6, 6, 8, 4, 4, 5, 3, 6, 2, 5, 3, 3, 8, 1, 5, 8, 3, 5, 3, 4, 5, 3, 1, 8, 3, 2, 6, 7, 7, 1, 5, 1, 9, 3, 9, 2, 5, 6, 6, 2, 5, 1, 1, 3, 8, 2, 5, 7, 5, 3, 2, 7, 3, 7, 8, 7, 1, 7, 9, 9, 9, 9, 7, 2, 4, 7, 7, 1, 5, 2, 4, 1, 2, 6, 9, 3, 5, 1, 3, 6, 6, 3, 5, 4, 7, 2, 8, 6, 5, 7, 3, 5, 2, 1, 6, 1, 6, 7, 7, 9, 5, 5, 5, 2, 4, 8, 5, 4, 2, 1, 9, 2, 6, 1, 7, 6, 4, 5, 5, 5, 3, 6, 3, 3, 8, 6, 9, 1, 8, 4, 6, 7, 1, 4, 3, 1, 4, 3, 2, 2, 1, 2, 6, 4, 8, 4, 3, 2, 4, 6, 4, 8, 9, 3, 1, 5, 2, 9, 8, 1, 4, 3, 4, 8, 3, 1, 5, 9, 7, 1, 8, 7, 8, 7, 4, 1, 2, 5, 2, 7, 3, 5, 7, 6, 1, 2, 2, 2, 1, 3, 2, 6, 6, 1, 3, 2, 9, 7, 7, 4, 2, 8, 3, 6, 2, 7, 4, 2, 6, 6, 6, 4, 1, 3, 6, 1, 2, 7, 7, 3, 2, 3, 4, 6, 3, 2, 9, 4, 7, 1, 5, 8, 4, 4, 8, 8, 4, 5, 4, 4, 4, 4, 4, 9, 3, 8, 6, 7, 6, 1, 9, 8, 5, 2, 1, 1, 4, 8, 1, 5, 1, 1, 9, 5, 3, 6, 9, 9, 5, 3, 4, 3, 2, 2, 7, 4, 7, 8, 3, 3, 7, 8, 5, 5, 4, 1, 8, 3, 9, 6, 6, 6, 3, 3, 4, 9, 8, 6, 4, 4, 7, 6, 6, 4, 2, 6, 8, 6, 7, 7, 8, 6, 6, 7, 7, 3, 8, 9, 7, 2, 7, 6, 4, 6, 9, 3, 1, 8, 3, 9, 2, 7, 1, 9, 8, 4, 5, 6, 9, 1, 7, 9, 7, 3, 9, 6, 7, 6, 3, 2, 2, 8, 5, 4, 9, 9, 2, 5, 9, 8, 1, 9, 6, 2, 8, 6, 6, 8, 2, 5, 8, 2, 8, 1, 1, 3, 1, 4, 9, 4, 7, 6, 7, 7, 8, 3, 6, 8, 5, 5, 7, 9, 9, 4, 2, 5, 3, 9, 7, 8, 4, 7, 8, 7, 1, 9, 4, 1, 3, 8, 1, 4, 9, 2, 6, 9, 7, 5, 8, 7, 4, 7, 2, 1, 6, 6, 2, 4, 3, 6, 2, 6, 1, 2, 9, 4, 7, 1, 8, 9, 2, 2, 4, 7, 5, 2, 3, 4, 5, 1, 2, 1, 6, 4, 9, 7, 2, 4, 9, 3, 1, 6, 1, 5, 2, 7, 7, 1, 7, 5, 5, 5, 1, 4, 8, 2, 5, 9, 4, 6, 7, 3, 9, 3, 2, 2, 7, 1, 9, 7, 5, 9, 1, 5, 6, 8, 4, 1, 3, 1, 8, 1, 3, 6, 3, 3, 7, 3, 7, 5, 5, 1, 3, 9, 3, 1, 3, 4, 4, 1, 6, 4, 7, 3, 3, 6, 7, 5, 3, 9, 2, 2, 3, 2, 3, 9, 6, 7, 2, 8, 7, 1, 7, 1, 6, 1, 5, 6, 2, 9, 5, 2, 4, 4, 2, 1, 4, 5, 6, 3, 3, 2, 2, 2, 2, 7, 4, 1, 2, 1, 6, 9, 6, 3, 5, 4, 3, 7, 9, 9, 3, 8, 2, 5, 9, 3, 5, 3, 3, 7, 2, 4, 5, 4, 6, 5, 8, 8, 1, 9, 4, 8, 7, 7, 7, 1, 7, 7, 9, 6, 4, 4, 6, 1, 5, 1, 2, 1, 5, 7, 3, 2, 9, 7, 2, 7, 5, 6, 2, 4, 8, 8, 2, 5, 3, 5, 1, 3, 9, 1, 1, 8, 5, 9, 7, 1, 6, 6, 7, 3, 4, 3, 4, 5, 8, 5, 7, 5, 8, 6, 8, 3, 6, 5, 1, 5, 7, 6, 7, 1, 8, 4, 8, 8, 2, 7, 8, 6, 8, 2, 5, 3, 5, 5, 2, 8, 3, 6, 1, 4, 9, 2, 4, 2, 8, 4, 4, 9, 2, 8, 6, 1, 6, 2, 3, 2, 2, 5, 5, 8, 2, 5, 4, 6, 3, 6, 1, 9, 5, 6, 4, 4, 2, 8, 7, 1, 9, 4, 8, 8, 1, 9, 4, 2, 7, 6, 3, 4, 9, 1, 3, 7, 3, 9, 8, 1, 4, 6, 7, 8, 6, 1, 5, 2, 6, 1, 6, 7, 2, 4, 9, 6, 9, 7, 7, 7, 5, 6, 8, 7, 7, 3, 2, 8, 7, 8, 6, 8, 6, 6, 7, 4, 1, 5, 5, 9, 4, 1, 8, 2, 6, 1, 8, 5, 8, 6, 2, 7, 3, 4, 7, 7, 3, 4, 9, 9, 3, 2, 9, 7, 6, 2, 4, 9, 6, 6, 1, 2, 6, 9, 6, 7, 9, 5, 2, 7, 4, 2, 8, 8, 9, 1, 2, 5, 2, 7, 4, 2, 1, 6, 5, 8, 7, 6, 8, 5, 8, 7, 2, 9, 2, 4, 7, 7, 7, 1, 1, 7, 8, 5, 1, 1, 9, 9, 5, 1, 6, 9, 5, 3, 8, 4, 8, 2, 3, 9, 7, 4, 9, 7, 7, 5, 3, 2, 7, 9, 5, 9, 6, 3, 6, 6, 5, 1, 9, 1, 3, 4, 7, 2, 7, 7, 8, 2, 1, 5, 8, 9, 4, 8, 4, 9, 1, 1, 9, 8, 7, 3, 1, 3, 1, 1, 2, 7, 5, 5, 4, 6, 6, 1, 7, 9, 5, 1, 2, 7, 2, 5, 8, 6, 9, 8, 2, 7, 4, 6, 1, 9, 8, 2, 2, 3, 4, 4, 4, 2, 6, 7, 4, 1, 1, 7, 5, 7, 8, 7, 7, 6, 6, 1, 5, 1, 6, 3, 8, 2, 3, 9, 7, 2, 3, 4, 2, 9, 6, 5, 8, 2, 1, 4, 6, 8, 1, 9, 3, 1, 1, 2, 5, 6, 7, 9, 9, 4, 1, 5, 6, 8, 6, 5, 7, 6, 2, 3, 3, 2, 5, 6, 2, 2, 3, 5, 5, 4, 5, 5, 4, 6, 9, 3, 8, 2, 5, 3, 9, 6, 8, 4, 6, 7, 2, 8, 7, 8, 3, 3, 4, 1, 6, 8, 2, 5, 5, 2, 2, 5, 8, 8, 5, 3, 5, 2, 5, 3, 1, 4, 9, 6, 3, 4, 4, 9, 8, 7, 2, 3, 9, 3, 4, 7, 9, 5, 6, 9, 2, 5, 2, 4, 7, 6, 6, 1, 3, 6, 2, 9, 7, 4, 8, 1, 3, 3, 9, 5, 7, 1, 2, 6, 5, 5, 7, 5, 9, 5, 3, 1, 9, 8, 3, 1, 2, 6, 1, 1, 9, 8, 3, 7, 9, 3, 5, 8, 6, 7, 5, 2, 2, 7, 1, 4, 2, 4, 2, 2, 6, 8, 4, 5, 5, 8, 7, 5, 1, 6, 4, 3, 6, 7, 4, 9, 5, 6, 7, 7, 7, 9, 8, 9, 3, 7, 7, 5, 9, 1, 5, 8, 4, 4, 1, 8, 3, 9, 1, 4, 9, 1, 8, 3, 9, 7, 3, 5, 9, 3, 7, 4, 2, 1, 1, 9, 6, 9, 6, 6, 6, 7, 8, 1, 4, 5, 6, 2, 6, 7, 8, 6, 3, 3, 2, 5, 1, 7, 1, 7, 4, 4, 1, 5, 9, 3, 3, 6, 3, 2, 3, 7, 2, 9, 4, 3, 7, 1, 5, 4, 8, 7, 4, 9, 5, 3, 6, 8, 2, 5, 3, 7, 4, 1, 1, 9, 1, 7, 3, 7, 9, 9, 7, 3, 2, 8, 5, 5, 6, 2, 4, 4, 2, 7, 8, 3, 1, 5, 3, 3, 5, 3, 7, 8, 6, 8, 7, 4, 7, 4, 7, 7, 9, 7, 7, 1, 7, 4, 5, 6, 6, 4, 7, 5, 7, 6, 8, 8, 2, 4, 9, 4, 2, 7, 8, 6, 7, 7, 1, 4, 9, 5, 5, 5, 7, 2, 8, 5, 3, 9, 9, 5, 7, 9, 1, 3, 6, 3, 1, 2, 7, 3, 1, 5, 5, 2, 6, 3, 5, 9, 7, 1, 1, 5, 3, 5, 6, 2, 7, 7, 1, 2, 5, 9, 9, 6, 3, 2, 6, 7, 3, 4, 7, 2, 5, 1, 6, 7, 8, 1, 7, 3, 3, 8, 9, 4, 5, 5, 6, 6, 2, 3, 9, 8, 7, 2, 3, 6, 7, 5, 2, 3, 5, 5, 1, 7, 8, 9, 2, 7, 2, 2, 4, 3, 3, 5, 2, 1, 2, 8, 5, 4, 5, 8, 2, 5, 9, 9, 6, 1, 1, 3, 4, 6, 8, 8, 5, 2, 7, 9, 8, 8, 6, 4, 5, 1, 8, 7, 9, 4, 6, 7, 3, 6, 3, 3, 4, 8, 2, 8, 9, 6, 9, 2, 6, 7, 1, 3, 2, 3, 4, 5, 3, 3, 8, 9, 8, 4, 3, 5, 5, 7, 2, 9, 6, 2, 7, 8, 9, 2, 4, 4, 6, 9, 9, 1, 3, 4, 3, 4, 2, 5, 8, 4, 8, 9, 8, 5, 7, 5, 3, 5, 4, 2, 8, 8, 2, 6, 9, 8, 2, 5, 9, 1, 1, 6, 6, 1, 8, 7, 9, 6, 5, 7, 7, 1, 5, 4, 1, 3, 6, 7, 6, 8, 7, 6, 3, 4, 4, 4, 6, 6, 2, 7, 8, 1, 7, 4, 2, 2, 3, 1, 4, 6, 1, 1, 5, 7, 3, 8, 1, 5, 7, 7, 5, 2, 6, 1, 7, 9, 2, 6, 5, 5, 3, 2, 2, 8, 6, 6, 8, 6, 7, 7, 8, 2, 1, 6, 8, 4, 7, 6, 8, 6, 1, 1, 1, 7, 4, 5, 8, 8, 9, 4, 1, 5, 6, 8, 6, 4, 8, 1, 8, 7, 7, 5, 1, 6, 1, 1, 1, 8, 7, 2, 8, 8, 1, 9, 4, 2, 3, 9, 9, 3, 9, 1, 4, 7, 3, 4, 8, 8, 8, 1, 9, 3, 6, 7, 7, 7, 3, 6, 2, 6, 8, 7, 6, 7, 5, 4, 7, 5, 5, 2, 8, 9, 1, 4, 8, 4, 4, 7, 1, 3, 3, 3, 1, 9, 3, 2, 1, 1, 3, 3, 8, 8, 4, 5, 7, 5, 9, 6, 1, 1, 1, 4, 3, 6, 8, 4, 5, 8, 3, 8, 1, 3, 2, 2, 4, 1, 1, 4, 7, 3, 3, 7, 4, 4, 3, 9, 7, 2, 2, 1, 2, 6, 9, 5, 7, 3, 6, 9, 6, 4, 3, 9, 5, 9, 3, 8, 2, 8, 7, 4, 5, 9, 9, 2, 2, 2, 6, 2, 1, 7, 1, 5, 2, 9, 4, 3, 3, 5, 4, 1, 2, 1, 8, 4, 4, 8, 1, 4, 5, 4, 8, 7, 7, 6, 1, 1, 2, 2, 6, 5, 6, 4, 3, 9, 4, 7, 1, 7, 2, 8, 8, 4, 9, 6, 7, 2, 3, 9, 1, 2, 1, 3, 5, 8, 4, 1, 4, 5, 3, 7, 9, 9, 2, 3, 7, 9, 4, 3, 9, 9, 2, 7, 6, 5, 3, 9, 7, 7, 8, 4, 2, 9, 4, 6, 1, 8, 5, 2, 9, 8, 9, 4, 5, 3, 8, 1, 2, 8, 4, 9, 5, 8, 5, 5, 6, 8, 2, 2, 8, 6, 4, 1, 4, 9, 4, 8, 6, 3, 3, 9, 3, 5, 4, 6, 6, 7, 4, 4, 4, 4, 5, 9, 9, 8, 4, 5, 4, 4, 3, 2, 3, 4, 1, 1, 4, 6, 7, 7, 3, 2, 1, 8, 2, 8, 3, 7, 1, 7, 4, 7, 8, 7, 6, 9, 2, 4, 6, 4, 9, 4, 4, 5, 3, 3, 7, 3, 1, 7, 4, 2, 7, 2, 1, 2, 6, 3, 8, 4, 1, 1, 8, 1, 7, 1, 4, 5, 5, 6, 2, 3, 8, 8, 2, 1, 9, 5, 4, 8, 2, 1, 7, 6, 8, 8, 2, 2, 1, 3, 2, 2, 5, 4, 6, 7, 9, 8, 8, 9, 5, 2, 4, 7, 1, 3, 9, 3, 6, 5, 9, 9, 5, 3, 5, 8, 3, 5, 4, 3, 6, 3, 8, 4, 3, 3, 5, 3, 8, 1, 7, 4, 6, 1, 5, 4, 9, 8, 8, 9, 2, 2, 7, 2, 3, 3, 3, 7, 5, 7, 2, 1, 3, 2, 5, 9, 3, 7, 3, 5, 5, 8, 8, 9, 2, 3, 5, 7, 4, 6, 3, 8, 4, 4, 6, 3, 7, 8, 3, 9, 7, 7, 5, 1, 3, 2, 3, 1, 9, 4, 5, 3, 1, 1, 1, 2, 8, 1, 5, 4, 9, 4, 9, 1, 1, 2, 4, 7, 4, 5, 8, 4, 3, 9, 5, 7, 5, 8, 8, 6, 2, 1, 6, 8, 3, 9, 2, 8, 1, 6, 7, 5, 9, 2, 9, 6, 1, 5, 7, 7, 6, 6, 3, 3, 1, 1, 7, 1, 1, 3, 5, 5, 2, 8]
    
    address_factor: 4