ASM = nasm
EMU = qemu-system-x86_64

ASMFLAGS = -f bin
BOOT_BIN = boot.bin

run:
	$(ASM) $(ASMFLAGS) -o $(BOOT_BIN) boot.asm
	$(EMU) -drive format=raw,file=$(BOOT_BIN)
.PHONY: run
