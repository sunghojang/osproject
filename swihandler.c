//SWI Handler

void eventsSWIHandler(unsigned int syscallnum)
{
	static unsigned int cnt = 0;

	uart_puts("SWI Handler:");
	uart_puts("syscall number =");
	uart_puthex(syscallnum);
	uart_puts(", cnt =");
	uart_puthexnl(cnt++);
}