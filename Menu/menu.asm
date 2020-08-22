; Assignment #7 - Conditional Processing
; created March 5, 2012 by Douglas Chidester. Finished [3/7/12]
; 
;
; MIT License
; 
; Copyright (c) 2012 Douglas Chidester
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.


; write a string to the screen ============================
printm MACRO string
	mov ah, 09h
	mov dx, offset string
	int 21h
ENDM

; position the cursor          ============================
setCursorPosition MACRO rowm, colm, videoPage
	mov ah, 2         ; set cursor position
	mov dh, rowm      ; row
	mov dl, colm      ; col
	mov bh, videoPage ; video page
	int 10h
ENDM

addLineItem MACRO rowm, colm, text, videoPage
	push ax ; save registers
	push bx
	push dx
	setCursorPosition rowm, colm, videoPage
	printm text
	pop dx ; restore registers
	pop bx
	pop ax
ENDM

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
boxStartRow = 4
boxStartCol = 5
defaultVideoPage = 0

.code
main proc
	mov ax, @data ; get access to data
	mov ds, ax

	; move the cursor to item one and highlight that line
one:
	call clearscreen ; clear screen
	call makeBox     ; create box
	call highlight   ; invert colors

	setCursorPosition row, boxStartCol, 0

	printm choice1

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
	
exit: ; reset cursor for DOS then exit
	call clearscreen
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
	setCursorPosition boxStartRow, boxStartCol, defaultVideoPage

	; add menu items
	mov cl, boxStartRow
	
	; add top
	addLineItem cl, boxStartCol, boxTop, defaultVideoPage

	; add item 1
	inc cl
	addLineItem cl, boxStartCol, choice1, defaultVideoPage
	
	; add item 2
	inc cl
	addLineItem cl, boxStartCol, choice2, defaultVideoPage
	
	; add item 3
	inc cl
	addLineItem cl, boxStartCol, choice3, defaultVideoPage

	; add item 4
	inc cl
	addLineItem cl, boxStartCol, choice4, defaultVideoPage
	
	; add bottom
	inc cl
	addLineItem cl, boxStartCol, boxBtm, defaultVideoPage
	
	ret
makeBox endp

highlight proc
	mov ah, 6
	mov ch, row ; upper left row
	mov cl, 6   ; upper left col
	mov dh, row ; lower right row
	mov dl, col	; lower right col
	mov bh, 21h	; green bg, blue text
	int 10h
highlight endp

end main
