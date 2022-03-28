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
	dec rcx
	; rax = RANDOM 
	L: rdrand ax    ; Générer un nombre aléatoire dans la variable eax 
	jnc L           ; https://rosettacode.org/wiki/Random_number_generator_(device)#X86_Assembly

	; rax = rax%64 
	mov rdx, 0      ; Reset la variale
	mov rbx, 64     ; modulo 64 le nombre
	div rbx         ; 
	mov rax, rdx    ; Met le modulo dans la variable rax

	mov rdx, 0      ; Reset rdx pour la prochaine utilisation
	mov rbx, 0

	; Condition de si la bombe est deja placée
	; push rcx
	; mov rcx, rax
	; 
	; mov rbx, r8
	; shr rbx, cl 
	; and rbx, 1
	; pop rcx
	; cmp rbx, 1
	; je generate_bombs
	mov rbx, 1     ; Masque
	push rcx      ; Sauvgarde rcx(Compteur nb_bombes)
	mov rcx, rax    ; masque = (1 << rax(position random de la bombe))
	shl rbx, cl     ; ↑
	or r8, rbx    ; bombs |= masque
	pop rcx       ; On reprend rcx en tant que nb_bombs

	cmp rcx, 0      ; Si y a plus de bombes a placer on quitter
	jne generate_bombs
	mov [bombs], r8
	ret


breakpoint:
    ret

affiche_grid:
	; Verifi si c'est un modulo 8 pour sauter une ligne
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

_start:                ;User prompt
   
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
        mov r14, 48     ; Line on commance par 48 pour directement avoir le code ascii
        call affiche_grid
        mov r14, 0




	
; mov eax, 3
; mov ebx, 2
; mov ecx, num
; mov edx, 5          ;5 bytes (numeric, 1 for sign) of that information
; int 80h


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
	

; END

; 	; Make a loop to print numbers from 0 to 9
; 	mov ecx, 48
; 	loopstart:
; 		mov eax, 4
; 		mov ebx, 1
; 		mov edx, 1 
; 		int 80h
; 		
; 		mov eax, ecx
; 		mov ebx, 1
; 		mov edx, 1
; 		int 80h
; 
; 		inc ecx
; 		cmp ecx, 57
; 		jne loopstart
; 	int 80h
; 
; 
; 
; 	mov eax, 4
; 	mov ebx, 1
; 	mov ecx, loseMsg
; 	mov edx, lenloseMsg
; 	int 80h

;      mov     rax, 0      ; GET_PID call
;      add     rax, byte[bombs]
;      mov     rbx, 0xA              ; Set divider to 10
;      mov     ebp, PID+6   ;  PID+6            ; Save the address of PID+6 to EBP
;      jnz     LoopMe                ; Run the loop to convert int to string
; 
; LoopMe:
;      div     rbx                   ; Divide the PID by 10
;      mov     cl, [LookUpDig+edx]   ; Copy ASCII value to CL
;      mov     [ebp], cl             ; Copy CL to PID buffer
;      dec     ebp                   ; Move to next byte in the buffer
;      xor     edx, edx              ; Clear the remainder, else weird results :)
;      inc     rax                   ; Increase EAX tricking JNZ
;      dec     rax                   ; Decrease to get back to original value
;      jnz     LoopMe                ; Loop until EAX is zero (all integers converted)
;      jz      PrintOut              ; When done call the print out function
; 
; PrintOut:
;      mov     rbx, 0x1              ; FD stdout
;      mov     rax, 0x4              ; sys_write call
;      int     0x80                  ; Call kernel
; 
;      mov     [PID+7], byte 0xA     ; Push a newline to PID string
; 
;      mov     edx, 0x8              ; Max length of 8 bytes
;      mov     rcx, PID              ; Push PID value
;      mov     rbx, 0x1              ; FD stdout
;      mov     rax, 0x4              ; sys_write call
;      int     0x80                  ; Call kernel



; mov eax, 4
; mov ebx, 1
; mov ecx, loseMsg
; mov edx, lenloseMsg
; int 80h

; ;Read and store the user input
; mov eax, 3
; mov ebx, 2
; mov ecx, num
; mov edx, 5          ;5 bytes (numeric, 1 for sign) of that information
; int 80h

; ;Output the message 'The entered number is: '
; mov eax, 4
; mov ebx, 1
; mov ecx, dispMsg
; mov edx, lenDispMsg
; int 80h

; ;Output the number entered
; mov eax, 4
; mov ebx, 1
; mov ecx, num
; mov edx, 5
; int 80h



; printNumber:
;     mov esi, [var1]
;     add esi, 48
;     mov [var1], esi
; 
;     mov eax, 4
;     mov ebx, 1
;     mov ecx, var1
;     mov edx, 10
; 
;     int 0x80
;     ret
; 
; 
; Generate n random bombs in the map;
; n is the number of bombs
;    mov rcx, 10
; start_generate_bombs:
;    mov rax, bombs
;    dec rcx
;    cmp rcx, 0
;    jg start_generate_bombs
; mov rax, bombs

; startloop:
; 
; eax ebx ecx edx²
; cmp rcx, 0
; jne startloop
; 
; mov esi, 52; esi = 52 
; mov [var1], esi
; call printNumber
; 
; 
; ; On pourait uilise r ça c'est possiblement plus opti https://www.aldeid.com/wiki/X86-assembly/Instructions/shr
; print_bin:                         ; Prend comme argument rax et affiche le nombre en binaire
;                                    ; Mais attention, il est print de gauche a droite, lsb à gauche et msb à droite
; 	mov ecx, 2
; 	mov rdx, 0
; 	div ecx                    ; Divise rax par 2, met le reste dans edx et met le quotient dans eax
; 	push rax 		   ; On met le quotient dans la pile, car il est effacé par print_1 ou print_0
; 	cmp rdx, 1
; 	je print_1                 ; Si le reste est 1, on appelle print_1 sinon print_0
; print_0:
; 	call just_print_0
; 	cmp rax, 1
; 	je end_print_bin
; print_1:
; 	call just_print_1
; end_print_bin:
; 	pop rax                     ; On récupère le quotient
; 	cmp rax, 0                  
; 	jne print_bin               ; Si le quotient est egale a 0, on sort de la fonction
; 	ret
; 
; just_print_0:
; 	mov rax, 1
; 	mov rdi, 1
; 	mov rsi, zero 
; 	mov rdx, 1
; 	syscall
; 	ret
; 
; just_print_1:
; 	mov rax, 1
; 	mov rdi, 1
; 	mov rsi, uno
; 	mov rdx, 1
; 	syscall
; 	ret
; v2_print_bin:   ; Variable = r8
;     mov rax, r8
;     shr rax, 1
;     mov r8, rax
;     jc print_1
;     print_0:
;         mov rax, 4
;         mov rbx, 1
;         mov rcx, zero 
;         mov rdx, 1
;         int 80h
;         jmp end_print
;     print_1:
;         mov rax, 4
;         mov rbx, 1
;         mov rcx, uno 
;         mov rdx, 1
;         int 80h
;     end_print:
;     cmp r8, 0
;     jne v2_print_bin
;     ret
;     
