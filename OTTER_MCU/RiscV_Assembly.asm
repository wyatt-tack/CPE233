
#-----------------------------------------------------------
#	Author: Wyatt Tack
#
#	Continously reads x and y values for accelerometer, 
#	prints x in degrees to sevseg
#-----------------------------------------------------------

main:	
	li s0, 0x11000000	#mmio adress	
	li sp, 0x10000		#stack pointer
	call accelrSetup
	li a1, 0
	li a2, 0
loop:	
	#call heartbeat for testing
	call readX	#x->a1
	call readY	#y->a2
	mv a0, a1
	call map90	#a3 = x->+/-90
	mv a3, a0
	mv a0, a2
	call map90	#a4 = y->+/-90
	mv a4, a0
	mv a0, a4
	call display	#a4 = y -> a0 -> SSEG
	j loop
#--------HeartBeat-------------------------------------------
heartbeat:
	addi sp, sp, -4 	#push ra to stack
	sw ra, (sp)
	li t1, 0x0400	
	sw t1, 0x20(s0)
	call delay25
	li t1, 0
	sw t1, 0x20(s0)
	call delay25
	lw ra, (sp)		#pop ra from stack
	addi sp, sp, 4 
	ret

#--------Call for displaying a3 into sevenseg-- a0->display -
display:	
	sw a0, 	0x40(s0)
	sw a0, 	0xd0(s0)
	ret
#--------Delay for visibility ------------------ delay 0.25s -
delay25:
	addi sp, sp, -4 	#push t0 to stack
	sw t0, (sp)
	li t0, 3125000		
delay25loop: 	addi t0, t0, -1	#delay 2.2ms
		bnez t0, delay2loop		
	lw t0, (sp)		#pop t0 from stack
	addi sp, sp, 4 
	ret
#--------Delay for loading stuff--------------- delay 2.2ms -
delay2:
	addi sp, sp, -4 	#push t0 to stack
	sw t0, (sp)
	li t0, 27430		
delay2loop: 	addi t0, t0, -1	#delay 2.2ms
		bnez t0, delay2loop		
	lw t0, (sp)		#pop to from stack
	addi sp, sp, 4 
	ret
#--------Filter ------------------ if a0 filtered a0 = 0 -
filter:	
	beqz a0 filtered	#filter a0 = 0
	li t1, 0xff
	beq t1, a0 filtered	#filter a0 = 0xff
	sub t0, a5, a0
	bgez t0 pos	#absolute value of a5-a0
	sub t0, x0, t0
pos:
	li t1, 0x12
	bgt t0, t1, filtered 	#filter a5-a0 > 0x20
	
	j unfiltered
filtered:
	li a0, 0		
unfiltered:	
	ret

#--------Call for reading X-axis------------------- x->a1 -
readX:
	addi sp, sp, -4 	#push t0 to stack
	sw t0, (sp)
	addi sp, sp, -4 	#push ra to stack
	sw ra, (sp)
	addi sp, sp, -4 	#push a0 to stack
	sw a0, (sp)
	li t0, 0x3b		#load x axis read adress into I2C
	sw t0, 0x90(s0)
	call delay2		#delay 2.2 ms for I2C to load
	lb a0, 0xc0(s0)		#load x data into t0
	
	mv a5, a1	#oldX into a5 for comp
	call filter
	beqz a0 filterX	#if not filtered, return into a1, else no change
	mv a1, a0
	filterX:
	
	lw a0, (sp)		#pop a0 from stack
	addi sp, sp, 4		
	lw ra, (sp)		#pop ra from stack
	addi sp, sp, 4 
	lw t0, (sp)		#pop t0 from stack
	addi sp, sp, 4 
	ret
#--------Call for reading Y-axis------------------  y->a2  -
readY:
	addi sp, sp, -4 	#push t0 to stack
	sw t0, (sp)
	addi sp, sp, -4 	#push ra to stack
	sw ra, (sp)
	addi sp, sp, -4 	#push a0 to stack
	sw a0, (sp)
	li t0, 0x3d		#load y axis read adress into I2C
	sw t0, 0x90(s0)
	call delay2		#delay 2.2 ms for I2C to load
	lb a0, 0xc0(s0)		#load y data into t0
	
	mv a5, a2	#oldY into a5 for comp
	call filter
	beqz a0 filterY	#if not filtered, return into a2, else no change
	mv a2, a0
filterY:
	
	lw a0, (sp)		#pop a0 from stack
	addi sp, sp, 4		
	lw ra, (sp)		#pop ra from stack
	addi sp, sp, 4 
	lw t0, (sp)		#pop t0 from stack
	addi sp, sp, 4 
	ret
#-------Setup call for accelerometer------------------------
accelrSetup:
	addi sp, sp, -4 	#push t0 to stack
	sw t0, (sp)
	li t0, 0x68 		#I2C adress for accelerometer
	sw t0, 0x80(s0)	
	li t0, 0x6b		#write register adress for power control
	sw t0, 0xa0(s0)	
	li t0, 0x00 		#write data for power setup
	sw t0, 0xb0(s0)	
	lw t0, (sp)		#pop to from stack
	addi sp, sp, 4 
	ret
#------Map to 90 degrees----- 0x8001<a0<0x7fff -> 90<a0<90 -
map90:
	addi sp, sp, -4 	#push ra to stack
	sw ra, (sp)
	addi sp, sp, -4 	#push a1 to stack
	sw a1, (sp)
	addi sp, sp, -4 	#push a2 to stack
	sw a2, (sp)
	
	bgez a0 positive	#absolute value of a0
	sub a0, x0, a0
	
positive:	
	mv a1, a0		# a0 = a0 * 90/0x7fff
	li a2, 90
	call multiply	#a0 = a1 x a2
	mv a1, a0
	li a2, 0x7f	
	call divide	#a0 = a1/a2
	lw a2, (sp)		#pop a2 from stack
	addi sp, sp, 4 
	lw a1, (sp)		#pop a1 from stack
	addi sp, sp, 4 	
	lw ra, (sp)		#pop ra from stack
	addi sp, sp, 4 
	ret	
#----- Multiply temp function -------------- a0 = a1 x a2 -	
multiply:
	li t0, 0
	mv t1, a1
	mv t2, a2
multloop:	
	add t0, t0, t1
	addi t2, t2, -1
	bgtz t2 multloop
	mv a0, t0	
	ret	
#----- Divide temp function ---------------- a0 = a1/a2 -	
divide:				 	  #- a3 = a1%a2 -
	li t0, 0
	mv t1, a1
	mv t2, a2
divloop1:	
	addi t0, t0, 1
	sub t1, t1, t2
	bgtz t1 divloop1	
		
	beqz t1  noqtnt1
	addi t0, t0, -1
	add a3, t1, t2
noqtnt1:
	mv a0, t0
	ret


	
	
	
	


