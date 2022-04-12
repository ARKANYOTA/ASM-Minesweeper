## ASM-Minesweeper
### An assembly minesweeper that is fully functional (i lied)


<img src="https://img.shields.io/github/license/arkanyota/ASM-Minesweeper" alt="license" />   <img src="https://img.shields.io/github/languages/count/arkanyota/asm-minesweeper" alt="lang-count" />   <img src="https://img.shields.io/github/languages/top/arkanyota/asm-minesweeper" alt="lang-top" />   <img src="https://img.shields.io/github/languages/code-size/arkanyota/asm-minesweeper" alt="size-code" />   <img src="https://img.shields.io/github/downloads/arkanyota/asm-minesweeper/total" alt="download" />
<img src="https://img.shields.io/github/issues/arkanyota/asm-minesweeper" alt="issues" />   <img src="https://img.shields.io/github/last-commit/arkanyota/asm-minesweeper" alt="last-commit" />

<!--https://shields.io/category/issue-tracking-->

### Prérequis :

- Ordinateur sous architecture x86
- Linux (version assez récente) sous architecture x86
- nasm (apt install nasm) | version 2.15.*
- git (apt install git)


### Processus d'installation :

Placez-vous dans un dossier vide et copiez le repo :

```
git clone https://github.com/ARKANYOTA/ASM-Minesweeper.git
```

Effectuez ensuite la commande suivante en ayant bien vérifié avoir les prérequis nécessaires pour faire tourner le programme :
```
make
```

On obtient normalement cette sortie et un fichier a.out apparait :

```
>> Nettoyage des anciens fichiers
>> nasm -felf64 asm-minesweeper.asm && ld asm-minesweeper.o -o asm-minesweeper
>> Fichier compilé et prêt à l'utilisation
```

Il suffit juste d'éxécuter ce fichier dans la console de commande :

```
make execute  # ou ./asm-minesweeper
```

