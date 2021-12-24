build:
	nasm -g -f elf64 -o main.o main.asm
	ld -o main main.o

run: build
	echo "$$(($$((2#$$(./main input.txt g))) * $$((2#$$(./main input.txt e)))))"

debug: build
	gdb main
