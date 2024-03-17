# Author: Ethan Vosburg 
# Date: 3/15/2024 
# Description: This program will process the input from the  

.data

SPEED:		.word 0x186A0, 0x15F90, 0x11170, 0xEA60, 0xC350, 0x9c40, 0x7530, 0x4E20, 0x2710

.text
	lui 	s0, 0x11000			# Load the address of the switches into s0
	li 		s1, 0x0				# Intr curent value reg
	la		t0, ISR
	csrrw	x0, mtvec, t0 		# Load ISR address
	li		t0, 8
	csrrw 	x0, mstatus, t0		# Allow interrupts

MAIN:
	# Check speed of input
	lw 		t6, 0x120(s0)		# load the value from external source in to t6 

    # Output the speed to the SSEG 
    sw      t6, 0x40(s0)        # Output the speed to the SSEG
    sw      t6, 0x0(SPEED)      # Output the speed to the Stepper Motor
    # Check if the stop button is pressed
    bnez   t6, STOP             # If the stop button is pressed, go to the stop function

    # Loop back
	j 		MAIN


# Emergency Stop
ISR:
    li      s1, 0x1             # Set the stop value to 1

STOP:
    j       STOP