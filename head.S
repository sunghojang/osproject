.equ IRQ32MOD, 0x12
.equ SVC32MOD, 0x13
.equ SYS32MOD, 0x1f
.equ NOINT, 0xc0

.globl _start  
_start:

_exception_vector_table_begin:
	b coreInitialize
	ldr pc,vectorUndefined
	ldr pc,vectorSWI
	ldr pc,vectorPrefetchAbort
	ldr pc,vectorDataAbort
	ldr pc,vectorReserved
	ldr pc,vectorIRQ
	ldr pc,vectorFIQ

_exception_vector_table_end:

vectorUndefined:
	.word coreUndefinedHandler

vectorSWI:
	.word coreSWIHandler

vectorPrefetchAbort:
	.word corePrefetchAbortHandler

vectorDataAbort:
	.word coreDataAbortHandler

vectorReserved:
	.word coreReservedHandler

vectorIRQ:
	.word coreIRQHandler					

vectorFIQ:
	.word coreFIQHandler	

coreInitialize:
	bl mmusetup

stack_setup:	
	msr cpsr_c,#NOINT | SVC32MOD

	@mov r0,=STACK
	@ldr r0,_STACK_ADDR_BASE
	@mov r1,#8192
	@add sp,r0,r1

	@ SVCStack L2PT1 Mem End 
	mov r0,#0x100000	
	sub sp,r0,#4	
	
	msr cpsr_c,#NOINT | IRQ32MOD
	sub sp,r0,#0x1000

	@ VADDR
	@ 0x0      ~ 0xFFFFF  Kernel
	@ 0x100000 ~ 0x1FFFFF Task1
	@ 0x200000 ~ 0x2FFFFF Task2
	@ 0x300000 ~ 0x3FFFFF ......

	msr cpsr_c,#NOINT | SYS32MOD   
	ldr sp,=0x408000

	msr cpsr_c,#NOINT | SVC32MOD
	
	ldr pc,=kmain

@_STACK_ADDR_BASE:
	@.word STACK_ADDR_BASE
