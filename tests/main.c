#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>



/* --- PRINTF_BYTE_TO_BINARY macro's --- */  //https://stackoverflow.com/a/25108449/14943431
#define PRINTF_BINARY_PATTERN_INT8 "%c %c %c %c %c %c %c %c"
#define PRINTF_BYTE_TO_BINARY_INT8(i)    \
    (((i) & 0x80ll) ? '1' : '0'), \
    (((i) & 0x40ll) ? '1' : '0'), \
    (((i) & 0x20ll) ? '1' : '0'), \
    (((i) & 0x10ll) ? '1' : '0'), \
    (((i) & 0x08ll) ? '1' : '0'), \
    (((i) & 0x04ll) ? '1' : '0'), \
    (((i) & 0x02ll) ? '1' : '0'), \
    (((i) & 0x01ll) ? '1' : '0')

#define PRINTF_BINARY_PATTERN_INT16 \
    PRINTF_BINARY_PATTERN_INT8       "\n"        PRINTF_BINARY_PATTERN_INT8
#define PRINTF_BYTE_TO_BINARY_INT16(i) \
    PRINTF_BYTE_TO_BINARY_INT8((i) >> 8),   PRINTF_BYTE_TO_BINARY_INT8(i)
#define PRINTF_BINARY_PATTERN_INT32 \
    PRINTF_BINARY_PATTERN_INT16        "\n"      PRINTF_BINARY_PATTERN_INT16
#define PRINTF_BYTE_TO_BINARY_INT32(i) \
    PRINTF_BYTE_TO_BINARY_INT16((i) >> 16), PRINTF_BYTE_TO_BINARY_INT16(i)
#define PRINTF_BINARY_PATTERN_INT64    \
    PRINTF_BINARY_PATTERN_INT32      "\n"       PRINTF_BINARY_PATTERN_INT32
#define PRINTF_BYTE_TO_BINARY_INT64(i) \
    PRINTF_BYTE_TO_BINARY_INT32((i) >> 32), PRINTF_BYTE_TO_BINARY_INT32(i)
/* --- end macros --- */


// Maps Vars
unsigned long long int bombs = 0; // Warn: La position 0 se trouve en bas a droite (Sur la representation graphique)
unsigned long long int flags = 0;
unsigned long long int disco = 0;
// Temp Vars
unsigned long long int vars  = 0;
// +-VARS----------------------------------------------------------------------------------------------------------------------------+ 
// + 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 + 
// +---------------------------------------------------------------------------------------------------------------------------------+ 
//                                                                                           ^-x-^ ^-y-^ ^-nb_bomb-^ ^---tmp---^ | ^--- is lose
//                                                                                                                               ^----- is win
//                                                                                                                                     
//                                                                                                                                     
//                                                                                                                                     
//                                         |========================================|                                                  
//                                         | Schema du stockage de la variable vars |                                                  
//                                         |========================================|                                                  

// get is lose => return ( vars       ) & 0b1
// get is win  => return ( vars >> 1  ) & 0b1
// get tmp     => return ( vars >> 2  ) & 0b111111 
// get nb_bomb => return ( vars >> 8  ) & 0b111111
// get x       => return ( vars >> 14 ) & 0b111
// get y       => return ( vars >> 16 ) & 0b111


// MArche pas::::::
// set is lose => vars = ( vars       ) & 0b1
// set is win  => vars = ( vars >> 1  ) & 0b1
// set tmp     => vars = ( vars >> 2  ) & 0b111111 
// set nb_bomb => vars = ( vars >> 8  ) & 0b111111
// set x       => vars = ( vars >> 14 ) & 0b111
// set y       => vars = ( vars >> 16 ) & 0b111


// Le Nombre de bombes je sais pas si on met 32 comme ça c'est sur on peut pas faire une boucle infinie dans le generate bombe, ou 64 le nombre de case

int pos = 0;  // Position de quand on clique
int tmp = 0;  // used for pos, 
              //
int x = 0;
int y = 0;

// On peut juste avoir pos au lieu de x et y:
// Pour accéder au y - 1, on fait pos - 8
// Pour accéder au y + 1, on fait pos + 8
// Pour accéder au x - 1, on fait pos - 1  // Meme si ça peut revenir a la ligne précédante si c'est en position modulo 8
// Pour accéder au x + 1, on fait pos + 1
// Pour vérifier si pos est dans la grille, 0 <= pos <= 0b111111  (63) ou
//                                          0 <= pos <  0b1000000 (64)


// Get bit => return (((Maps Vars) >> pos) & 1)
//
// Reset bit => Maps_Vars = Maps_Vars & ~(1 ull << pos)
//
// Set bit:
//  - Si le bit est inconnu:
//      Reset bit
//  - Puis 
//      => Maps_Vars = Maps_Vars | (new_bit ull << pos)
//      
// x & y to pos => return (y*8+x)

void reset_map(){
    bombs = 0;
    flags = 0;
    disco = 0;
    return;
}

void generate_bombs(){
    return;
}

int main(){
    // Définir un nombre random qui change a chaque lancement
    time_t t;
    srand((unsigned) time(&t));
    // A Commenter si tu veux faire plein de tests avec les mêmes valeurs

    // GENERATE BOMBS
    pos = 28;  // Get input(Pas Obligatoire On peu garder le pos)
    int nb_bombs = 16;  // TODO Le get par ull(vars) 
    while(nb_bombs > 0){
        tmp = rand() % 0b1000000; // 64 (Le nombre de case)
        if((!((bombs >> tmp) & 1)) && tmp != pos){  // Si on clique on peut être entourée de bombe, mais bon pas grave.
            // Get bit: Ce n'est pas une bombe 

            // On sait que le bit est null donc pas besoin de le reset
            // Faut que le 1 soit un unsigned long long sinon sa marche pas, Il est possible que le problème arrive en assembleur
            // https://stackoverflow.com/questions/7401888/why-doesnt-left-bit-shift-for-32-bit-integers-work-as-expected-when-used
            bombs |= (1ull << tmp);
            nb_bombs--;
        }
    }
    // END GENERATE BOMBS
    
    while(1){
        printf("Bombs   \n" PRINTF_BINARY_PATTERN_INT64 "\n", PRINTF_BYTE_TO_BINARY_INT64(bombs));
        printf("Flags   \n" PRINTF_BINARY_PATTERN_INT64 "\n", PRINTF_BYTE_TO_BINARY_INT64(flags));
        printf("Disco   \n" PRINTF_BINARY_PATTERN_INT64 "\n", PRINTF_BYTE_TO_BINARY_INT64(disco));


        printf("Position x: ");
        scanf("%d", &x);
        printf("Position y: ");
        scanf("%d", &y);

        if((bombs >> y*8+x) & 1){
            printf("Perdu Dommage\n");
            exit(0);
        }else{
            disco |= (1ull << y*8+x);
        }
    //      - Cliquer sur la case
    //      - Vérifier si c'est win ou lose
    //
    }

    return 0;
}
