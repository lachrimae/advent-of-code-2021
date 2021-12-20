build:
	nasm -g -f elf64 -o main.o main.asm
	ld -o main main.o -I/nix/store/z56jcx3j1gfyk4sv7g8iaan0ssbdkhz1-glibc-2.33-56/lib/libc-2.33.so

run: build
	./main input.txt > out.txt
