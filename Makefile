# CuteOS Makefile

CFLAGS := -I./include -march=armv7-a -mcpu=cortex-a9 -c -v

.c.o:
	arm-none-eabi-gcc $< $(CFLAGS)

.S.o:
	arm-none-eabi-gcc $< $(CFLAGS)	

#BOOTLOADER
BOOTOBJ = start.o cuteOS.bin.o

cute-boot:$(BOOTOBJ)
	#arm-none-eabi-ld $(OBJ) -o cute-boot -Ttext 0x00000000 -N -T cute-boot.lds
	arm-none-eabi-ld $(BOOTOBJ) -o cute-boot -N -T cute-boot.lds
	arm-none-eabi-objcopy cute-boot cute-boot.bin -O binary
	arm-none-eabi-nm cute-boot | grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | sort > CuteBoot.map
	arm-none-eabi-objdump -D -a -f -p -s -h cute-boot > cute-boot.das
	
start.o: start.S
	arm-none-eabi-gcc start.S $(CFLAGS) -DOS_RAM_BASE=0x40100000 

#KERNEL

KERNEL_OBJ = head.o main.o mmusetup_2.o uart.o exceptions.o swihandler.o

cuteOS.bin.o : cuteOS
	arm-none-eabi-ld -b binary cuteOS.bin -r -o cuteOS.bin.o

cuteOS : $(KERNEL_OBJ)
	arm-none-eabi-ld $(KERNEL_OBJ) -o cuteOS -Ttext 0x00000000 -N	
	#arm-none-eabi-ld head.o main.o mmusetup_2.o -o cuteOS -Ttext 0x40100000 -N	
	arm-none-eabi-objcopy cuteOS cuteOS.bin -O binary
	arm-none-eabi-nm cuteOS | grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | sort > OsCute.map
	arm-none-eabi-objdump -D -a -f -p -s -h cuteOS > cuteOS.das

dbg:
	#gnome-terminal --hide-menubar -e "qemu-system-arm -M smdkc210 -display none -serial stdio -kernel cute-boot.bin" &
	#gnome-terminal --hide-menubar -e "qemu-system-arm -M smdkc210 -display none -serial stdio -kernel $(TARGET)" &
	gnome-terminal --hide-menubar -e "qemu-system-arm -M smdkc210 -display none -serial stdio -kernel cute-boot.bin -s -S" &
	arm-none-eabi-gdb -x .gdbinit
	#arm-none-eabi-gdb -x tools/debugger/gdbinit

run:
	gnome-terminal --hide-menubar -e "qemu-system-arm -M smdkc210 -display none -serial stdio -kernel cute-boot.bin" &

clean:
	rm -f *.o
	rm -f cute-boot
	rm -f cute-boot.bin
	rm -f cuteOS
	rm -f cuteOS.bin
	rm -f *.das
	rm -f *.map
