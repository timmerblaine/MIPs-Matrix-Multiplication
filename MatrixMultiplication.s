.data
ARRAYA:	.space		144	# 6 x 6 block is 36 words, 4 bytes per word, 4 * 36 = 144
ARRAYB:	.space		144	# 6 x 6 matrix b
ARRAYC:	.space		144	# 6 x 6 matrix c
MSG1:	.asciiz		"Welcome to the Matrix Multiplication Program\n"
MSG2:	.asciiz		"Enter a square matrix side length between 2 - 6: "
MSG3:	.asciiz		"Input values to fill array A:\n"
MSG4:	.asciiz		"Input values to fill array B:\n"
MSG5:	.asciiz		"Printing Array A:\n"
MSG6:	.asciiz		"Printing Array B:\n"
MSG7:	.asciiz		"Printing Array C, the product of the two prior matrices:\n"
EOL:	.byte		'\n'
SPACE:	.byte		' '
	.text
	.globl main
main:
	li	$v0,4
	la	$a0,MSG1
	syscall	
	li	$t6,2		# Lower bound of size; size must be > 1 (2 - 6)
	li	$t7,6		# Upper bound of size; size must be < 7 (2 - 6)
SIZE:	li	$v0,4
	la	$a0,MSG2	# Prompt user to enter square matrix size
	syscall	
	li	$v0,5		# Tell syscall to read in an integer
	syscall			# Read given integer
	move	$t1,$v0		# Save $v0 integer to $t0, $t0 = size
	sltu	$t0,$t1,$t6	# If (size < 1) then $t0 = 1, else $t0 = 0
	sltu	$t2,$t7,$t1	# If (7 < size) then $t2 = 1, else $t2 = 0
	bgtz	$t0,SIZE	# If ($t0 > 0) then go to SIZE for re-input of size
	bgtz	$t2,SIZE	# If ($t2 > 0) then go to SIZE for re-input of size
	
	addiu	$sp,$sp,-4	# Push one word of stack space
	sw	$ra,0($sp)	# Save current return address
	li	$v0,4
	la	$a0,MSG3	# Print out "Input values to fill array A:\n"
	syscall	
	move	$a3,$t1		# $a3 = size, parameter for fill
	la	$a1,ARRAYA	# $a1 = ARRAYA, parameter for fill
	jal	FILL		# Call function FILL to fill array
	li	$v0,4
	la	$a0,MSG4	# Print out "Input values to fill array B:\n"
	syscall	
	la	$a1,ARRAYB	# $a1 = ARRAYB, parameter for fill
	jal	FILL		# Call function FILL to fill array
	
	la 	$a0,ARRAYA	# $a0 is ARRAYA or a[6][6]
	la	$a1,ARRAYB	# $a1 is ARRAYB or b[6][6]
	la	$a2,ARRAYC	# $a2 is ARRAYC or c[6][6]
	move	$a3,$t1		# $a3 = size
	jal	MM		# Call function MM (Matrix Multiply), send in registers $a0-$a3
	li	$v0,4
	la	$a0,MSG5	# Print "Printing Array A"
	syscall	
	la	$a1,ARRAYA	# Load array address to be passed into PRINT
	jal	PRINT		# Jump and link to PRINT Matrix stored in $a1
	li	$v0,4
	la	$a0,MSG6	# Print "Printing Array B"
	syscall	
	la	$a1,ARRAYB	# Load array as parameter
	jal	PRINT		# Call function PRINT
	li	$v0,4
	la	$a0,MSG7	# Print "Printing Array C"
	syscall	
	la	$a1,ARRAYC	# Load array as parameter
	jal	PRINT		# Call function PRINT
	lw	$ra,0($sp)	# Load contents of stack space back 
				# into return address ($ra)
	addiu	$sp,$sp,4	# Pop 4 bytes back
	jr	$ra		# End program
FILL:				# Parameters: $a1 = array/matrix, $a3 = size; No return
	move	$t1,$a3		# Pass size in, save as $t1. $t1 = row size/loop end
	li	$s0,0		# i = 0;
F1:	li	$s1,0		# j = 0;
F2:	mul	$t2,$s0,$t1	# $t2 = i * (row size)
	addu	$t2,$t2,$s1	# $t2 = (i * row size) + j for total # of bytes
	sll	$t2,$t2,2	# $t2 = $t2 * 4; ( 4 = 2^2), since 4 bytes per word
	addu	$t2,$a1,$t2	# $t2 = byte address of matrix[i][j], $a1 is the parameter

	li	$v0,5		# Tell syscall to read in an integer
	syscall			# Read given integer
	sw	$v0,0($t2)	# m[i][j] = $v0 <- input
	
	addiu	$s1,$s1,1	# j++;
	bne	$s1,$t1,F2	# if (j != size) go to FM2
	addiu	$s0,$s0,1	# i++
	bne	$s0,$t1,F1	# if (i != size) go to FM1
	jr	$ra
MM:				# Params: $a0-$a2: arrays a, b, c, and $a3 = size; No return
	move 	$t1,$a3		# Pass size in, save as $t1. $t1 = row size/loop end
	li	$s0,0		# i = 0; first for loop variable
L1:	li	$s1,0		# j = 0; second for loop variable & restart
L2:	li	$s2,0		# k = 0; third for loop variable & restart
	mul	$t2,$s0,$t1	# $t2 = i * (row size)
	addu	$t2,$t2,$s1	# $t2 = (i * row size) + j for total # of bytes
	sll	$t2,$t2,2	# $t2 = $t2 * 4; ( 4 = 2^2), since 4 bytes per word
	addu	$t2,$a2,$t2	# $t2 = byte address of c[i][j]
	lw	$t4, 0($t2)	# $t4 = 4 bytes of c[i][j]
	
L3:	mul	$t0,$s2,$t1	# $t0 = k * (row size)
	addu	$t0,$t0,$s1	# $t0 = (k * row size) + j for total # of bytes
	sll	$t0,$t0,2	# $t0 = $t0 * 4; ( 4 = 2^2), since 4 bytes per word
	addu	$t0,$a1,$t0	# $t0 = byte address of b[k][j]
	lw	$t5, 0($t0)	# $t5 = 4 bytes of b[k][j]
	
	mul	$t0,$s0,$t1	# $t0 = i * (row size)
	addu	$t0,$t0,$s2	# $t0 = (i * row size) + k for total # of bytes
	sll	$t0,$t0,2	# $t0 = $t0 * 4; ( 4 = 2^2), since 4 bytes per word
	addu	$t0,$a0,$t0	# $t0 = byte address of a[i][k]
	lw	$t6, 0($t0)	# $t6 = 4 bytes of a[i][k]
	
	mul	$t5,$t6,$t5	# $t5 = a[i][k] * b[k][j]
	addu	$t4,$t4,$t5	# $t4 = c[i][j] + a[i][k] * b[k][j]
	addiu	$s2,$s2,1	# k++
	bne	$s2,$t1,L3	# If (k != size) go to L3
	
	sw	$t4,0($t2)	# c[i][j] = $t4
	addiu	$s1,$s1,1	# j++
	bne	$s1,$t1,L2	# if (j != size) go to L2
	addiu	$s0,$s0,1	# i++
	bne	$s0,$t1,L1	# if (i != size) go to L1
	
	jr 	$ra		# Return to main
PRINT:				# Params: $a3 = size, $a1 = array[][]; no return.
	move	$t1,$a3		# Pass size in, save as $t1. $t1 = row size/loop end
	li	$s0,0		# i = 0;
P1:	li	$s1,0		# j = 0;
P2:	mul	$t2,$s0,$t1	# $t2 = i * (row size)
	addu	$t2,$t2,$s1	# $t2 = (i * row size) + j for total # of bytes
	sll	$t2,$t2,2	# $t2 = $t2 * 4; ( 4 = 2^2), since 4 bytes per word
	addu	$t2,$a1,$t2	# $t2 = byte address of matrix[i][j], $a1 is the parameter
	lw	$a0, 0($t2)	# $a0 = matrix[$t2] = m[i][j]
	li 	$v0,1		# Prepare to print an integer
	syscall
	lb	$a0,SPACE	# Load space byte
	li	$v0,11		# Print space byte
	syscall
	
	addiu	$s1,$s1,1	# j++;
	bne	$s1,$t1,P2	# if (j != size) go to P2 (innermost loop)
	lb	$a0,EOL		# Load byte EOL
	li	$v0,11		# Prepare to print a byte
	
	syscall			# Print a new line for new row of matrix
	addiu	$s0,$s0,1	# i++
	bne	$s0,$t1,P1	# if (i != size) go to P1 (outermost loop)
	jr	$ra
