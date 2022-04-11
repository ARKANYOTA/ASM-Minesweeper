section .data          ; Data segment
	posMsg            db 'Position x et y sans separation: '
	lenposxMsg           equ $-posMsg

	youWinMessage     db 10,' You Win, Bravo!'
	lenyouWinMessage     equ $-youWinMessage
	youLoseMessage    db 10,' You Lose, Ressaye!'
	lenyouLoseMessage    equ $-youLoseMessage

	nb_bombs          DQ 10

	bombs             DQ 0x0 ;0xa09440c820930000
	flag              DQ 0x0
	disco             DQ 0x0

	zero              db "0"
	uno               db "1"
	sautdelMsg        db "",10
	whatCollIs        db "  0 1 2 3 4 5 6 7"
	lenwhatCollIs        equ $-whatCollIs

	espace            db " "
	pointMsg          db "."
	noBombAndFlagMsg  db "~"
	justbombMsg       db "#"
	bombAndFlagMsg    db "x"

	isDiscoveredMsg   db "-"
	
	isLose            DQ 0x0
	isWin             DQ 0x0


	num1 			  dq 0x0
	num2 			  dq 0x0
	num3 			  dq 0x0

	tmpcos                dq 0x0
	tmpx                  dq 0x0
	tmpy                  dq 0x0

	cos                dq 0x0
	x                  dq 0x0
	y                  dq 0x0

section .bss           ; Uninitialized data
	tmp resb 1
	value resb 1

section .text          ; Code Segment
	global _start

; r8   ; bombs
; r9
; r10
; r11 ; is_cos_inside_output
; r12
; r13 ; is_cos_inside_inputx
; r14 ; is_cos_inside_inputy
; r15

%macro discover 1 			; Input : cos (Dans un cl ou un truc de 8 bit) | Output: Write [disco] | Modifications : rax, rbx, rcx
	mov cl, %1  			; On place les cos a rcx
	mov rax, [disco] 		; on place le premier quadra word dans rax

 	mov rbx, 1              ; Masque
 	shl rbx, cl             ; masque = (1 << rax(position random de la bombe))
 	or rax, rbx             ; bombs |= masque

    mov [disco], rax        ; Output dans disco
%endmacro

; Fact (n) = n * fact (n-1) for n > 0
flood_fill:       ; Input [cos] | Modif : discover(rax,rbx, rcx), rdx
    ; 1. Set Q to the empty queue or stack.
    xor rdx, rdx
    mov dl, 65
    push rdx
    ; 2. Add node to the end of Q.
    mov dl, [cos]
    push rdx

    ; 3. While Q is not empty:
    while_Q_not_empy:
        pop rdx
        cmp dl, 65
        je end_flood_fill
    ; 4.   Set n equal to the first element of Q.
        ; Is dl
    ; 5.   Remove first element from Q.
        ; Is always dl
    ; 6.   If n is Inside:
        ; TODO: If indide
        ; j(if not inside) while_Q_not_empty
    ;        Set the n
            discover dl
    ;        Add the node to the west of n to the end of Q.
            ; Faire les verifications
            dec dl
            push rdx
            inc dl
    ;        Add the node to the east of n to the end of Q.
    ;        Add the node to the north of n to the end of Q.
    ;        Add the node to the south of n to the end of Q.
    ; 7. Continue looping until Q is exhausted.
    end_flood_fill:
    ; 8. Return.

    ret


%macro add_number 2			; Input : cos,valeur | Modifications : rax, rbx, rcx
	mov rdx, %1
	mov rcx, 63
	
	sub rcx, rdx
	push rcx

	read_number rcx

	pop rcx
	

	xor rax, rax
	mov bx, %2
	mov word ax, [value]
	add ax, bx
	

	mov bx, 4
	div bl
	
	push ax

	xor ah, ah

	gen_new_number rax, [num3], cl
	mov [num3], rdx

	pop ax
	shr ax, 8

	mov bx, 2
	div bl
	
	push ax

	xor ah, ah

	gen_new_number rax, [num2], cl
	mov [num2], rdx

	pop ax
	shr ax, 8
	
	gen_new_number rax, [num1], cl
	mov [num1], rdx

%endmacro
%macro read_number 1 			; Input : cos | Output : [value] | Modifications : rax, rbx, rcx
	mov rcx, %1  			; On place les cos a rcx
	mov rax, [num1] 		; on place le premier quadra word dans rax

	shr rax, cl 			; on le bitdhift de coo
	and rax, 1 				; on recup seulement le premier nombre

	mov byte [value], al 	; on initialise value à ce nombre

	mov rax, [num2] 		; on va refaire pareil avec num2

	shr rax, cl				; On bitshift num2 de cos
	and al, 1				; on recup seulement le premier nombre

	mov bx, 2				; On multiplie par 2**1
	mul bx
	add [value], al			; On ajoute a value

	mov rax, [num3] 		; On va refaire pareil avec num3 

	shr rax, cl				; On bitshift num2 de cos
	and al, 1				; On recup seulement le premier nombre
	
	mov bx, 4				; On multiplie par 2**2
	mul bx
	add [value], al 		; On ajoute à la value
%endmacro
%macro print_grid 0
	mov rax, 4                         ; Affiche "  0 1 2 3 4 5 6 7\n"
	mov rbx, 1
	mov rcx, whatCollIs
	mov rdx, lenwhatCollIs
	int 80h
	
	mov rax, 0                         ; Definit toute les variables dont a besoin pour affiche grid
	mov rbx, 0
	mov rdx, 0
	mov rcx, 64
	mov r8, [bombs]
	mov r9, [flag]
	mov r10, [disco]
	mov r15, 48                         ; Le numero de la line, on commance par 48 car c'est ord("0") pour pouvoir le print
	call affiche_grid                   ; Affiche toutes les lignes 1 par 1
	
	mov rax, 4                          ; Affiche "\n"
	mov rbx, 1
	mov rcx, sautdelMsg
	mov rdx, 1
	int 80h
	
	mov r15, 0	
%endmacro
%macro gen_new_number 3			;Input : value, num, cos | Output : rdx
	mov cl, %3
	mov rdx, %2
	mov rax, %1
	mov rbx, 1

	shl rbx, cl
	not rbx
	and rdx, rbx

	shl rax, cl    ; code copié depuis https://www.geeksforgeeks.org/modify-bit-given-position/ (il est 2h soyez indulgent)


	or rdx, rax
%endmacro
	

is_cos_inside: 			; Input : x[r13] y[r14], Output [r11], Modifications : rax, rdx

    mov rax, r14					; y --> rax
	mov rdx, r13					; x --> rdx
    cmp rax,0			
    mov r11, 0						; Si y < 0 ==> ret
    jl is_no_inside
        cmp rax,7					; Si y > 7 ==> ret
        jg is_no_inside
            cmp rdx,0		 		; Si x < 0 ==> ret
            jl is_no_inside
                cmp rdx,7			; Si x > 7 ==> ret
                jg is_no_inside
                    mov r11, 255	; Boolean de si la cordonnée est bonne
                    ; Is inside
    is_no_inside:
    	ret

quit_program:
	; Saut de ligne pour éviter le %
	mov rax, 4
	mov rbx, 1
	mov rcx, sautdelMsg
	mov rdx, 1
	int 80h

	; exit(0)
	xor ecx, ecx
	xor edx, edx
	mov     eax, 0x1              ; Set system_call
	mov     ebx, 0               ; Exit_code 0
	int     0x80                  ; Call kernel
	ret

get_x_y: 				; Input : [tmpcos], Output : [tmpx] and [tmpy]
	push rbx                    ; Je sais pas si elle est utilisé donc je la save
	mov rax, [tmpcos]           ; Rax a l'intut tmpcos
	mov bl, 8                  
	div bl                     ; Rax = Rax // 8, Rdx = Rax % 8
	mov [tmpx], ah             ; Met rax, rdx dans les variables output
	mov [tmpy], al 
	pop rbx                     ; Recuperer les variable size
	ret
	

user_input:   			; Output: [tmpx], [tmpy], [cos]
	mov eax, 3                ; Input in cos
	mov ebx, 2                
	mov edx, 4
	mov ecx, cos
	int 80h
	
	mov rdx, 0
	mov bx, 0b100000000                 ;Prend seleuement de 2 premiers caracteres
	mov eax, [cos]
	div bx ; division pour la co x
	
	sub rdx, 48
	mov [x], rdx ; Move de la coo X
	mov rdx, 0
	
	div bx ; redivision pour la co y
	
	sub rdx, 48
	mov [y], rdx  ; move de la co y
	
	mov eax, 0
	mov [cos], eax
	
	mov bx, 8
	mov al, [y] ; On multiplie y par 8 pour avoir la ligne 
	mul bl
	
	add al, [x]
	mov [cos], al ; On ajoute la colonne 
	
	    ; Reset varaibles
	xor rax,rax ; reset al
	xor rbx,rbx
	xor rcx,rcx
	
	ret

generate_bomb:   		; Input [cos]

	mov r8, [bombs]     ; On met bombs dans r8 que ganera un bit a chaque itération
    mov rcx, [nb_bombs] ; Nombre de bombe dans rcx
	generate_bombs_loop:
		;rax = RANDOM       ; Générer un nombre aléatoire dans la variable eax 
		L: rdrand ax        ; https://rosettacode.org/wiki/Random_number_generator_(device)#X86_Assembly
		jnc L 				
		
		; rax(random) %= 64
		and ax, 63
		
		mov [tmpcos], al     	; Met le reste		
		
		
		; Condition de si la bombe est deja placée
		push rcx             ; Save rcx
		mov rcx, [tmpcos]    ; shr ne marche que avec cl(rcx) donc je passe rax a rcx
		mov rbx, r8          ; passe r8 a rbx, pour eviter de le deruire
		shr rbx, cl          ; RightBitShift de cos
		and rbx, 1           ; Si rbx = 1; Alors bombe sinin pas bombe
		pop rcx              ; Recuperer rcx


		cmp rbx, 1                  ; Si bombe est deja ici
		je generate_bombs_loop      ; on genere une autre bombe
		mov rax, [tmpcos]
		mov rdx, [cos]
		cmp rax, rdx         ; Si la position de la bombe (tmpcos) est la ou a cliquer le joueur(cos)
		je generate_bombs_loop      ; On genere une autre bombe

		
		push rcx                    ; Sauvgarde rcx(Compteur nb_bombes)    
		mov rbx, 1                  ; Masque
		mov rcx, [tmpcos]           ; shr ne marche que avec cl(rcx) 
		shl rbx, cl                 ; masque = (1 << rax(position random de la bombe))
		or r8, rbx                  ; bombs |= masque

		call get_x_y

		mov rax, [tmpy] 			; On move y a rax qui sera l'itérateur sur le y
		mov rdx, [tmpx] 			; On move x a rdx qui sera l'itérateur sur le x

		add byte [tmpy], 2
		add byte [tmpx], 2

		dec rdx ; On les decremente car on part de y-1 pour aller a y+2
		dec rax ; idem avec x

		neighbours1:
			neighbours2:
				mov r14, rax
				mov r13, rdx
				
				call is_cos_inside 	; vérifie que les coordonées sont à l'intèrieur de la grille

				mov rax, r14
				mov rdx, r13

				cmp r11, 255 			; Si oui :
				jne neighboursNotInside 	; Appeller la fonction pour augmenter le nombre

				push rdx						; On pus l'itérateur du x
				push rax 		 				; On pus l'itérateur du y
				mov bl, 8   	 				; On place 8 à bl pour multiplier rax par bl après
				mul bl			 				; On multiplie le y par 8 pour avoir la ligne
				add rax, rdx	 				; On ajoute x pour avoir la co

				add_number rax, 1				; On ajoute 1 a la valeur de la case avec write_number
				
				pop rax							; On recup l'itérateur y
				pop rdx							; On recup l'itérateur x
										
				neighboursNotInside:
					inc rdx 				; On augmente l'itérateur du x
					cmp rdx, [tmpx]			; tant que rdx <= x+2 :
					jl neighbours2 			; boucler

					mov rdx, [tmpx] 			; reset l'itérateur du x
					sub rdx, 3 					; et on le remet à x-1

			inc rax				; on incrémente l'itérateur
			cmp rax, [tmpy]		; Condition du while rax<y+2
			jl neighbours1		; se réappelle si la condition n'est pas respectée	
		pop rcx                      ; On reprend rcx en tant que nb_bombs
		dec rcx                      ; On passe a la prochaine bombe
		
		cmp rcx, 0      ; Si y a plus de bombes a placer on quitte
		jne generate_bombs_loop
	mov [bombs], r8         ; bombs a ete bien générée

	; Variable reset
        xor rax, rax
        xor rbx, rbx
        xor rcx, rcx
        xor rdx, rdx
	ret




affiche_grid:   		; Input r8 as [bombs], r9 as [flag], r10 as [disco], r15 as ligne 
				; Output None | Modification r[abcd]x
	
	xor rdx, rdx            ; Verifie si c'est un modulo 8 pour sauter une ligne
	mov rax, rcx
	mov rbx, 8
	div rbx
	dec rcx     ; Passe a l'itteration suivante
	push rcx                ; Sauvgarde rcx, je sais pas si c'est utile

	cmp rdx, 0              ; Si c'est modulo 8 on saute une ligne, car c'est le premier char de la ligne
	jne pass_saut_de_ligne  ; Sinon passe
		mov rax, 4                ; Saute une ligne
		mov rbx, 1
		mov rcx, sautdelMsg
		mov rdx, 1
		int 80h

		
		mov byte[rsp-1], r15b     ; Print The current ligne
		mov eax,1                     ; Write system call number
		mov edi,1                     ; file descriptor (1 = stdout)
		lea rsi,[rsp-1]               ; address of message on the stack
		mov edx,1                     ; length of message
		syscall                   ; Call system, pas int 80h car sa marche pas

		
		mov rax, 4                ; Print un espace après le nombre
		mov rbx, 1
		mov rcx,espace 
		mov rdx, 1
		int 80h

		inc r15                   ; Ajoute 1 au nombre de lignes 
	pass_saut_de_ligne:
	pop rcx



	; Affiche le premier caractere 
	                            ; Si le lsb modulo 2 est 1 ou 0 pour print 1 ou 0
	mov rax, r8                 ; Met r8(bombs avec le lsb etant la position acctuelle) dans rax
	shr rax, 1                  ; Passe a la bombe suivante
	mov r8, rax                 ; Re sauvgarde rax dans r8
	push rcx                    ; Sauvgarde le rcx pour pas le perdre
	jc print_bomb
	print_no_bomb:              ; Si y a pas de bombe
		mov rax, r9         ; Met r8(bombs avec le lsb etant la position acctuelle) dans rax
		shr rax, 1          ; Passe a la bombe suivante
		mov r9, rax         ; Re sauvgarde rax dans r8
		jc print_no_bomb_and_flag   ; Pas bombe et pas de drapeau
                                            ; Print le nombre de bombe de nombre autour

			read_number rcx     ; Lit le nombre de bombe autour
			mov rax, [value]    ; Le met dans rax

			add al, 48           ; Ajoute 48 pour avoir l'assci du nombre bombe autour
			mov byte[rsp-1], al  ; Ajoute au stack

			mov eax,1            ; Write system call number
			mov edi,1            ; file descriptor (1 = stdout)
			lea rsi,[rsp-1]      ; address of message on the stack
			mov edx,1            ; length of message
			syscall              ; Syscall, mais pas int 80h car sa marche pas

			jmp end_print

		print_no_bomb_and_flag:     ; Si y a pas de bombe  et un flag
			mov rax, 4          ; on print "~"
			mov rbx, 1
			mov rcx, noBombAndFlagMsg 
			mov rdx, 1
			int 80h
			jmp end_print
	print_bomb:                
		mov rax, r9  ; Met r8(bombs avec le lsb etant la position acctuelle) dans rax
		shr rax, 1   ; Passe a la bombe suivante
		mov r9, rax  ; Re sauvgarde rax dans r8
		jc print_bomb_and_flag       ; Bombe et pas de flag
			mov rax, 4
			mov rbx, 1
			mov rcx, justbombMsg ; Print "#"
			mov rdx, 1
			int 80h
			jmp end_print
		print_bomb_and_flag:         ; Bombe and flag
			mov rax, 4
			mov rbx, 1
			mov rcx, bombAndFlagMsg ; Print "x"
			mov rdx, 1
			int 80h
			jmp end_print
	end_print:

	; Print le 2 eme caractere
	mov rax, r10  ; Met r8(bombs avec le lsb etant la position acctuelle) dans rax
	shr rax, 1   ; Passe a la bombe suivante
	mov r10, rax  ; Re sauvgarde rax dans r8
	jc print_is_disco                  ; Si c'est pas decouvert
		mov rax, 4
		mov rbx, 1
		mov rcx, pointMsg          ; affiche "."
		mov rdx, 1
		int 80h
		jmp end_print_disco
	print_is_disco:                    ; Si c'est découvert
		mov rax, 4
		mov rbx, 1
		mov rcx, isDiscoveredMsg   ; affiche "-"
		mov rdx, 1
		int 80h
	end_print_disco:
	pop rcx     ; Re recupere le rcx en tant que compteur 

	cmp rcx, 0  ; Si on est a la fin on quitte
	jne affiche_grid   
	ret


; discover: ;Input [tmpcos];    ; rcx, = cos  ; rax= y; rdx = x
; 	mov rcx, [tmpcos]
; 
; 	mov r10, [disco]
; 	mov rbx, 1     ; Masque
; 	; mov rcx, [cos]   ;  a faire avant
; 	shl rbx, cl     ; masque = (1 << rax(position random de la bombe))
; 	or r10, rbx    ; bombs |= masque
; 	mov [disco], r10
; 	ret
_start:					; User prompt
	call user_input     ; Input, output [cos], [x], [y]
	call generate_bomb  ; Input [cos], ouput [bombs]
	; call get_x_and_y
	; call discover

while_true:

	print_grid

	mov r9, [num1]

	mov r10, [num2]

	mov r12, [num3]

	; call is_game_finished
   
	mov eax, 4
	mov ebx, 1
	mov ecx, posMsg
	mov edx, lenposxMsg
	int 80h
	call user_input

	; xor rax, rax
	; xor rbx, rbx
	; xor rcx, rcx
	; xor rdx, rdx

	mov rcx, [cos]   ; 
	call get_x_y


        mov cl, [cos]
	discover cl


	; mov r8, [bombs]
	; mov r9, [flag]
	; mov r10, [disco]

	jmp while_true


	call quit_program
