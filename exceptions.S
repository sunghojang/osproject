.globl coreUndefinedHandler
coreUndefinedHandler:
1:	b 1b

.globl corePrefetchAbortHandler
corePrefetchAbortHandler:
1:	b 1b

.globl coreDataAbortHandler
coreDataAbortHandler:
1:	b 1b

.globl coreReservedHandler
coreReservedHandler:
1:	b 1b

.globl coreFIQHandler
coreFIQHandler:
1:	b 1b

.globl coreSWIHandler
coreSWIHandler:
	stmfd sp!,{r0-r12,lr}
	ldr r10,[lr,#-4]
	bic r10,r10,#0xFF000000
	mov r0,r10
	mrs r1,spsr
	stmfd sp!,{r1}

	bl eventsSWIHandler
	
	ldmfd sp!,{r1}
	msr spsr_cxsf,r1
	ldmfd sp!,{r0-r12,pc}^

.globl coreIRQHandler
coreIRQHandler:
1:	b 1b