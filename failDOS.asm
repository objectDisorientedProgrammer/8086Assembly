; FailDOS
; created April 27, 2012
; finished [4/29/12]
; by Douglas Chidester
; 
; This program simulates a GUI for DOS
;
; write a string to the screen ============================
printm macro string
	mov ah, 09h
	mov dx, offset string
	int 21h
	endm
; move the cursor to row r, column c ======================
cursor macro row, col
	mov ah, 02
	mov bh, 00
	mov dh, row
	mov dl, col
	int 10h
	endm
; draw a box ==============================================
drawRect macro startRow, startCol, endRow, endCol, color
	local outterLoop, innerLoop
	mov dx, startRow
outterLoop:
	mov cx, startCol
innerLoop:
	mov ah, 0Ch
	mov al, color		; set color
	int 10h
	inc cx
	cmp cx, endCol		; check if end of row
	jne innerLoop
	inc dx
	cmp dx, endRow 		; check for more rows
	jne outterLoop
	endm
;==========================================================
;===================== Main Program =======================
;==========================================================
.model small
.stack 100h

.data
tickCount dw 00
lowCount dw 00
highCount dw 00
oldVidMode db ?
newVidMode db 13h	; 320 x 200 px 256 color, graph, 1 page
screenXmax = 200
screenYmax = 320
month db "May $"
day db "2,$"
year db "2012$"
titleMsg db "FailDOS GUI simulator$"
credits db "Created by Douglas Chidester$"
quitMsg db "Press ESC or 'q' to exit...$"
continueMsg db "press the any key to boot$"
startupMsg db "FailDOS is setting up$"
loadingMsg1 db "loading$"
loadingMsg2 db "loading . $"
loadingMsg3 db "loading . . $"
loadingMsg4 db "loading . . .$"
endBtnTxt db "end$"
programs db "programs$"
pong db "pong$"
shutdown db "shutdown$"
bosdMsg1 db "FailDOS has encountered an unexpected$"
bosdMsg2 db "error. Please contact your system$"
bosdMsg3 db "administrator to resolve this issue.$"
bosdMsg4 db "You must be root to shutdown.$"
bosdMsg5 db "Try: 'sudo shutdown' from the terminal.$"

mouseX dw ?
mouseY dw ?
.code
main proc
	mov ax, @data
	mov ds, ax				; load data
	
	mov ah, 0Fh
	int 10h
	mov oldVidMode, al		; save old video mode
	
	mov ah, 00
	mov al, newVidMode		; set new video mode
	int 10h
	
	cursor 4, 7
	printm titleMsg
	cursor 6, 5
	printm credits
	cursor 10, 6
	printm quitMsg			; tell user how to exit
	mov tickCount, 36		; 2 sec delay
	call delay
	cursor 15, 8
	printm continueMsg
	
	mov ah, 10h				; wait for key
	int 16h
	cmp al, 1Bh				; check for esc and q
	je exit1
	cmp al, 71h
	je exit1
	
	drawRect 0, 0, screenXmax, screenYmax, 0h ; clear entire screen
	call loadingScreen
	mov ax, 0				; initialize mouse
	int 33h
	mov ax, 01				; show cursor
	int 33h
	drawRect 0, 0, screenXmax, screenYmax, 0h ; clear entire screen
redrawDesktop:
	call showDesktop
mainLoop:
	mov ax, 03h				; get mouse status
	int 33h
	
	cmp bx, 0001h			; check for mouse click
	je leftClick
checkKey:
	mov ah, 11h				; check for key press
	int 16h					; key is in AL
	
	cmp al, 1Bh				; check ESC key
	je exit1
	cmp al, 71h				; check 'q'
	je exit1
	jmp mainLoop
exit1:
	jmp exit
leftClick:
	;check if click on bottom of screen (end button)
	cmp dx, 173
	jge checkEndButton
	jmp checkKey
checkEndButton:
	;if click isnt in end button, dont draw menu
	cmp cx, 80
	ja checkKey
	; if it is, display menu
	call endBtnMenu
	mov tickCount, 18		; 1 sec delay
	call delay
	mov ax, 03h				; get mouse status
	int 33h

	; check if mouse is in the menu box
	cmp dx, 55
	jb redrawDesktop1
	cmp dx, 173
	jge redrawDesktop1
	cmp cx, 160
	ja redrawDesktop1
	
	jmp checkMenuItemClick
redrawDesktop1:
	jmp redrawDesktop
; mouse is inside menu
checkMenuItemClick:
	mov ax, 03h				; get mouse status
	int 33h
	cmp bx, 0001h
	je checkWhichItem		; check for click on programs
	
	jmp checkMenuItemClick
checkWhichItem:
	; check if mouse is still in the menu box
	cmp cx, 160
	ja redrawDesktop1
	cmp dx, 55
	jb redrawDesktop1
	cmp dx, 173
	jge redrawDesktop1
	cmp dx, 85				; check for click in "programs"
	jb programsClicked
	cmp dx, 130				; check for click in "pong"
	jb pongClicked
	cmp dx, 130				; check for click in "shutdown"
	ja shutdownClicked
	jmp redrawDesktop1
programsClicked:
	call programsWindow
	jmp mainLoop
pongClicked:
	call pongWindow
	jmp mainLoop
shutdownClicked:
	call shutdownWindow
	mov tickCount, 180		; delay 10 sec
	call delay
	jmp exit

exit:
	mov ax, 2				; hide the mouse
	int 33h
	mov ah, 00
	mov al, oldVidMode		; restore old video mode
	int 10h
	
	mov ah, 4Ch				; return to DOS
	int 21h
main endp
; This procedure is used for animation delay
delay proc
	mov ah, 0h
	int 1Ah
	add dx, tickCount
	add cx, tickCount
	mov lowCount, dx
	mov highCount, cx
cont:
	mov ah, 0h
	int 1Ah
	cmp dx, lowCount
	je done
	cmp cx, highCount
	je done
	jmp cont
done:
	ret
delay endp
; This is the loading screen
loadingScreen proc
	cursor 7, 7
	printm startupMsg
	mov tickCount, 27	; 1.5 sec delay
	call delay
	cursor 13, 10
	printm loadingMsg1
	mov tickCount, 18	; 1 sec delay
	call delay
	drawRect 100, 0, 180, screenYmax, 0h ; clear bottom of screen
	mov cx, 4
loadingLoop:
	push cx
	call loadingAnimation
	pop cx
	loop loadingLoop
	ret
loadingScreen endp
; This is the ". . ." animation
loadingAnimation proc
	drawRect 100, 0, screenXmax, screenYmax, 0h ; clear loading msg
	
	cursor 13, 10
	printm loadingMsg2
	mov tickCount, 18	; 1 sec delay
	call delay
	drawRect 100, 0, 180, screenYmax, 0h ; clear loading msg
	
	cursor 13, 10
	printm loadingMsg3
	mov tickCount, 18	; 1 sec delay
	call delay
	drawRect 100, 0, 180, screenYmax, 0h ; clear loading msg

	cursor 13, 10
	printm loadingMsg4
	mov tickCount, 18	; 1 sec delay
	call delay
	drawRect 100, 0, 180, screenYmax, 0h ; clear loading msg
	ret
loadingAnimation endp
; Draw the desktop and all its glory
showDesktop proc
	mov tickCount, 1	; 55 ms delay
	call delay
	; Draw desktop, startbar, startbutton, icons
	drawRect 0, 0, screenXmax, screenYmax, 00000011b	; desktop background
	drawRect 175, 0, screenXmax, screenYmax, 07h		; start bar
	drawRect 173, 0 175, screenYmax, 00001011b			; separator line
	drawRect 175, 0, screenXmax, 40, 0Fh				; start button
	drawRect 10, 270, 15, 300, 2Ah						; recycle bin icon
	drawRect 15, 275, 35, 295, 2Ah
	drawRect 40, 270, 58, 300, 07h						; computer icon
	drawRect 42, 273, 56, 297, 01h
	drawRect 56, 265, 64, 305, 07h
	cursor 23, 1
	printm endBtnTxt
	cursor 23, 68
	printm month
	cursor 23, 72
	printm day
	cursor 23, 74
	printm year
	ret
showDesktop endp
; Create the end button menu
endBtnMenu proc
	drawRect 55, 0, 173, 80, 0Fh
	drawRect 60, 5, 170, 75, 00h
	cursor 9, 1
	printm programs
	cursor 14, 2
	printm pong
	cursor 19, 1
	printm shutdown
	ret
endBtnMenu endp
; Displays installed programs
programsWindow proc
	call showDesktop					; redraw the desktop
	drawRect 20, 60, 140, 260, 0Fh		; create a programs window
	drawRect 25, 65, 135, 255, 00h
	drawRect 30, 70, 48, 100, 07h		; computer icon
	drawRect 32, 73, 46, 97, 01h
	drawRect 46, 66, 54, 104, 07h
	drawRect 30, 115, 35, 145, 2Ah		; recycle bin icon
	drawRect 35, 120, 55, 140, 2Ah
	drawRect 30, 155, 55, 160, 04h		; pong icon
	drawRect 43, 160, 46, 163, 0Fh
	drawRect 30, 175, 55, 180, 0Ah
	ret
programsWindow endp
; Pong
pongWindow proc
	call showDesktop					; redraw the desktop
	drawRect 20, 60, 140, 260, 0Fh		; create a window
	drawRect 25, 65, 135, 255, 00h
	drawRect 30, 70, 75, 75, 04h		; red player
	drawRect 30, 245, 75, 250, 0Ah		; green player
	drawRect 25, 159, 135, 161, 07h		; seperator bar
	drawRect 30, 150, 40, 155, 07h		; red score
	drawRect 31, 151, 39, 154, 00h
	drawRect 30, 165, 40, 170, 07h		; green score
	drawRect 31, 166, 39, 169, 00h
	drawRect 75, 150, 78, 153, 0Fh		; ball
	ret
pongWindow endp
; Blue screen of death
shutdownWindow proc
	drawRect 0, 0, screenXmax, screenYmax, 01h
	cursor 1, 1
	printm bosdMsg1
	cursor 3, 1
	printm bosdMsg2
	cursor 5, 1
	printm bosdMsg3
	cursor 14, 1
	printm bosdMsg4
	cursor 16, 1
	printm bosdMsg5
	ret
shutdownWindow endp
end main