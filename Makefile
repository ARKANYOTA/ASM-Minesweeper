all: clean asm-minesweeper

clean:
	@rm -rf *.out *.o main.i main.s peda-session-a.out.txt asm-minesweeper
	@echo "Nettoyage des anciens fichiers"

asm-minesweeper:
	nasm -felf64 asm-minesweeper.asm && ld asm-minesweeper.o -o asm-minesweeper
	@echo "Fichier compilé et prêt à l'utilisation"

install: all
	sudo install -m 755 asm-minesweeper /usr/bin

execute:
	./asm-minesweeper

