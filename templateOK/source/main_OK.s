	.section .init
	.globl _start
_start:
	b main


	.section .text
main:
	mov sp,#0x8000
	
	pinNum .req r0
	pinFunc .req r1
	mov pinNum,#16
	mov pinFunc, #1
	bl SetGpioFunction
	.unreq pinFunc
	.unreq pinNum

	ptrn .req r4
	ldr ptrn,=pattern
	ldr ptrn,[ptrn]
	seq .req r5
	mov seq,#0
	
mainloop$:
	pinNum .req r0
	pinVal .req r1
	mov pinNum, #16
	mov pinVal, #1
	lsl pinVal, seq
	and pinVal, ptrn
	bl SetGpio
	.unreq pinVal
	.unreq pinNum
	
	mov r0,#1
	lsl r0,#18
	bl TimerWait

	add seq, seq, #1
	and seq, #0b11111
	
	b mainloop$
	
	.section .data
	.align 2
pattern:
	.int 0b11111111101010100010001000101010
	
