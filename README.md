## ASM-Minesweeper
### An assembly minesweeper that is fully functional (i lied)


<img src="https://img.shields.io/github/license/arkanyota/ASM-Minesweeper" alt="license" />

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
>> nasm -felf64 main2.asm && ld main2.o
>> Fichier compilé et prêt à l'utilisation
```

Il suffit juste d'éxécuter ce fichier dans la console de commande :

```
./a.out
```

