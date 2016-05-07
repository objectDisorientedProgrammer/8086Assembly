; Assignment #7 - Conditional Processing
; created March 5, 2012 by Douglas Chidester. Finished [3/7/12]
.model small
.stack 100h

.data
boxTop db 0DAh, 21 dup(0C4h), 0BFh, 0Dh, 0Ah, '$'
choice1 db 0B3h,"  1. menu item one   ",0B3h,0Dh,0Ah,'$'
choice2 db 0B3h,"  2. menu item two   ",0B3h,0Dh,0Ah,'$'
choice3 db 0B3h,"  3. menu item three ",0B3h,0Dh,0Ah,'$'
choice4 db 0B3h,"  4. menu item four  ",0B3h,0Dh,0Ah,'$'
boxBtm db  0C0h, 21 dup(0C4h), 0D9h, 0Dh, 0Ah, '$'
row = 5
col = 26
.code
main proc
	mov ax, @data ; get access to data
	mov ds, ax

	; move the cursor to item one and highlight that line
one:
	call clearscreen ; clear screen
	call makeBox  ; create box
	mov ah, 6
	mov ch, row ; upper left row
	mov cl, 6   ; upper left col
	mov dh, row ; lower right row
	mov dl, col	; lower right col
	mov bh, 21h	; green bg, blue text
	int 10h
	mov ah, 2	; set cursor position
	mov dh, 5	; row
	mov dl, 5	; col
	mov bh, 0	; video page 0
	int 10h
	mov ah, 9	; output
	mov dx, offset choice1 ; display 1st choice
	int 21h
	mov ah, 10h	; wait for keystroke
	int 16h
	cmp ah, 48h	; if up arrow, jump to 4
	je four
	cmp ah, 50h ; if down arrow, jump to 2
	je two
	jmp exit
two:
	call clearscreen ; clear screen
	call makeBox  ; create box
	mov ah, 6
	mov ch, row+1 	; upper left row
	mov cl, 6   	; upper left col
	mov dh, row+1 	; lower right row
	mov dl, col		; lower right col
	mov bh, 21h		; green bg, blue text
	int 10h
	mov ah, 2		; set cursor position
	mov dh, row+1	; row
	mov dl, 5		; col
	mov bh, 0		; video page 0
	int 10h
	mov ah, 9		; output
	mov dx, offset choice2 ; display 1st choice
	int 21h
	mov ah, 10h	; wait for keystroke
	int 16h
	cmp ah, 48h	; if up arrow, jump to 1
	je one
	cmp ah, 50h ; if down arrow, jump to 3
	je three
	jmp exit
halfToOne: jmp one
three:
	call clearscreen ; clear screen
	call makeBox  ; create box
	mov ah, 6
	mov ch, row+2 	; upper left row
	mov cl, 6   	; upper left col
	mov dh, row+2 	; lower right row
	mov dl, col		; lower right col
	mov bh, 21h		; green bg, blue text
	int 10h
	mov ah, 2		; set cursor position
	mov dh, row+2	; row
	mov dl, 5		; col
	mov bh, 0		; video page 0
	int 10h
	mov ah, 9		; output
	mov dx, offset choice3 ; display 1st choice
	int 21h
	mov ah, 10h	; wait for keystroke
	int 16h
	cmp ah, 48h	; if up arrow, jump to 2
	je two
	cmp ah, 50h ; if down arrow, jump to 4
	je four
	jmp exit
four:
	call clearscreen ; clear screen
	call makeBox  ; create box
	mov ah, 6
	mov ch, row+3 	; upper left row
	mov cl, 6   	; upper left col
	mov dh, row+3 	; lower right row
	mov dl, col		; lower right col
	mov bh, 21h		; green bg, blue text
	int 10h
	mov ah, 2		; set cursor position
	mov dh, row+3	; row
	mov dl, 5		; col
	mov bh, 0		; video page 0
	int 10h
	mov ah, 9		; output
	mov dx, offset choice4 ; display 1st choice
	int 21h
	mov ah, 10h	; wait for keystroke
	int 16h
	cmp ah, 48h	; if up arrow, jump to 3
	je three
	cmp ah, 50h ; if down arrow, jump to 1(using 1/2 step because masm said je was out of range)
	je halfToOne
	jmp exit
	; reset cursor for DOS then exit
exit:
	mov ah, 2	; set cursor position
	mov dh, 24	; row
	mov dl, 0	; col
	mov bh, 0	; video page 0
	int 10h
	mov ax, 4C00h ; return to DOS
	int 21h
main endp
clearscreen proc
	mov ah, 6	; move screen
	mov al, 0	; whole screen
	mov bh, 0	; normal mode
	mov ch, 0	; from y=0
	mov cl, 0	; from x=0
	mov dh, 24	; to y=79
	mov dl, 79	; to x=24
	int 10h
	ret
clearscreen endp

makeBox proc
	; make bg box and set colors
	mov ah, 6	; ah-scroll window up
	mov al, 0	; al-entire window
	mov ch, 4   ; ch-upper left row
	mov cl, 5   ; cl-upper left col
	mov dh, 9   ; dh-lower right row
	mov dl, 27	; dl-lower right col
	mov bh, 12h	; blue bg, green text
	int 10h
	mov ah, 2	; set cursor position
	mov dh, 5	; row 5
	mov dl, 5	; col 5
	mov bh, 0	; video page 0
	int 10h
	
	; add top
	mov ah, 2	; set cursor position
	mov dh, 4	; row 4
	mov dl, 5	; col
	mov bh, 0	; video page 0
	int 10h
	mov dx, offset boxTop ; display top of box
	mov ah, 9
	int 21h

	; add item 1
	mov ah, 2	; set cursor position
	mov dh, row	; row 5
	mov dl, 5	; col
	mov bh, 0	; video page 0
	int 10h
	mov dx, offset choice1 ; display 1st choice
	mov ah, 9
	int 21h
	
	; add item 2
	mov ah, 2		; set cursor position
	mov dh, row+1	; row 6
	mov dl, 5		; col
	mov bh, 0		; video page 0
	int 10h
	mov dx, offset choice2 ; display 2nd choice
	mov ah, 9
	int 21h
	
	; add item 3
	mov ah, 2		; set cursor position
	mov dh, row+2	; row 7
	mov dl, 5		; col
	mov bh, 0		; video page 0
	int 10h
	mov dx, offset choice3 ; display 3rd choice
	mov ah, 9
	int 21h
	
	; add item 4
	mov ah, 2		; set cursor position
	mov dh, row+3	; row 8
	mov dl, 5		; col
	mov bh, 0		; video page 0
	int 10h
	mov dx, offset choice4 ; display 4th choice
	mov ah, 9
	int 21h
	
	; add top
	mov ah, 2	; set cursor position
	mov dh, 9	; row 9
	mov dl, 5	; col 5
	mov bh, 0	; video page 0
	int 10h
	mov dx, offset boxBtm ; display bottom of box
	mov ah, 9
	int 21h
	ret
makeBox endp
end main