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
	pointMsg          db "."
	noBombAndFlagMsg  db "~"
	justbombMsg       db "#"
	bombAndFlagMsg    db "x"

	isDiscoveredMsg   db "-"
	
	isLose            DQ 0x0
	isWin             DQ 0x0


section .bss           ; Uninitialized data
    cos resd 1
    x resb 1
    y resb 1
	num1 resq 1
	num2 resq 1
	num3 resq 1
	tmp resb 1
	value resb 1

section .text          ; Code Segment
	global _start

; r8
; r9
; r10
; r11
; r12
; r13
; r14
; r15

