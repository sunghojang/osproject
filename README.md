cute_os : 2016 OsProject 2nd project  
  
Chapter 7-3 . Task0, Task1 Shared Region  

Memory Map  

PADDR  

0x40010000              First Load Addr (Load cute-boot.bin)  
0x40100000              CuteOS Load Addr (Load CuteOS)  

VADDR  

0x0        ~ 0xFFFFF    CuteOS Kernel (When Kmain Start)  
0x100000   ~ 0x1FFFFF   MMU Page Table  
0x200000   ~ 0x2FFFFF   Task1  
0x300000   ~ 0x3FFFFF   Task2  
0x400000   ~ 0x3FFFFF   Task Run Region  
0x40100000 ~ 0x401FFFFF CuteOS Kernel Region(for When PA -> VA)  
0xF0000000 ~ 0xFFFFFFFF SFR Region  

StackPoint(VADDR)  

SVC SP : 0x100000 - 0x4  
IRQ SP : 0x100000 - 0x1000  
SYS SP : 0x408000  
