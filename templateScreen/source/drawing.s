	.section .data
	.align 1
foreColour:
	.hword 0xFFFF

	.align 2
graphicsAddress:
	.int 0

	.section .text
	.globl SetForeColour
SetForeColour:
	cmp r0,#0x10000
	movhs pc,lr
	ldr r1,=foreColour
	strh r0,[r1]
	mov pc,lr

	.globl SetGraphicsAddress
SetGraphicsAddress:
	ldr r1,=graphicsAddress
	str r0,[r1]
	mov pc,lr

	.globl DrawPixel
DrawPixel:
	px .req r0
	py .req r1
	addr .req r2
	ldr addr,=graphicsAddress
	ldr addr,[addr]

	height .req r3
	ldr height,[addr,#4]
	sub height,#1
	cmp py,height
	movhi pc,lr
	.unreq height

	width .req r3
	ldr width,[addr,#0]
	sub width,#1
	cmp px,width
	movhi pc,lr

	ldr addr,[addr,#32]
	add width,#1
	mla px,py,width,px
	.unreq width
	.unreq py
	add addr,px,lsl #1
	.unreq px

	fore .req r3
	ldr fore,=foreColour
	ldrh fore,[fore]

	strh fore,[addr]
	.unreq fore
	.unreq addr
	mov pc,lr

	.globl DrawLine
DrawLine:
	push {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
	x0 .req r4
	y0 .req r5
	x1 .req r6
	y1 .req r7

	dx .req r8
	sx .req r9
	dyn .req r10
	sy .req r11
	err .req r12

	mov x0,r0
	mov y0,r1
	mov x1,r2
	mov y1,r3

	cmp x1,x0
	subgt dx,x1,x0
	movgt sx,#1
	suble dx,x0,x1
	movle sx,#-1

	cmp y1,y0
	subgt dyn,y0,y1
	movgt sy,#1
	suble dyn,y1,y0
	movle sy,#-1

	add err,dx,dyn

lineloop$:
	mov r0,x0
	mov r1,y0
	bl DrawPixel

	cmp dyn,err,lsl #1
	addle x0,sx
	addle err,dyn

	cmp dx,err,lsl #1
	addge y0,sy
	addge err,dx

	teq x0,x1
	teqne y0,y1
	bne lineloop$

	.unreq x0
	.unreq x1
	.unreq y0
	.unreq y1
	.unreq dx
	.unreq dyn
	.unreq sx
	.unreq sy
	.unreq err
	
	pop {r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}
