//uart.c

typedef struct {

    volatile unsigned long ULCON;
    volatile unsigned long UCON;
    volatile unsigned long UFCON;
    volatile unsigned long UMCON;
    volatile unsigned long UTRSTAT;
    volatile unsigned long UERSTAT;
    volatile unsigned long UFSTAT;
    volatile unsigned long UMSTAT;
    volatile unsigned char UTXH;
    volatile unsigned char res1[3];
    volatile unsigned char URXH;
    volatile unsigned char res2[3];
    volatile unsigned long UBRDIV;
} S5PC11X_UART;

void uart_putc(char ch) {    

    //S5PC11X_UART *const uart = (S5PC11X_UART *)0x13800000;
    S5PC11X_UART *const uart = (S5PC11X_UART *)0xF3800000;

    while (!(uart->UTRSTAT & 0x2));

    uart->UTXH = ch;
}

void uart_puts(const char *s) {

    while (*s) uart_putc(*s++);
}

void uart_puthex(const unsigned int value) {

	char c;
	int i;
	char buf[11];
	
	buf[0]='0';
	buf[1]='x';
	
	for (i=7;i>=0;i--) {
		
		c= (char)((value >> (i*4)) & 0x0f);
		if (c>9) c+=('a' - 10);
		else c+= '0';
		buf[9-i] = c;
	}
	
	buf[10] = '\0';
	uart_puts(buf);
	
}

void uart_puthexnl (const unsigned int value) {

	uart_puthex(value);
	uart_putc('\n');
}
