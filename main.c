#include <s5pv310.h>

// uart include
void uart_putc(char ch);
void uart_puts(const char *s);
void uart_puthex(const unsigned int value);
void uart_puthexnl (const unsigned int value);

void eventsSWIHandler(unsigned int syscallnum);

#define get_pc() \
({ unsigned int pc; \
   __asm__ __volatile__("mov %0, pc" :"=r"(pc):); pc;})

#define get_sp() \
({ unsigned int sp; \
	__asm__ __volatile__("mov %0, sp" :"=r"(sp):); sp;})

#define syscall() __asm__ ("swi 1")

//static int TestArray[100];
//static int TestArray2[2] = {1,2};
//unsigned char MainStackAddr = 0x40200000;
//unsigned char MainStack[1024*8];
//unsigned char ExceptStack[1024*8];

void kmain(void) {

	unsigned int sp;
	unsigned int pc;
	unsigned int loopCnt = 0;
	
	// uart_putc('O');
	// uart_putc('S');
	// uart_putc('P');
	// uart_putc('R');
	// uart_putc('O');
	// uart_putc('J');
	// uart_putc('E');
	// uart_putc('C');
	// uart_putc('T');
	// uart_putc(' ');
	// uart_putc('T');
	// uart_putc('E');
	// uart_putc('S');
	// uart_putc('T');
	// uart_putc('!');
	// uart_putc('\n');

	uart_puts("IAMROOT OS PROJECT 2016!!\n");
	uart_puts("S5PC210 MMU Enable Verison!!\n");

	pc = get_pc();
	sp = get_sp();

	uart_puts("kmain :");	
	uart_puthexnl((unsigned int)kmain);

	uart_puts("SP :");
	uart_puthexnl(sp);

	uart_puts("PC :");
	uart_puthexnl(pc);

	while(loopCnt < 16)
	{
		int i;
		syscall();
		for(i=0;i<0x100000;i++); //Delay
		loopCnt++;		
	}

	while(1);
}
