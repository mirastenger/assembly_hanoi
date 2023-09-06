section 	.data

extern printByteArray
extern getByteArray
extern printEndl
extern exitNormal
extern printRAX

fancy		db "*****************************  "
openingMsg	db "Welcome to Towers of Hanoi     "
diskPrompt	db "How many disks would you like?:"
diskError		db "Please select a number 2-5     "
errorMsg		db "Invalid move. Please try again "
inErrorMsg	db "Invalid input. Please try again"
movePrompt	db "Please enter your move:"
repeatMsg	db "Disk already there! Try again  "
moveCounter    db "Moves: "
line			db "====="
label			db "A B C"
diskInput0        db "  "
diskInput 		db " "
moveDisk		db " "
movePos0		db "  "
movePosition	db " "
print_		db " "
space		db " "
winMsg		db "Congratulations! You have won! "
minYayMsg	db "And you used the minimum number of moves!            "
minBooMsg	db "However, you did not use the minimum number of moves."
closingMsg	db "Play again soon!               "

printSize 		db 1
printSize2 	db 2
lineLen  		db 5
moveLen		db 7
dPromptSize 	db 31
mPromptSize 	db 23
minMsgSize	db 53

Array:  ;to be printed
        db '1', ' ', ' '
	db '2', ' ', ' '
	db '3', ' ', ' '
	db '4', ' ', ' '
	db '5', ' ', ' '
	
MoveArray: ;keeps track of each disk's position 
        db 0, 0, 0, 0, 0
	
ValidArray: ;valid user inputs
	db '2', '3', '4', '5'
	db '1', '2', '3', '4', '5'
	db 'A', 'B', 'C'
	db 'a', 'b', 'c'
	
MinArray: ;minimum number of moves for each disk amount
	db 3, 7, 15, 31

section		.bss
section		.text


global _start ;function declarations
global move
global print

 ;##########
;       MOVE
;##########
move:

 push rbp
 mov  rbp, rsp
 push rax
 push rbx
 push rcx
 push r8
 push r9
 push r10
 push r11
 push r12
 
	mov rcx, 3
	lowercaseLoop: ;if lowercase input, change to uppercase
		mov al, byte[movePosition]
		cmp al, byte[ValidArray + rcx+11]
		je changeUppercase
	loop lowercaseLoop
	jmp noCaseChange
	
	changeUppercase:
	sub rax, 32
	mov byte[movePosition], al
	
	noCaseChange:
	mov rcx, 5
	MoveDiskValidLoop: ;if disk number not valid
		mov al, byte[moveDisk]
		cmp al, byte[ValidArray + rcx+3]
		je moveDiskValidCont
	loop MoveDiskValidLoop
	
	inError:
	mov dl, byte [dPromptSize] 
	mov rsi, inErrorMsg          
	call printByteArray
	call printEndl
	jmp doneMove
	
	moveDiskValidCont:
	mov rcx, 3
	MovePosValidLoop: ;if position letter not valid
		mov al, byte[movePosition]
		cmp al, byte[ValidArray + rcx+8]
		je movePosValidCont
	loop MovePosValidLoop
	jmp inError
	
	movePosValidCont:
	mov al, byte[diskInput] ;if disk number is greater than disks
	cmp al, byte[moveDisk]
	jl inError

	mov al, byte[moveDisk] 
	sub rax, 49 ; rax contains which disk to move
	mov bl, byte[movePosition] 
	sub rbx, 65 ; rbx contains which column to move to
	mov r8b, byte[moveDisk] ; r8 contains what to print
 
	cmp bl, byte[MoveArray + rax]
	je repeatMove
	
	cmp rax, 0
	je doneCheck
	
	mov rcx, rax
	mov r9, rax
	mov r12b, byte[MoveArray + rax]
	preMoveCheck1: ;error if trying to move a disk while others are on top of it
		dec r9
		cmp r12b, byte[MoveArray + r9]
		je error
	loop preMoveCheck1
 
	mov rcx, rax
	mov r9, rax
	preMoveCheck2: ;error if trying to move a disk while others are on top of it
		dec r9
		cmp bl, byte[MoveArray + r9]
		je error
	loop preMoveCheck2
	
        doneCheck: 
	mov r10b, byte[MoveArray + rax] ;r10 contains last disk position
	mov byte[MoveArray + rax], bl ;MoveArray has been updated

	xor r11, r11 ;move ' ' to old array element
	mov r11, rax
	imul r11, 3
	add r11, r10
	mov byte[Array + r11], ' '
 
	xor r11, r11 ;move disk number to new array element
	mov r11, rax
	imul r11, 3
	add r11, rbx
	mov byte[Array + r11], r8b
	
	inc r15 ; keep track of valid moves played
	jmp doneMove
 
	error:
		mov dl, byte [dPromptSize] 
		mov rsi, errorMsg          
		call printByteArray
		call printEndl
		jmp doneMove
		
	repeatMove:
	mov dl, byte [dPromptSize]
	mov rsi, repeatMsg          
	call printByteArray
	call printEndl
		
	doneMove:
 
 pop r12
 pop r11
 pop r10
 pop r9
 pop r8
 pop rcx
 pop rbx
 pop rax
 pop rbp
 ret
 
;##########
;       PRINT
;##########
print:

 push rbp
 mov  rbp, rsp
 push rax
 push rbx
 push r8
 push r9
 
	mov bl, byte[diskInput]
	sub rbx, 48
	mov r8, 0
	printLoop: ;prints the specified number of rows from the array
		mov r9, 0
		rowLoop: ;prints each element in a given row
			mov rax, r8
			imul rax, 3
			add rax, r9
			mov  al, byte[Array + rax]
			mov byte [print_], al    
			mov dl, byte [printSize]  
			mov rsi, print_          
			call printByteArray 
			mov rsi, space          
			call printByteArray
			inc r9
			cmp r9, 3
			jl rowLoop
		call printEndl
		inc r8
		cmp r8, rbx
		jl printLoop
	mov dl, byte [lineLen]  
	mov rsi, line          
	call printByteArray 
	call printEndl
	mov rsi, label  
	call printByteArray
	call printEndl
	call printEndl

 pop r9
 pop r8
 pop rbx
 pop rax
 pop rbp
 ret
 
 
;####################
;####################
;
;                   START
;
;####################
;####################
_start:

;##########
;       SETUP
;##########
	mov r15, 0

	mov dl, byte [dPromptSize] 
	mov rsi, fancy          
	call printByteArray 
	call printEndl
	mov rsi, openingMsg          
	call printByteArray 
	call printEndl
	mov rsi, fancy          
	call printByteArray 
	call printEndl

diskNumInput:
	mov dl, byte [dPromptSize] ;asks for number of disks 
	mov rsi, diskPrompt          
	call printByteArray 
	mov dl, byte [printSize2] ;collects user input  
	mov rsi, diskInput0
	call getByteArray
	call printEndl
	mov al, byte[diskInput0]
	
	mov rcx, 4
	diskValidLoop:
		cmp al, byte[ValidArray + rcx-1]
		je diskValidCont
	loop diskValidLoop
	
	mov dl, byte [dPromptSize] 
	mov rsi, diskError          
	call printByteArray
	call printEndl
	jmp diskNumInput
	
	diskValidCont:
	mov byte[diskInput], al
	
	call print

;##########
;       INPUT
;##########
turnBegin:
	mov dl, byte [mPromptSize] ;asks for move input
	mov rsi, movePrompt          
	call printByteArray 

	mov dl, byte [printSize] ;collects user input  
	mov rsi, moveDisk
	call getByteArray
	mov dl, byte [printSize2] 
	mov rsi, movePos0
	call getByteArray
	call printEndl
	mov al, byte[movePos0]
	mov byte[movePosition], al

;##########
;       GAME
;##########
	call move
	mov dl, byte [moveLen] 
	mov rsi, moveCounter          
	call printByteArray
	mov rax, r15
	call printRAX
	call printEndl
	xor rax, rax
	call print
	
	mov r8b, byte[diskInput] ;check for a winning position
	sub r8, 49 ;r8 contains number of disks
	mov r9b, byte[MoveArray + r8] ;r9 contains highest disk position
	cmp r9, 2
	jne turnBegin
	mov rcx, r8
	winCheckLoop: ;compare positions of all disks
		dec r8
		cmp r9b, byte[MoveArray + r8]
		jne turnBegin
	loop winCheckLoop
	
;##########
;     VICTORY
;##########
winnerWinnerChickenDinner:
	mov dl, byte [dPromptSize] 
	mov rsi, winMsg          
	call printByteArray
	call printEndl
	
	mov dl, byte [minMsgSize] 
	mov r8b, byte[diskInput] ;check if minimum move number was made
	sub r8, 50 
	mov r9b, byte[MinArray + r8] ;r9 contains the appropriate min move number
	cmp r9, r15
	je minYay
	jne minBoo
	
	minYay:
	mov rsi, minYayMsg          
	call printByteArray
	call printEndl
	jmp gameOver
	
	minBoo:
	mov rsi, minBooMsg          
	call printByteArray
	call printEndl
	
gameOver:
	mov dl, byte [dPromptSize] 
	mov rsi, fancy          
	call printByteArray 
	call printEndl
	mov rsi, closingMsg          
	call printByteArray 
	call printEndl
	mov rsi, fancy          
	call printByteArray 
	call printEndl

call    exitNormal