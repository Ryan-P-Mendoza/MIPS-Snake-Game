# Snake game in MIPS
# Unit Width: 8	
# Unit Height: 8
# Display Width: 512
# Display Height: 512
# Base Address for Display:($gp)

.data

displayX: 	.word 64
displayY: 	.word 64
snake: 	.word	0x0ff020 # green
blank:	.word	0x000000 # blank
border: .word	0xa04000 # brown	
fruit: 	.word	0xf01b0f # red

score: 		.word 0
scoreMultiplier:.word 20 # How many points a fruit gives
snakeSpeed:	.word 200 # speed of snake, increases based on score (actual value decreases which makes it faster)
Levels: 	.word 100, 150, 200, 500, 750, 850, 1000 # scores for when game gets harder
scoreArrayIndex:.word 0

gameOverMessage:.asciiz "You lost! Your score is: "
restartMessage:	.asciiz "Restart?"

headXCoord: 	.word 30 # snake head x-coords
headYCoord:	.word 30 # snake head y-coords
tailXCoord:	.word 30 # snake tail x-coords
tailYCoord:	.word 36 # snake tail y-coords
headDirection:	.word 115 # direction the snake moves in
tailTrailing:	.word 115 # direction tail follows to follow snake

changeDirectionArray:	.word 0:200 # when tail hits an element in this array it changes direction (max of 100 length for snake)
changeNewDirectionArray:.word 0:200 # array for what direction the tail moves in
arrayIndex:		.word 0 # array iterators
locationInArray:	.word 0 # array iterators

fruitXCoord: .word
fruitYCoord: .word

.text
main:
	lw $a2, blank # load color
	lw $a0, displayX # display width
	lw $a1, displayX # display height
	mul $a3, $a1, $a0 # display
	mul $a3, $a3, 4 # word align our display counter
	add $a1, $zero, $gp # iterator
	add $a3, $a3, $gp

# Reset the screen to blank by going through every pixel until done	
Fill:
	beq $a1, $a3, variableInitializer
	sw $a2, 0($a1) # set the background pixels to blank 
	addiu $a1, $a1, 4 # counter incramenting on word boundary
	j Fill

# Initialize variables and wipe registers
variableInitializer:
	# Reset values for replay functionality
	
	sw $zero, arrayIndex
	sw $zero, locationInArray
	sw $zero, scoreArrayIndex
	sw $zero, score
	
	li $t0, 20
	sw $t0, scoreMultiplier
	
	li $t0, 250
	sw $t0, snakeSpeed
	
	li $t0, 30
	sw $t0, headXCoord
	sw $t0, headYCoord
	sw $t0, tailXCoord
	
	li $t0, 36
	sw $t0, tailYCoord
	
	li $t0, 119
	sw $t0, headDirection
	sw $t0, tailTrailing
	
	
	# clear all registers for replayability and avoiding errors
	li $v0, 0
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0

# Drawing the border around the screen by doing it one side at a time and iterating through every pixel of a side until done
TopBorder:
	move $a0, $t1	# store x-coord
	li $a1, 0	# y-coord to 0 for top
	jal coordToAddress	# get coord address
	move $a0, $v0	# store screen address 
	lw $a1, border # store color
	jal draw	# draw color

	add $t1, $t1, 1 # move to next pixel	
	bne $t1, 64, TopBorder # loop through top
	li $t1, 0	# reset coord for orgin point

RightBorder:
	move $a1, $t1	
	li $a0, 63	
	jal coordToAddress	
	move $a0, $v0	
	lw $a1, border	
	jal draw
	
	add $t1, $t1, 1	# move to next pixel
	bne $t1, 64, RightBorder # loop through right
	li $t1, 0 # reset coord for orgin point

LeftBorder:
	move $a1, $t1	
	li $a0, 0	
	jal coordToAddress	
	move $a0, $v0	
	lw $a1, border	
	jal draw
	
	add $t1, $t1, 1	# move to next pixel
	bne $t1, 64, LeftBorder	# loop through left	
	li $t1, 0 # reset coord for orgin point
	
BottomBorder:
	move $a0, $t1	
	li $a1, 63	
	jal coordToAddress	
	move $a0, $v0	
	lw $a1, border	
	jal draw
	
	add $t1, $t1, 1	# move to next pixel
	bne $t1, 64, BottomBorder # loop through bottom



# Create snake and fruit by drawing them out and generating a random spot for first fruit
snakeHead:
	
	lw $a0, headXCoord #load coords
	lw $a1, headYCoord 
	jal coordToAddress # get address
	move $a0, $v0 # save address
	lw $a1, snake # load color
	jal draw


	li $t1, 1
drawBody:
	# draw body same as head just down 1 pixel, then another, looping 6 times.
	lw $a0, headXCoord
	lw $a1, headYCoord
	add $a1, $a1, $t1
	add $t1, $t1, 1
	jal coordToAddress 

	move $a0, $v0 
	lw $a1, snake 
	jal draw

	bne $t1, 6, drawBody

	# draw tail
	lw $a0, tailXCoord # load coords
	lw $a1, tailYCoord 
	jal coordToAddress # get address
	move $a0, $v0 # store address
	lw $a1, snake # color
	jal draw	
	

CreateFruit:

	li $v0, 42 # random integer generator
	li $a1, 60 # upper bound of 59 which is 64 width/height - 4 for borders
	syscall
	
	addiu $a0, $a0, 1 # incrament by 1 pixel to avoid border
	sw $a0, fruitXCoord # store x
	syscall
	
	addiu $a0, $a0, 1 # increment by one pixel to avoid border
	sw $a0, fruitYCoord # store y
	jal IncreaseDifficulty # check for difficulty increase
	
# Input/Direction checks
checkInput:
	
	lw $a0, snakeSpeed 
	jal Wait

	# get the new direction if needed
	lw $a0, headXCoord
	lw $a1, headYCoord
	jal coordToAddress
	add $a2, $v0, $zero

	# read new input from the user
	li $t0, 0xffff0000
	lw $t1, ($t0)
	andi $t1, $t1, 0x0001
	beqz $t1, chooseDirection # if no input then keep going
	lw $a1, 4($t0) # load new direction
	
DirectionCheck:
	
	lw $a0, headDirection # current direction

	jal directionChecker	# make sure valid direction change
	beqz $v0, checkInput	# if not valid, read new input
	sw $a1, headDirection	# store new direction
	lw $t7, headDirection

	
# Next Frame			
chooseDirection:
	# get direction to move based on input
	beq $t7, 119, DrawUp
	beq  $t7, 115, DrawDown
	beq  $t7, 97, DrawLeft
	beq  $t7, 100, DrawRight
	
	j checkInput # if no valid input then get another input
	
DrawUp:
	# check for border
	lw $a0, headXCoord
	lw $a1, headYCoord
	lw $a2, headDirection
	jal gameOverCheck
	
	# next frame for head moving up
	lw $t0, headXCoord
	lw $t1, headYCoord
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal coordToAddress
	add $a0, $v0, $zero
	lw $a1, snake
	jal draw

	sw  $t1, headYCoord
	j updateTail # next frame tail moving up
	
DrawDown:
	# border check
	lw $a0, headXCoord
	lw $a1, headYCoord
	lw $a2, headDirection	
	jal gameOverCheck
	
	# move down
	lw $t0, headXCoord
	lw $t1, headYCoord
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal coordToAddress
	add $a0, $v0, $zero
	lw $a1, snake
	jal draw
	
	sw  $t1, headYCoord	
	j updateTail 

DrawLeft:
	# border check
	lw $a0, headXCoord
	lw $a1, headYCoord
	lw $a2, headDirection	
	jal gameOverCheck
	
	# move left
	lw $t0, headXCoord
	lw $t1, headYCoord
	addiu $t0, $t0, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal coordToAddress
	add $a0, $v0, $zero
	lw $a1, snake
	jal draw
	
	sw  $t0, headXCoord	
	j updateTail

DrawRight:
	# border check
	lw $a0, headXCoord
	lw $a1, headYCoord
	lw $a2, headDirection	
	jal gameOverCheck
	
	# move right
	lw $t0, headXCoord
	lw $t1, headYCoord
	addiu $t0, $t0, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal coordToAddress
	add $a0, $v0, $zero
	lw $a1, snake
	jal draw
	
	sw  $t0, headXCoord
	j updateTail 


# next frame of tail			
updateTail:	
	lw $t2, tailTrailing
	
	# direction check for tail
	beq  $t2, 119, tailUp
	beq  $t2, 115, tailDown
	beq  $t2, 97, tailLeft
	beq  $t2, 100, tailRight

# Tail Up
tailUp:
	
	lw $t8, locationInArray # get coords of the next direction
	la $t0, changeDirectionArray # get base address of the coord-array
	add $t0, $t0, $t8 # go to needed index
	lw $t9, 0($t0)# get the data
	lw $a0, tailXCoord # get current coords
	lw $a1, tailYCoord
	beq $s1, 1, lengthGrowUp # if fruit picked up and length needs increase and don't change coords
	addiu $a1, $a1, -1 # move tail if no fruit picked up
	sw $a1, tailYCoord # store new position
	
lengthGrowUp:
	li $s1, 0 # set boolean for snake eating to false
	jal coordToAddress
	add $a0, $v0, $zero
	bne $t9, $a0, DrawTailUp # change direction if needed
	la $t3, changeNewDirectionArray  # update direction
	add $t3, $t3, $t8
	lw $t9, 0($t3)
	sw $t9, tailTrailing
	addiu $t8,$t8,4

	# if the index is out of bounds loop back to zero
	bne $t8, 396, tempLocationUp
	li $t8, 0

tempLocationUp:
	sw $t8, locationInArray 

DrawTailUp:
	lw $a1, snake
	jal draw

	# delete behdind tail
	lw $t0, tailXCoord
	lw $t1, tailYCoord
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal coordToAddress
	add $a0, $v0, $zero
	lw $a1, blank
	jal draw	
	j DrawFruit  # since snake is updated go to fruit to be updated

# Tail Down (steps are about the same for down, left, and right just different directions)
tailDown:
	
	lw $t8, locationInArray
	la $t0, changeDirectionArray 
	add $t0, $t0, $t8
	lw $t9, 0($t0)
	lw $a0, tailXCoord  
	lw $a1, tailYCoord
	beq $s1, 1, lengthGrowDown 
	addiu $a1, $a1, 1 
	sw $a1, tailYCoord
	
lengthGrowDown:
	li $s1, 0 
	jal coordToAddress
	add $a0, $v0, $zero
	bne $t9, $a0, DrawTailDown 
	la $t3, changeNewDirectionArray  
	add $t3, $t3, $t8
	lw $t9, 0($t3)
	sw $t9, tailTrailing
	addiu $t8,$t8,4

	
	bne $t8, 396, tempLocationDown
	li $t8, 0

tempLocationDown:
	sw $t8, locationInArray  

DrawTailDown:	
	lw $a1, snake
	jal draw	
	
	lw $t0, tailXCoord
	lw $t1, tailYCoord
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal coordToAddress
	add $a0, $v0, $zero
	lw $a1, blank
	jal draw	
	j DrawFruit 

# Tail Left
tailLeft:
	
	lw $t8, locationInArray
	la $t0, changeDirectionArray 
	add $t0, $t0, $t8
	lw $t9, 0($t0)
	lw $a0, tailXCoord 
	lw $a1, tailYCoord
	beq $s1, 1, lengthGrowLeft 
	addiu $a0, $a0, -1 
	sw $a0, tailXCoord
	
lengthGrowLeft:
	li $s1, 0 
	jal coordToAddress
	add $a0, $v0, $zero
	bne $t9, $a0, DrawTailLeft 
	la $t3, changeNewDirectionArray 
	add $t3, $t3, $t8
	lw $t9, 0($t3)
	sw $t9, tailTrailing
	addiu $t8,$t8,4
	
	bne $t8, 396, tempLocationLeft
	li $t8, 0

tempLocationLeft:
	sw $t8, locationInArray  

DrawTailLeft:	
	lw $a1, snake
	jal draw	
	
	lw $t0, tailXCoord
	lw $t1, tailYCoord
	addiu $t0, $t0, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal coordToAddress
	add $a0, $v0, $zero
	lw $a1, blank
	jal draw	
	j DrawFruit  

# Tail Right
tailRight:
	lw $t8, locationInArray
	la $t0, changeDirectionArray
	add $t0, $t0, $t8
	lw $t9, 0($t0)
	lw $a0, tailXCoord
	lw $a1, tailYCoord
	beq $s1, 1, lengthGrowRight
	addiu $a0, $a0, 1
	sw $a0, tailXCoord
	
lengthGrowRight:
	li $s1, 0
	jal coordToAddress
	add $a0, $v0, $zero
	bne $t9, $a0, DrawTailRight
	la $t3, changeNewDirectionArray
	add $t3, $t3, $t8
	lw $t9, 0($t3)
	sw $t9, tailTrailing
	addiu $t8,$t8,4
	bne $t8, 396, tempLocationRight
	li $t8, 0

tempLocationRight:
	sw $t8, locationInArray  

DrawTailRight:	

	lw $a1, snake
	jal draw	

	lw $t0, tailXCoord
	lw $t1, tailYCoord
	addiu $t0, $t0, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal coordToAddress
	add $a0, $v0, $zero
	lw $a1, blank
	jal draw
	j DrawFruit
	
# draw fruit pixel
DrawFruit:
	# check if snake touched fruit
	lw $a0, headXCoord
	lw $a1, headYCoord
	jal checkIfEaten
	beq $v0, 1, AddLength # if fruit was eaten increase snake size

	# draw fruit
	lw $a0, fruitXCoord
	lw $a1, fruitYCoord
	jal coordToAddress
	add $a0, $v0, $zero
	lw $a1, fruit
	jal draw
	j checkInput
	
AddLength:
	li $s1, 1 # boolean to increase snake length set to true
	j CreateFruit

j checkInput # redundancy check

coordToAddress:
	lw $v0, displayX 	# load display width
	mul $v0, $v0, $a1	# multiply by y coords
	add $v0, $v0, $a0	# add x coords
	mul $v0, $v0, 4		# mult by 4 for word
	add $v0, $v0, $gp
	jr $ra			# return address

draw:
	sw $a1, ($a0) 	# paint at address of location
	jr $ra
	
directionChecker:
	beq $a0, $a1, Same  # if input is in current direction, then ignore input
	beq $a0, 119, pressedDown # if moving up, check to see if down is pressed
	beq $a0, 115, pressedUp	# if moving down, check to see if up is pressed
	beq $a0, 97, pressedRight # if moving left, check to see if right is pressed
	beq $a0, 100, pressedLeft # if moving right, check to see if left is pressed
	j checkerDone # if input is invalid get new one
	
pressedUp:
	beq $a1, 119, invalidInput # up is pressed when going down
	j validInput

pressedDown:
	beq $a1, 115, invalidInput # down is pressed when going up
	j validInput

pressedRight:
	beq $a1, 100, invalidInput # right is pressed when going left
	j validInput
	
pressedLeft:
	beq $a1, 97, invalidInput # left is pressed when going right
	
validInput:
	li $v0, 1
	
	beq $a1, 119, storeUp  # store coords of direction change
	beq $a1, 115, storeDown 	
	beq $a1, 97, storeLeft  
	beq $a1, 100, storeRight 
	j checkerDone
	
storeUp:
	lw $t4, arrayIndex # get the current index
	la $t2, changeDirectionArray # get the address of the coords for direction change
	la $t3, changeNewDirectionArray # get address of new direction
	add $t2, $t2, $t4 # go to current array index
	add $t3, $t3, $t4
		
	sw $a2, 0($t2) # save the coords to the array
	li $t5, 119 # up direction
	sw $t5, 0($t3) # save the direction change to the array
	
	addiu $t4, $t4, 4 # continue through array, if getting out of bounds reset to index 0
	bne $t4, 396, tempUpStore # store the up change temperarorly 
	li $t4, 0

tempUpStore:
	sw $t4, arrayIndex	
	j checkerDone
	
storeDown:
	lw $t4, arrayIndex 
	la $t2, changeDirectionArray 
	la $t3, changeNewDirectionArray 
	add $t2, $t2, $t4
	add $t3, $t3, $t4
	
	sw $a2, 0($t2) 
	li $t5, 115
	sw $t5, 0($t3) 

	addiu $t4, $t4, 4 
	bne $t4, 396, tempDownStore
	li $t4, 0

tempDownStore:	
	sw $t4, arrayIndex
	j checkerDone

storeLeft:
	lw $t4, arrayIndex 
	la $t2, changeDirectionArray 
	la $t3, changeNewDirectionArray 
	add $t2, $t2, $t4 
	add $t3, $t3, $t4

	sw $a2, 0($t2) 
	li $t5, 97
	sw $t5, 0($t3) 

	addiu $t4, $t4, 4 
	bne $t4, 396, tempLeftStore
	li $t4, 0

tempLeftStore:
	sw $t4, arrayIndex
	j checkerDone

storeRight:
	lw $t4, arrayIndex 
	la $t2, changeDirectionArray 
	la $t3, changeNewDirectionArray 
	add $t2, $t2, $t4 
	add $t3, $t3, $t4
	
	sw $a2, 0($t2) 
	li $t5, 100
	sw $t5, 0($t3) 

	addiu $t4, $t4, 4 
	bne $t4, 396, tempRightStore
	li $t4, 0

tempRightStore:
	sw $t4, arrayIndex		
	j checkerDone

	
invalidInput:
	li $v0, 0 # direction is not valid
	j checkerDone
	
Same:
	li $v0, 1 # same direction
	
checkerDone:
	jr $ra # return to calling function
	

Wait:
	li $v0, 32 # short wait for input checking
	syscall
	jr $ra
	

checkIfEaten:
	
	lw $t0, fruitXCoord # get fruit coords
	lw $t1, fruitYCoord
	add $v0, $zero, $zero # initialize zero, aka no touching
	beq $a0, $t0, snakeXfruit # compare x-coords with snake
	j exitCheck # if not the same then no touching
	
snakeXfruit:
	beq $a1, $t1, snakeYfruit # compare y-coords with snake
	j exitCheck # if different then no touching

snakeYfruit:
	lw $t5, score # update score since it was eaten
	lw $t6, scoreMultiplier
	add $t5, $t5, $t6
	sw $t5, score
	
	li $v0, 1 # set eaten boolean to true
	
exitCheck:
	jr $ra
	
	
gameOverCheck:
	
	# store coords and adresses
	add $s3, $a0, $zero 
	add $s4, $a1, $zero 
	sw $ra, 0($sp)

	beq  $a2, 119, checkAbove # check if collided going up, down, etc.
	beq  $a2, 115, checkBelow
	beq  $a2, 97,  checkToLeft
	beq  $a2, 100, checkToRight
	j BodyCollisionDone 
	
checkAbove:
	
	addiu $a1, $a1, -1 # check if snake/border is above
	jal coordToAddress
	lw $t1, 0($v0)	# get color of what's above
	lw $t2, snake # get snake color
	lw $t3, border # get border color
	beq $t1, $t2, Exit # If hit snake, then game over
	beq $t1, $t3, Exit # If hit border, then game over as well
	j BodyCollisionDone # if neither then keep going

checkBelow:

	addiu $a1, $a1, 1
	jal coordToAddress
	lw $t1, 0($v0)
	lw $t2, snake
	lw $t3, border
	beq $t1, $t2, Exit 
	beq $t1, $t3, Exit 
	j BodyCollisionDone 

checkToLeft:

	addiu $a0, $a0, -1
	jal coordToAddress
	lw $t1, 0($v0)
	lw $t2, snake
	lw $t3, border
	beq $t1, $t2, Exit 
	beq $t1, $t3, Exit 
	j BodyCollisionDone 

checkToRight:

	addiu $a0, $a0, 1
	jal coordToAddress
	lw $t1, 0($v0)
	lw $t2, snake
	lw $t3, border
	beq $t1, $t2, Exit 
	beq $t1, $t3, Exit 
	j BodyCollisionDone 

BodyCollisionDone:
	lw $ra, 0($sp)
	jr $ra		
	
IncreaseDifficulty:
	lw $t0, score # get current score
	la $t1, Levels # get the milestones
	lw $t2, scoreArrayIndex # get current index
	add $t1, $t1, $t2 # go to that index
	lw $t3, 0($t1) # get the value of that index
	
	
	bne $t3, $t0, difficultyDone # if the player score is not equal to the level then move on, else increase difficulty
	addiu $t2, $t2, 4 # increase the index
	sw $t2, scoreArrayIndex # store new index
	lw $t0, scoreMultiplier # get score multiplier
	sll $t0, $t0, 1 # double score multiplier
	lw $t1, snakeSpeed # get game speed
	addiu $t1, $t1, -30 # speed up game by 30
	sw $t1, snakeSpeed # store speed

difficultyDone:
	jr $ra

Exit:   
	li $v0, 56
	la $a0, gameOverMessage 
	lw $a1, score
	syscall
	
	li $v0, 50 
	la $a0, restartMessage 
	syscall
	
	beqz $a0, main # restart
	
	li $v0, 10 # exit
	syscall
