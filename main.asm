section .data                           ;Data segment
	LookUpDig         db "0123456789"             ; Translation Table
	loseMsg           db 'Perdu Dommage'
	lenloseMsg           equ $-loseMsg             ;The length of the message
	posxMsg           db 'Position x: '
	lenposxMsg           equ $-posxMsg             ;The length of the message
	posyMsg           db 'Position y: '
	lenposyMsg           equ $-posyMsg             ;The length of the message
	bombs             DQ 0x0
	flag              DQ 0x001
	disco             DQ 0x33
	vars              DQ 0
	nb_bombs          DQ 14
	zero              db "0"
	uno               db "1"
	bombsMsg          db "B "
	nothingMsg        db ". "
	sautdelMsg        db "",10
	espace            db " "
	whatCollIs        db "  0 1 2 3 4 5 6 7"
	lenwhatCollIs        equ $-whatCollIs             ;The length of the message

section .bss           ;Uninitialized data
    cos resd 1
    x resb 1
    y resb 1

section .text          ;Code Segment
	global _start

generate_bombs:
	
	; rax = RANDOM 
	L: rdrand ax    ; Générer un nombre aléatoire dans la variable eax 
	jnc L           ; https://rosettacode.org/wiki/Random_number_generator_(device)#X86_Assembly

	; rax = rax%64 
	xor rdx, rdx     ; Reset la variale
	mov rbx, 64     ; modulo 64 le nombre
	div rbx         ; 
	mov rax, rdx    ; Met le modulo dans la variable rax

	xor rdx, rdx    ; Reset rdx pour la prochaine utilisation
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


	mov rbx, 1     ; Masque
	push rcx      ; Sauvgarde rcx(Compteur nb_bombes)    

	mov rcx, rax
	shl rbx, cl     ; masque = (1 << rax(position random de la bombe))
	or r8, rbx    ; bombs |= masque

	pop rcx       ; On reprend rcx en tant que nb_bombs
	dec rcx

	cmp rcx, 0      ; Si y a plus de bombes a placer on quitte
	jne generate_bombs
	mov [bombs], r8
	ret


affiche_grid:
	; Verifie si c'est un modulo 8 pour sauter une ligne
	mov rdx, 0      
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



	; Si le lsb modulo 2 est 1 ou 0 pour print 1 ou 0
	mov rax, r8  ; Met r8(bombs avec le lsb etant la position acctuelle) dans rax
	shr rax, 1   ; Passe a la bombe suivante
	mov r8, rax  ; Re sauvgarde rax dans r8
	push rcx     ; Sauvgarde le rcx pour pas le perdre
	jc print_1
	print_0:     ; Func Name... 
		mov rax, 4
		mov rbx, 1
		mov rcx, nothingMsg 
		mov rdx, 2
		int 80h
		; saut de ligne
		jmp end_print
	print_1:
		mov rax, 4
		mov rbx, 1
		mov rcx, bombsMsg
		mov rdx, 2
		int 80h
	end_print:
	pop rcx     ; Re recupere le rcx en tant que compteur 

	dec rcx     ; Passe a l'itteration suivante
	cmp rcx, 0  ; Si on est a la fin on quitte
	jne affiche_grid   
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

    

_start:                ;User prompt
    
    call user_input

    mov rax, 0
    mov rbx, 64        ; Permet de faire un modulo 64
    mov rdx, 0 
    mov r8, [bombs]
    mov rcx, [nb_bombs]
    call generate_bombs

    

	; mov r, [bombs]
	; call v2_print_bin                ; Affiche le nombre 103 en binaire

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

    ; Saut de ligne pour éviter le %
    mov rax, 4
    mov rbx, 1
    mov rcx, sautdelMsg
    mov rdx, 1
    int 80h

	; exit(0)
	mov     eax, 0x1              ; Set system_call
	mov     ebx, 0               ; Exit_code 0
	int     0x80                  ; Call kernel
