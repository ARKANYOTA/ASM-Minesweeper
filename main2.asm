section .data          ; Data segment
	posMsg            db 'Position x et y sans separation: '
	lenposxMsg           equ $-posMsg

	youWinMessage     db 10,' You Win, Bravo!'
	lenyouWinMessage     equ $-youWinMessage
	youLoseMessage    db 10,' You Lose, Ressaye!'
	lenyouLoseMessage    equ $-youLoseMessage

	nb_bombs          DQ 1

	bombs             DQ 0x0;0xa09440c820930000
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

section .bss           ; Uninitialized data
	cos resd 1
	x resb 1
	y resb 1
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

%macro add_number 2			; Input : cos,valeur | Modifications : rax, rbx, rcx
	xor rax, rax
	read_number %1
	mov rcx, %1
	mov bx, %2
	mov word ax, [value]
	add ax, bx
	

	mov bx, 4
	div bl
	
	push ax

	xor ah, ah
	shl rax, cl

	or [num3], rax

	pop ax
	shr ax, 8

	mov bx, 2
	div bl
	
	push ax

	xor ah, ah
	shl rax, cl

	or [num2], rax

	pop ax
	shr ax, 8
	
	shl rax, cl

	or [num1], rax

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
	mov rax, 4
	mov rbx, 1
	mov rcx, whatCollIs
	mov rdx, lenwhatCollIs
	int 80h
	
	mov rax, 0
	mov rbx, 0
	mov rdx, 0
	mov rcx, 64
	mov r8, [bombs]
	mov r9, [flag]
	mov r10, [disco]
	mov r15, 48     ; Line
	call affiche_grid
	
	mov rax, 4
	mov rbx, 1
	mov rcx, sautdelMsg
	mov rdx, 1
	int 80h
	
	mov r15, 0	
%endmacro
	

is_cos_inside: 			; Input : x[r13] y[r14], Output [r11], Modifications : rax, rdx

    mov rax, r14					; y --> rax
	mov rdx, r13					; x --> rdx
    cmp rax,0			
    mov r11, 0						; Si y < 0 ==> ret
    jl is_no_inside
        cmp rax,7					; Si y > 7 ==> ret
        jg is_no_inside
            cmp rdx,0				; Si x < 0 ==> ret
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

		xor rdx, rdx          ; Reset la variable rdx
		mov rbx, 64           ; Rbx modulo 64
		div rbx
		mov rax, rdx          ; Met le modulo dans la variable eax (Position dans la grille)
		
		mov [tmpcos], rax     ; Met rax dans tmpcos
		call get_x_y
		
		
		
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
				je neighboursInside 	; Appeller la fonction pour augmenter le nombre
				neighboursInside:
					push rdx						; On pus l'itérateur du x
					push rax 		 				; On pus l'itérateur du y
					mov bl, 8   	 				; On place 8 à bl pour multiplier rax par bl après
					mul bl			 				; On multiplie le y par 8 pour avoir la ligne
					add rax, rdx	 				; On ajoute x pour avoir la co

					add_number rax, 1				; On ajoute 1 a la valeur de la case avec write_number
					
					pop rax							; On recup l'itérateur y
					pop rdx							; On recup l'itérateur x
				
				inc rdx 				; On augmente l'itérateur du x
				cmp rdx, tmpx			; tant que rdx <= x+2 :
				jl neighbours2 			; boucler

				mov rdx, [tmpx] 			; reset l'itérateur du x
				sub rdx, 3 					; et on le remet à x-1

			inc rax				; on incrémente l'itérateur
			cmp rax, tmpy		; Condition du while rax<y+2
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




affiche_grid:   		; A commenter
	; Verifie si c'est un modulo 8 pour sauter une ligne
	xor rdx, rdx    
	mov rax, rcx
	mov rbx, 8
	div rbx
	push rcx
	cmp rdx, 0
	jne pass_saut_de_ligne
		mov rax, 4
		mov rbx, 1
		mov rcx, sautdelMsg
		mov rdx, 1
		int 80h

		; Print The current ligne
		mov byte[rsp-1], r15b
		mov eax,1       ;Write system call number
		mov edi,1       ;file descriptor (1 = stdout)
		lea rsi,[rsp-1] ;address of message on the stack
		mov edx,1       ;length of message
		syscall

		; Print un espace après le nombre
		mov rax, 4
		mov rbx, 1
		mov rcx,espace 
		mov rdx, 1
		int 80h

		inc r15     ; Ajoute 1 au nombre de lignes 
	pass_saut_de_ligne:
	pop rcx



	; Si le lsb modulo 2 est 1 ou 0 pour print 1 ou 0
	mov rax, r8  ; Met r8(bombs avec le lsb etant la position acctuelle) dans rax
	shr rax, 1   ; Passe a la bombe suivante
	mov r8, rax  ; Re sauvgarde rax dans r8
	push rcx     ; Sauvgarde le rcx pour pas le perdre
	jc print_bomb
	print_no_bomb:     ; Func Name... 
		mov rax, r9  ; Met r8(bombs avec le lsb etant la position acctuelle) dans rax
		shr rax, 1   ; Passe a la bombe suivante
		mov r9, rax  ; Re sauvgarde rax dans r8
		jc print_no_bomb_and_flag
			mov rax, 4
			mov rbx, 1
			mov rcx, espace
			mov rdx, 1
			int 80h
			jmp end_print
		print_no_bomb_and_flag:
			mov rax, 4
			mov rbx, 1
			mov rcx, noBombAndFlagMsg 
			mov rdx, 1
			int 80h
			jmp end_print
	print_bomb:
		mov rax, r9  ; Met r8(bombs avec le lsb etant la position acctuelle) dans rax
		shr rax, 1   ; Passe a la bombe suivante
		mov r9, rax  ; Re sauvgarde rax dans r8
		jc print_bomb_and_flag
			mov rax, 4
			mov rbx, 1
			mov rcx, justbombMsg
			mov rdx, 1
			int 80h
			jmp end_print
		print_bomb_and_flag:
			mov rax, 4
			mov rbx, 1
			mov rcx, bombAndFlagMsg
			mov rdx, 1
			int 80h
			jmp end_print
	end_print:
	mov rax, r10  ; Met r8(bombs avec le lsb etant la position acctuelle) dans rax
	shr rax, 1   ; Passe a la bombe suivante
	mov r10, rax  ; Re sauvgarde rax dans r8
	jc print_is_disco
		mov rax, 4
		mov rbx, 1
		mov rcx, pointMsg 
		mov rdx, 1
		int 80h
		jmp end_print_disco
	print_is_disco:
		mov rax, 4
		mov rbx, 1
		mov rcx, isDiscoveredMsg
		mov rdx, 1
		int 80h
	end_print_disco:
	pop rcx     ; Re recupere le rcx en tant que compteur 

	dec rcx     ; Passe a l'itteration suivante
	cmp rcx, 0  ; Si on est a la fin on quitte
	jne affiche_grid   
	ret
_start:					; User prompt
	call user_input     ; Input, output [cos], [x], [y]
	call generate_bomb  ; Input [cos], ouput [bombs]
	; mov qword [num1], 0
	; mov qword [num2], 0
	; mov qword [num3], 0
	; call get_x_and_y
	; call discover

while_true:
	mov eax, 4
	mov ebx, 1
	mov ecx, posMsg
	mov edx, lenposxMsg
	int 80h

    print_grid

    ; call is_game_finished
   
    ; call user_input

    ; xor rax, rax
    ; xor rbx, rbx
    ; xor rcx, rcx
    ; xor rdx, rdx

    ; mov rcx, [cos]   ; 
    ; call discover


    ; mov r8, [bombs]
    ; mov r9, [flag]
    ; mov r10, [disco]
    
    jmp while_true

    
    call quit_program
