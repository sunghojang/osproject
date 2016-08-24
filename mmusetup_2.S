#define L1_COARSE_PAGE    0x1
#define L1_SECTION_PAGE   0x2
#define L1_FINE_PAGE      0x3
#define L1_CACHE_ENABLE   (0x2 << 2)
#define L1_BUFFER_ENABLE  (0x1 << 2)
#define L1_SBZ_4BIT       (0x1 << 4)
#define L1_DOMAIN(A)      (A << 5)
#define L1_AP(A)          (A << 10)

#define L2_LARGE_PAGE 	     0x1
#define L2_SMALL_PAGE 	     0x2
#define L2_TINY_PAGE  	     0x3
#define L2_CACHE_ENABLE      (0x2 << 2)
#define L2_BUFFER_ENABLE     (0x1 << 2)
#define L2_AP(A) 	         (A << 4)
#define L2_PAGE_BASE_ADDR(A) A

#define L1PT  0x40000000
#define L2PT1 0x40004000
#define L2PT2 0x40004400
#define L2PT3 0x40004800
#define L2PT4 0x40004C00

#define SFRSTARTADDR 0x10000000
#define STARTADDR 0x0

@ Client Accesses are checked
#define DOM_CLIENT 0x1    
@ Manager Accesses are not checked
#define DOM_MANAGER 0x3   
#define DOMVAL(a,b) (a << (b*2))

@ 0x3010055A
#define KERNELBASE (L2_PAGE_BASE_ADDR(0x40100000) | L2_AP(0x1) | L2_CACHE_ENABLE | L2_SMALL_PAGE)
#define KERNELL2PT (L2PT1 | L1_DOMAIN(0x3) | L1_SBZ_4BIT | L1_COARSE_PAGE)
#define SFRSECBASE (SFRSTARTADDR | L1_AP(0x1) | L1_DOMAIN(0x3) | L1_SBZ_4BIT | L1_CACHE_ENABLE | L1_SECTION_PAGE)
#define MMU1_1SECBASE (STARTADDR | L1_AP(0x1) | L1_DOMAIN(0x3) | L1_SBZ_4BIT | L1_CACHE_ENABLE | L1_SECTION_PAGE)
#define MMU1_TEMP1SECBASE (0x40100000 | L1_AP(0x1) | L1_DOMAIN(0x3) | L1_SBZ_4BIT | L1_CACHE_ENABLE | L1_SECTION_PAGE)
#define PTSECBASE  (L1PT | L1_AP(0x1) | L1_DOMAIN(0x3) | L1_SBZ_4BIT | L1_CACHE_ENABLE | L1_SECTION_PAGE)

#define DOMAINVAL DOMVAL(DOM_MANAGER,0x3)
@#define DOMAINVAL  0x000000C0

@@ SP5C210 MEM MAP @@ 

@ 0x40100000 OS START ADDR

@ 0x40010000 FIRST LOAD ADDR 

@ 0x40004C00 L2PT4
@ 0x40004800 L2PT3
@ 0x40004400 L2PT2
@ 0x40004000 L2PT1
@ 0x40000000 L1
@ 0x10000000 ~ 0x14000000 SFR Region 

.globl mmusetup

mmusetup:

mmu_init_pt:

	ldr r0,=L1PT
	add r1,r0,#0x5000
	mov r2,#0x0

1:
	str r2,[r0],#4
	cmp r0,r1
	blt 1b

mmu_map_kernel:

	ldr r0,=L2PT1
	add r1,r0,#0x400
	ldr r2,=KERNELBASE

1:
	str r2,[r0],#4
	cmp r0,r1
	addlt r2,r2,#0x1000
	blt 1b

	ldr r0,=L1PT
	ldr r2,=KERNELL2PT 
	str r2,[r0]            @ VA 0x00000000 <- CuteOS

	@add r0,r0,#0xc00
	@add r0,r0,#4

	add r0,r0,#0x1000
	add r0,r0,#4

	str r2,[r0]            @ VA 0x40100000 <- CuteOS

mmu_map_l1page: 
	ldr r0,=L1PT	
	ldr r1,=L2PT1
	ldr r2,=MMU1_1SECBASE
1:	
	str r2,[r0],#4
	cmp r0,r1
	addlt r2,r2,#0x100000  @ += 1MB SECTION
	blt 1b

mmu_map_l1_temp:	
	ldr r0,=L1PT
	ldr r2,=MMU1_TEMP1SECBASE
	str r2,[r0]

	add r0,r0,#0x1000
	add r0,r0,#4	
	str r2,[r0]

@ SFR ADDR MAPPING
@ PA 0x10000000 ~ 0x14000000 ---> VA 0xF0000000 ~ 0xFFFFFFFF

mmu_map_sfr: 
	ldr r1,=L2PT1
	sub r0,r1,#0x400   @ 0x4000000 / 0x100000 => 0x40 , 64M, x 4 => 0x100
	ldr r2,=SFRSECBASE
1:	
	str r2,[r0],#4
	cmp r0,r1
	addlt r2,r2,#0x100000  @ += 1MB SECTION
	blt 1b	

ttbmap:
	ldr r0,=L1PT
	mcr p15,0,r0,c2,c0,0			

domainset:
	ldr r0,=DOMAINVAL
	mcr p15,0,r0,c3,c0,0

controlset:
	mov r0,#0
	mcr p15,0,r0,c7,c7,0 @ Flush v3/v4 Cache
	mcr p15,0,r0,c8,c7,0 @ Flush v4 TLB

	mrc p15,0,r0,c1,c0,0
	bic r0,r0,#0x00002300 @clear bits 13,9:8 (--V- --RS)
	bic r0,r0,#0x00000087 @clear bits 7,2:0 (B--- -CAM)
	orr r0,r0,#0x00000002 @set bit 2(A)  Align
	orr r0,r0,#0x00001000 @set bit 12(I) I-Cache
	orr r0,r0,#0x00000004 @set bit 2(C)  D-Cache
	orr r0,r0,#0x00000001 @set bit 2(M)	 MMU Enable
	mcr p15,0,r0,c1,c0,0

	mov pc,lr