; section .data                           ;Data segment
;     txt db "Hello",10
;     lentxt equ $-txt
; section .bss           ;Uninitialized data
; section .text          ;Code Segment
; 	global _start
; 
; _start:                ;User prompt
; 
;     mov r8, 5           ; Went print 5 in console
;     add r8, 48          ; add ascii of 0 to get ascii of 5
; 
;     push r8 
;     mov eax, 4
;     mov ebx, 1
;     mov ecx, esp 
;     mov edx, 1
;     int 80h
; 
;     mov eax, 4
;     mov ebx, 1
;     mov ecx, txt
;     mov edx, lentxt
;     int 80h
; 
; 	; exit(0)
; 	mov     eax, 0x1              ; Set system_call
; 	mov     ebx, 0               ; Exit_code 0
; 	int     0x80                  ; Call kernel
; 
;  -------------------
;  V2
;  ---------------
section .text
global _start
_start:
    ; mov byte[rsp-1], 0x35
    ; mov eax,1       ;Write system call number
    ; mov edi,1       ;file descriptor (1 = stdout)
    ; lea rsi,[rsp-1] ;address of message on the stack
    ; mov edx,1       ;length of message
    ; syscall

    ; mov byte[rsp-1], 0x36
    ; mov eax,1       ;Write system call number
    ; mov edi,1       ;file descriptor (1 = stdout)
    ; lea rsi,[rsp-1] ;address of message on the stack
    ; mov edx,1       ;length of message
    ; syscall


    mov eax,60      ;Exit system call
    mov edi, 0     ;RDI=0
    syscall
; 
; 
; section .text
; global _start
; _start:
;     mov r8, 0x35
;     mov eax,1       ;Write system call number
;     mov edi,1       ;file descriptor (1 = stdout)
;     lea rsi,[r8] ;address of message on the stack
;     mov edx,1       ;length of message
;     syscall
;     mov eax,60      ;Exit system call
;     xor edi,edi     ;RDI=0
;     syscall
; 
