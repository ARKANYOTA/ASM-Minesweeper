all: clean asm-compile2


asm-compile:
	nasm -felf64 main.asm && ld main.o
asm-compile2:
	nasm -felf64 main2.asm && ld main2.o

asm-test:
	nasm -felf64 test.asm && ld test.o

asm-debug: clean asm-compile
	gdb a.out

clean:
	rm -rf *.out *.o main.i main.s peda-session-a.out.txt

c-compile:
	gcc main.c -o main.o

c-source:
	gcc -save-temps -c -o main.o main.c

execute:
	./a.out

