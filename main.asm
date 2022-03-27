section .data                           ;Data segment
	LookUpDig db "0123456789"             ; Translation Table
	loseMsg db 'Perdu Dommage'
	lenloseMsg equ $-loseMsg             ;The length of the message
	posxMsg db 'Position x: '
	lenposxMsg equ $-posxMsg             ;The length of the message
	posyMsg db 'Position y: '
	lenposyMsg equ $-posyMsg             ;The length of the message
	bombs DQ 0x0
	Flags DQ 0
	disco DQ 0
	vars  DQ 0
	nb_bombs DQ 14
	zero db "0"
	uno  db "1"

section .bss           ;Uninitialized data
	PID:  resb 8
	var1: resb 1

section .text          ;Code Segment
	global _start

	
randomnumgenerator:

        ret



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

v2_print_bin:   ; Variable = r8
    mov rax, r8
    shr rax, 1
    mov r8, rax
    jc print_1
    print_0:
        mov rax, 4
        mov rbx, 1
        mov rcx, zero 
        mov rdx, 1
        int 80h
        jmp end_print
    print_1:
        mov rax, 4
        mov rbx, 1
        mov rcx, uno 
        mov rdx, 1
        int 80h
    end_print:
    cmp r8, 0
    jne v2_print_bin
    ret
    

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

_start:                ;User prompt
    
    mov rax, 0
    mov rbx, 64        ; Permet de faire un modulo 64
    mov rdx, 0 
    mov r8, [bombs]
    mov rcx, [nb_bombs]
    call generate_bombs

    

	; mov r, [bombs]
	call v2_print_bin                ; Affiche le nombre 103 en binaire

	; exit(0)
	mov     eax, 0x1              ; Set system_call
	mov     ebx, 0               ; Exit_code 0
	int     0x80                  ; Call kernel
	

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
