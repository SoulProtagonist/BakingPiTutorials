	/** GetMailboxBase **/
	.globl GetMailboxBase
GetMailboxBase:
	ldr r0,=0x2000B880
	mov pc,lr

	/** MailboxWrite **/
	.globl MailboxWrite
MailboxWrite:
	// verify vals passed in make sense
	tst r0,#0b1111
	movne pc,lr
	cmp r1,#15
	movhi pc,lr

	// setup registers and get mb base addr
	channel .req r1
	value .req r2
	mov value,r0
	push {lr}
	bl GetMailboxBase
	mailbox .req r0

	// wait for status to be 0
wait1$:
	status .req r3
	ldr status,[mailbox,#0x18]
	tst status,#0x80000000
	.unreq status
	bne wait1$

	// combine channel and value
	add value,channel
	.unreq channel

	// store value to write field
	str value,[mailbox,#0x20]
	.unreq value
	.unreq mailbox
	pop {pc}

	/** MailboxRead **/
	.globl MailboxRead
MailboxRead:
	// validate inputs
	cmp r0,#15
	movhi pc,lr

	// set channel and get mailbox addr
	channel .req r1
	mov channel,r0
	push {lr}
	bl GetMailboxBase
	mailbox .req r0

	// check status
rightmail$:
wait2$:
	status .req r2
	ldr status,[mailbox,#0x18]
	tst status,#0x40000000     // check 30th bit = 0
	.unreq status
	bne wait2$

	// read mailbox item
	mail .req r2
	ldr mail,[mailbox,#0]

	// check the channel is correct
	inchan .req r3
	and inchan,mail,#0b1111
	teq inchan,channel
	.unreq inchan
	bne rightmail$
	.unreq mailbox
	.unreq channel

	// move answer to r0
	and r0,mail,#0xfffffff0
	.unreq mail
	pop {pc}
	
