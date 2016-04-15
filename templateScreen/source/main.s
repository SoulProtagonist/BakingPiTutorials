	.section .init
	.globl _start
_start:
	b main


	.section .text
main:
	mov sp,#0x8000

	/* setup framebuffer */
	mov r0,#1024
	mov r1,#768
	mov r2,#16
	bl InitialiseFrameBuffer

	/* make sure it returns non zero */
	teq r0,#0
	bne noError$

	/* error - turn on OK LED */
	mov r0,#16
	mov r1,#1
	bl SetGpioFunction
	mov r0,#16
	mov r1,#0
	bl SetGpio

error$:
	b error$

noError$:
	fbInfoAddr .req r4
	mov fbInfoAddr,r0

	bl SetGraphicsAddress

	mov r0,#0xff
	bl SetForeColour
	mov r0,#10
	mov r1,#10
	mov r2,#100
	mov r3,#100
	bl DrawLine
	
	rand .req r5
	col .req r6
	lx .req r7
	ly .req r8
	cx .req r9
	cy .req r10
	mask .req r11

	mov mask,#0xff
	add mask,mask,lsl #8

	mov rand,#0
	mov col,#0
	mov lx,#0
	mov ly,#0

render$:	
	mov r0,rand
	bl Random
	mov cx,r0
	bl Random
	mov cy,r0
	mov rand,cy

	mov r0,col
	bl SetForeColour
	add col,#1
	and col,mask

	mov cx, cx, lsr #22
	mov cy, cy, lsr #22

	cmp cy,#0
	blt render$
	cmp cy,#768
	bge render$

	mov r0,lx
	mov r1,ly
	mov r2,cx
	mov r3,cy
	bl DrawLine
	
	mov lx,cx
	mov ly,cy

	b render$

	.unreq fbInfoAddr
	.unreq rand
	.unreq col
	.unreq lx
	.unreq ly
	.unreq cx
	.unreq cy
	.unreq mask
