/* GetTimerAddress */
	.globl GetTimerAddress
GetTimerAddress:
	ldr r0,=0x20003000
	mov pc,lr

	/* GetTimeStamp */
	.globl GetTimeStamp
GetTimeStamp:
	push {lr}
	bl GetTimerAddress
	ldrd r0,r1,[r0,#4]
	pop {pc}
	
/* TimerWait */
	.globl TimerWait
TimerWait:
	cmp r0, #1
	movlt pc,lr // check the wait time is 1 or more.

	waitTime .req r2
	mov waitTime,r0
	
	push {lr}
	
	startTime .req r3
	bl GetTimeStamp
	mov startTime, r0
	
timerloop$:
	currentTime .req r0
	bl GetTimeStamp
	sub r1, currentTime, startTime
	cmp r1, waitTime
	bls timerloop$

	.unreq waitTime
	.unreq currentTime
	.unreq startTime
	
	pop {pc}
