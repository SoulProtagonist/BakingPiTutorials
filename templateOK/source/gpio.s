/* GetGpioAddress */
	.globl GetGpioAddress
GetGpioAddress:
	ldr r0,=0x20200000
	mov pc,lr

/* SetGpioFunction*/
	.globl SetGpioFunction
SetGpioFunction:
	cmp r0,#53
	cmpls r1,#7
	movhi pc,lr
	
	push {lr}
	mov r2,r0
	bl GetGpioAddress

functionLoop$:
	cmp r2,#9
	subhi r2,#10
	addhi r0,#4
	bhi functionLoop$

	add r2, r2, lsl #1 /* mult r2 times 3 */
	lsl r1,r2          /* move to correct pin position */

	mov r3, #7	   /* set to 111 */
	lsl r3, r2	   /* move to pin position */

	mvn r3, r3	   /* invert to create mask for other bits */
	ldr r2, [r0]       /* load existing pin states */
	and r2, r3         /* existing code with our pin all 0 */

	orr r1, r2	   /* set on our pins and keep state of others */

	str r1,[r0]        
	pop {pc}

/* SetGpio */
	.globl SetGpio
SetGpio:
	pinNum .req r0
	pinVal .req r1

	cmp pinNum, #53
	movhi pc,lr
	push {lr}
	mov r2, pinNum
	.unreq pinNum
	pinNum .req r2
	bl GetGpioAddress
	gpioAddr .req r0

	pinBank .req r3
	lsr pinBank,pinNum,#5
	lsl pinBank,#2
	add gpioAddr,pinBank
	.unreq pinBank

	and pinNum,#31
	setBit .req r3
	mov setBit,#1
	lsl setBit,pinNum
	.unreq pinNum

	teq pinVal,#0
	.unreq pinVal
	streq setBit,[gpioAddr,#40]
	strne setBit,[gpioAddr,#28]
	.unreq setBit
	.unreq gpioAddr
	pop {pc}
