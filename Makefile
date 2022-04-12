all: clean asm-minesweeper

clean:
	@rm -rf *.out *.o main.i main.s peda-session-a.out.txt asm-minesweeper
	@echo "\033[1m\033[94mNettoyage des anciens fichiers\033[0m"

asm-minesweeper:
	@nasm -felf64 asm-minesweeper.asm && ld asm-minesweeper.o -o asm-minesweeper
	@echo "\033[1m\033[92mCompilation\033[0m"
	@echo "\033[1m\033[92mFichier compilé et prêt à l'utilisation\033[0m"

install: all
	sudo install -m 755 asm-minesweeper /usr/bin

execute:
	./asm-minesweeper

