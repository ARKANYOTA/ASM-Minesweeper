section .data          ; Data segment
	posMsg            db 'Position x et y sans separation: '
	lenposxMsg           equ $-posMsg

	youWinMessage     db 10,' You Win, Bravo!'
	lenyouWinMessage     equ $-youWinMessage
	youLoseMessage    db 10,' You Lose, Ressaye!'
	lenyouLoseMessage    equ $-youLoseMessage

	nb_bombs          DQ 14

	bombs             DQ 0x0;0xa09440c820930000
	flag              DQ 0x0
	disco             DQ 0x0

	zero              db "0"
	uno               db "1"
	sautdelMsg        db "",10
	whatCollIs        db "  0 1 2 3 4 5 6 7"
	lenwhatCollIs        equ $-whatCollIs

	espace            db " "
	noBombAndFlagMsg  db "~"
	justbombMsg       db "#"
	bombAndFlagMsg    db "x"

	isDiscoveredMsg   db "-"
	
	isLose            DQ 0x0
	isWin             DQ 0x0
	
	num1 			  dq 0x0
	num2 			  dq 0x0
	num3 			  dq 0x0

section .bss           ; Uninitialized data
    cos resd 1
    x resb 1
    y resb 1
	tmp resb 1
	value resb 1

section .text          ; Code Segment
	global _start

generate_bombs:
	;rax = RANDOM 
	L: rdrand ax        ; Générer un nombre aléatoire dans la variable eax 
	jnc L               ; https://rosettacode.org/wiki/Random_number_generator_(device)#X86_Assembly

	; rax = rax%64 
	xor rdx, rdx        ; Reset la variale
	mov rbx, 64         ; modulo 64 le nombre
	div rbx
	mov rax, rdx        ; Met le modulo dans la variable rax

	xor rdx, rdx        ; Reset rdx pour la prochaine utilisation
	xor rbx, rbx

	; Condition de si la bombe est deja placée
	push rcx
	mov rcx, rax
	
	mov rbx, r8
	shr rbx, cl 
	and rbx, 1
	pop rcx
	cmp rbx, 1
	je generate_bombs
    mov rbx, [cos]                    ; Je crois que ca marche pas ouf bien cette merde
    cmp rax, rbx
    je generate_bombs


	mov rbx, 1     ; Masque
	push rcx      ; Sauvgarde rcx(Compteur nb_bombes)    

	mov rcx, rax
	shl rbx, cl     ; masque = (1 << rax(position random de la bombe))
	or r8, rbx    ; bombs |= masque


	call get_x_and_y

	mov [y], rax
	mov [x], rdx

	dec rdx
	dec rax
	add byte [y], 2
	add byte [x], 2

	mov byte [tmp], 1

	neighbours1:


		jmp neighbours2

		inc rax
		cmp rax, y
		jne neighbours1

		ret
	neighbours2:

		call is_cos_inside
		cmp r11, 255
		je neighboursInside

		
		inc rdx
		cmp rdx, x
		jne neighbours2

		mov rdx, [x]
		sub rdx, 3
		ret
	neighboursInside:
		push rax
		mov bl, 8
		mul bl
		add rax, rdx
		mov [cos], rax
		call write_number
		pop rax
		ret
	pop rcx       ; On reprend rcx en tant que nb_bombs
	dec rcx

	cmp rcx, 0      ; Si y a plus de bombes a placer on quitte
	jne generate_bombs
	mov [bombs], r8
	ret


affiche_grid:
	; Verifie si c'est un modulo 8 pour sauter une ligne
	xor rdx, rdx    
	mov rax, rcx
	mov rbx, 8
	div rbx
	mov r13, rcx
	push rcx
	cmp rdx, 0
	jne pass_saut_de_ligne
		mov rax, 4
		mov rbx, 1
		mov rcx, sautdelMsg
		mov rdx, 1
		int 80h

		; Print The current ligne
		mov byte[rsp-1], r14b
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

		inc r14     ; Ajoute 1 au nombre de lignes 
	pass_saut_de_ligne:
	pop rcx



	;                     espace            db " "
	;                     noBombAndFlagMsg  db "~"
	;                     justbombMsg       db "#"
	;                     bombAndFlag       db "x"
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
		mov rcx, espace 
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

write_number: ;placer les coos à [cos] et le nombre à ajouter a [tmp]
	call read_number
	mov rcx, [cos]
	mov bx, [tmp]
	mov word ax, [value]
	add ax, bx
	

	mov bx, 4
	div bx
	
	push ax

	xor ah, ah
	shl rax, cl

	or [num3], rax

	pop ax
	shr ax, 8

	mov bx, 2
	div bx
	
	push ax

	xor ah, ah
	shl rax, cl

	or [num2], rax

	pop ax
	shr ax, 8
	
	shl rax, cl

	or [num1], rax

	ret	
read_number: ; On store les coos du nombre à lire dans [cos] la valeur est return dans [value]
	xor rax, rax
	mov rcx, [cos]
	mov rax, [num1] ; on place le premier quadra word dans rax

	shr rax, cl ; on le bitdhift des coos
	and rax, 1 ; on recup seulement le premier nombre

	mov byte [value], al ; on initialise value à ce nombre

	mov rax, [num2] ; on va refaire pareil avec num2 mais en multipliant par 2 à la fin (système binaire)

	shr rax, cl
	and al, 1

	mov bx, 2
	mul bx
	add [value], al

	mov rax, [num3] ; on va refaire pareil avec num2 mais en multipliant par 4 à la fin (système binaire)

	shr rax, cl
	and al, 1
	
	mov cx, 4
	mul cx
	add [value], al

	ret

user_input:
    mov eax, 3
    mov ebx, 2,
    mov edx, 4
    mov ecx, cos
    int 80h

    mov rdx, 0
    mov bx, 0b100000000
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
    mul bx

    add al, [x]
    mov [cos], al ; On ajoute la colonne 

    xor al,al ; reset al
    xor rbx,rbx
    xor rcx,rcx
    
    ret

    
print_grid:
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
    mov r14, 48     ; Line
    call affiche_grid
    mov r14, 0
    ret
    

is_game_finished:
    ; Vérifie si on a gagnée
    mov r8, [bombs]
    mov r10, [disco]
    not r8
    cmp r8, r10
    jne verif_lose_condition
        mov rax, 4
        mov rbx, 1
        mov rcx, youWinMessage
        mov rdx, lenyouWinMessage
        int 80h
         
        call quit_program
    verif_lose_condition:
        ; Vérifie si on a perdu
        mov r8, [bombs]
        mov r10, [disco]
        and r8, r10        ; On AND les 2 int, si a un endroit il y a bombs et discovered alors la nouvelle valeur sera plus grande que 0
        cmp r8, 0
        je continue_game
            mov rax, 4
            mov rbx, 1
            mov rcx, youLoseMessage
            mov rdx, lenyouLoseMessage
            int 80h
             
            call quit_program
    continue_game:
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

get_x_and_y:
    ; mov rax, [cos]
    mov rbx, 8
    div bl
    ret ; rax = y, rdx = x

is_cos_inside:
    ; rax = y, rdx = x
    cmp rax,0
    mov r11, 0                       ; La cordonn{es est pas bonne
    jl is_no_inside
        cmp rax,7
        jg is_no_inside
            cmp rdx,0
            jl is_no_inside
                cmp rdx,7
                jg is_no_inside
                    mov r11, 255                ; Boolean de si la cordonnée est bonne
                    ; Is inside
    is_no_inside:
    ret

discover:    ; rcx, = cos
    ; mov r10, [disco]
    ; mov rbx, 1     ; Masque
    ; ; mov rcx, [cos]   ;  a faire avant
    ; shl rbx, cl     ; masque = (1 << rax(position random de la bombe))
    ; or r10, rbx    ; bombs |= masque
    ; mov [disco], r10

    ; ; Decouvrir dans la hauteur
    ; push rcx
    ; mov rax, rcx
    ; call get_x_and_y
    ; ; rax = y, rdx = x

    ; cmp rax, 0
    ; jl no_discover
    ; jle discover_down
    ;     push rcx
    ;     mov rax, rcx
    ;     call get_x_and_y
    ;     ; rax = y, rdx = x
    ;     

    ;     call discover
    ;     pop rcx
    ; discover_down:
    ; call no_discover
        
        

    ret

_start:                ;User prompt
    
    call user_input

	mov qword [num1], 0
	mov qword [num2], 0
	mov qword [num3], 0

	; call read_number

    mov rax, 0         ; Generere les bombes En fonction de l'input utilisateur (TODO)
    mov rbx, 64        ; Permet de faire un modulo 64
    mov rdx, 0 
    mov r8, [bombs]
    mov rcx, [nb_bombs]
    call generate_bombs
    call discover

while_true:
    call print_grid


    call is_game_finished
   
    mov rax, 4
    mov rbx, 1
    mov rcx, sautdelMsg
    mov rdx, 1
    int 80h

    call user_input

    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx

    mov rcx, [cos]   ; 
    call discover


    mov r8, [bombs]
    mov r9, [flag]
    mov r10, [disco]
    mov r15, 0               ; Is finished
    
    jmp while_true

    
    call quit_program
