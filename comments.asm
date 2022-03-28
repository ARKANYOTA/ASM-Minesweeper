; mov eax, 3
; mov ebx, 2
; mov ecx, num
; mov edx, 5          ;5 bytes (numeric, 1 for sign) of that information
; int 80h


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
