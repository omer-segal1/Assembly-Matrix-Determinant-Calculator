	; Omer Segal
	
	.model small
	.data
		MAT db 9, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7
		;determinant is -648
		N dw 5
		;Allocates space in memory for temporary matrices to store the minors
		tempMatrixSize2 db 4 dup (?)
		
		tempMatrixSize3 db 9 dup (?)
		
		tempMatrixSize4 db 16 dup (?)
	
		;Arrays that dictate which indices from the original matrix to copy for each case
		minor_indices_3_0 dw 4,5,7,8 ;Matrix of size 3, removing column 0
		minor_indices_3_1 dw 3,5,6,8
		minor_indices_3_2 dw 3,4,6,7
		minor_indices_4_0 dw 5,6,7,9,10,11,13,14,15     
		minor_indices_4_1 dw 4,6,7,8,10,11,12,14,15   
		minor_indices_4_2 dw 4,5,7,8,9,11,12,13,15      
		minor_indices_4_3 dw 4,5,6,8,9,10,12,13,14   
		minor_indices_5_0 dw 6,7,8,9,11,12,13,14,16,17,18,19,21,22,23,24    
		minor_indices_5_1 dw 5,7,8,9,10,12,13,14,15,17,18,19,20,22,23,24    
		minor_indices_5_2 dw 5,6,8,9,10,11,13,14,15,16,18,19,20,21,23,24      
		minor_indices_5_3 dw 5,6,7,9,10,11,12,14,15,16,17,19,20,21,22,24    
		minor_indices_5_4 dw 5,6,7,8,10,11,12,13,15,16,17,18,20,21,22,23    
	.stack 100h
	.code
	
	printDet proc ;Assume that the determinant was pushed into the stack before calling the routine.
		push ax
		push bx
		push cx
		push dx
		push bp          		; Keeping the old BP value
		mov bp, sp       		; BP points to the top of the stack
		
		mov ax, [bp+12] 		;AX holds the value of the determinan
		mov cx, 0        		; counter for the number of digits
		mov bx, 10       		; Base 10 for division

		cmp ax, 0
		jge GetDigitsLoop    	; If the number is positive, skip this part.
		
		;If the number is negative:
		push ax
		mov al, '-'      		; Prints -
		mov ah, 07h
		mov es:[di],ax
		add di, 2        		;Adds 2 to get the next position on the screen
		pop ax
		
		neg ax           		 ; Makes the number positive
		
		GetDigitsLoop:
			mov dx, 0        	 ; Set DX to 0
			div word ptr bx  	 ;Divides by 10 and stores the last digit in DX.
			push dx          	 ; Stores the digits in the stack in reverse order.
			inc cx           	 ; Count the number of digits
			add ax, 0        	 ; Checks if AX has reached 0
			jnz GetDigitsLoop    ; If not continue in loop
		
		PrintDigits:
			pop dx           	 ; Takes the last digit out of the stack and print it
			add dl, '0'
			mov al, dl
			mov ah, 07h
			mov es:[di], ax
			add di, 2 		 	;Adds 2 to get the next position on the screen
			loop PrintDigits 	;Repeats and prints all digits according to the count in CX
		pop bp
		pop dx
		pop cx
		pop bx
		pop ax
		ret 2 					;Deletes the determinant we saved from the stack.
	printDet endp
	
	getMinor proc ;Assume we pushed into the stack in this order: column number, matrix size, and the matrix address
		push ax
		push bx
		push cx
		push dx
		push si
		push di
		push bp          		; Keeping the old BP value
		mov bp, sp       		; BP points to the top of the stack
		
		mov ax, [bp+16]         ;AX contains the matrix address
		mov cx, [bp+18]			;CX contains the size of the matrix
		mov dx, [bp+20]         ;DX contains the column number to be removed
		
		;By comparing the size of the matrix, we jump to the function that matches the size of the matrix.
		cmp cx, 3
		je MinorSize3
		cmp cx, 4
		je MinorSize4
		cmp cx, 5
		je MinorSize5
		
		MinorSize3:
		mov bx, offset tempMatrixSize2 ;BX contains the address of the temporary matrix of (size 2) where we will store the minor
		mov bp, ax ;BP contains the original matrix address
		mov cx, 4  ;Sets CX to the number of copies required for the copy loop at the end of the routine.
		
		;Jumps to the section that matches the column.
		cmp dx, 0
		je Minor3column0
		cmp dx, 1
		je Minor3column1
		cmp dx, 2
		je Minor3column2
		;Stores in DI the array of indexes to copy according to the column
		Minor3column0:
		mov di, offset minor_indices_3_0
		jmp END_OF_GET_MINOR
		Minor3column1:
		mov di, offset minor_indices_3_1
		jmp END_OF_GET_MINOR
		Minor3column2:
		mov di, offset minor_indices_3_2
		jmp END_OF_GET_MINOR
		
		
		MinorSize4:
		mov bx, offset tempMatrixSize3 ;BX contains the address of the temporary matrix of (size 3) where we will store the minor
		mov bp, ax ;BP contains the original matrix address
		mov cx, 9  ;Sets CX to the number of copies required for the copy loop at the end of the routine.
		
		;Jumps to the section that matches the column.
		cmp dx, 0
		je Minor4column0
		cmp dx, 1
		je Minor4column1
		cmp dx, 2
		je Minor4column2
		cmp dx, 3
		je Minor4column3
		;Stores in DI the array of indexes to copy according to the column
		Minor4column0:
		mov di, offset minor_indices_4_0
		jmp END_OF_GET_MINOR
		Minor4column1:
		mov di, offset minor_indices_4_1
		jmp END_OF_GET_MINOR
		Minor4column2:
		mov di, offset minor_indices_4_2
		jmp END_OF_GET_MINOR
		Minor4column3:
		mov di, offset minor_indices_4_3
		jmp END_OF_GET_MINOR
		
		
		MinorSize5:
		mov bx, offset tempMatrixSize4 ;BX contains the address of the temporary matrix of (size 4) where we will store the minor
		mov bp, ax ;BP contains the original matrix address
		mov cx, 16  ;Sets CX to the number of copies required for the copy loop at the end of the routine.
		
		;Jumps to the section that matches the column.
		cmp dx, 0
		je Minor5column0
		cmp dx, 1
		je Minor5column1
		cmp dx, 2
		je Minor5column2
		cmp dx, 3
		je Minor5column3
		cmp dx, 4
		je Minor5column4
		;Stores in DI the array of indexes to copy according to the column
		Minor5column0:
		mov di, offset minor_indices_5_0
		jmp END_OF_GET_MINOR
		Minor5column1:
		mov di, offset minor_indices_5_1
		jmp END_OF_GET_MINOR
		Minor5column2:
		mov di, offset minor_indices_5_2
		jmp END_OF_GET_MINOR
		Minor5column3:
		mov di, offset minor_indices_5_3
		jmp END_OF_GET_MINOR
		Minor5column4:
		mov di, offset minor_indices_5_4
		jmp END_OF_GET_MINOR
		
		END_OF_GET_MINOR: ;DI-indexes array, BP-matrix address, BX-minor address, CX-number of copies
			mov si,[di] ;SI contain the index of the number in the original matrix we need to copy
			mov al, DS:[bp+si] ;AL contain the number we need to copy
			mov DS:[bx], al	 ;copy to the right spot in memory
			add di, 2 ;move to the next index in the array (Add 2 because it is an array of words, not bytes)
			inc bx ;move to the next place in the minor
			loop END_OF_GET_MINOR
	
		pop bp
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret 6 					;Deletes the 3 parameters (column, size and matrix) we saved from the stack.
	
	getMinor endp

	
	calc_det_size2 proc  ;Calculates determinant of size 2 and returns the value in AX
	;Assume that the address of the matrix was pushed into the stack before calling the routine.
	
		push bx 				;Saves the contents of the registers we will use
		push cx
		push dx
		
		push bp          		; Keeping the old BP value
		mov bp, sp       		; BP points to the top of the stack
		
		 
		mov bx ,[bp+10] 		;BX contains the matrix address in memory.
		
		;Adds the digits in the matrix to AL, AH, DH, DL
		mov al, [bx]     ;A->al
		mov ah, [bx+3]   ;D->ah
		mov dl, [bx+1]	 ;B->dl
		mov dh, [bx+2]	 ;C->dh
		
	
		imul ah 				;Calculates the product of the main diagonal(AD)and stores the result in CX
		mov cx, ax
		
		mov ax, dx 				;Calculates the product of the secondary diagonal (BC), the result in AX
		imul ah
		
		sub cx, ax 				;Calculate AD-BC
		mov ax, cx 				;Saves the result in AX.
		
		pop bp
		pop dx
		pop cx
		pop bx
		ret 2 					;Deletes the matrix address that we put on the stack before calling the routine
	calc_det_size2 endp
	
	
	calc_det_size3 proc  ;Calculates determinant of size 3 and returns the value in AX
	;Assume that the address of the matrix was pushed into the stack before calling the routine.
	
		push bx 				;Saves the contents of the registers we will use
		push cx
		push dx
		push si
		
		push bp          		; Keeping the old BP value
		mov bp, sp       		; BP points to the top of the stack
		
		 
		mov dx ,[bp+12] 		;DX contains the matrix address in memory.
		
	    ;calculate the 2X2 minors and keeps the determinant value in the stack (local variables)
	    mov cx, 3 ;number of iterations
		sub sp, 6  ;Saves space for storing the determinant values ​​of the minors on the stack.
		mov si, -6  ;SI Contains the offset on the stack where the determinant should be stored.

	    CALC_MINORS_SIZE_3:
	    dec cx ;CX now contains the column number that we will remove and get its minor.
	    ; pushing in this order: column number, matrix size, and the matrix address
	    push cx    ; push column
		mov bx, 3 ; BX = size of the matrix
	    push bx	   ; push matrix size
	    push dx    ; push matrix address
	    call getMinor
		mov bx, offset tempMatrixSize2 ;bx contains the minors address in memory
		push bx ;push minor address to the stack
		call calc_det_size2
		mov [bp+si], ax  ;Stores the determinants in the stack (in the local variables area)
		;The minor of column 2 is stored in [bp-6], the minor of column 1 in [bp-4], and the minor of column 0 in [bp-2].
		add si, 2
		add cx, 0
	    jnz CALC_MINORS_SIZE_3
	  
		mov bx, dx ;BX contains the matrix address in memory.
		;Calculates the determinant of the size 3 matrix
		;Multiply the elements in the first row of the matrix by the determinant of the corresponding minor.
		
	    ; Calculates the first product
	    mov ax, [bp - 2] ;AX contains the determinant of the minor in which the 0th column was removed.
	    mov dx, 0   
		mov dl, [bx] ;[BX] contains the element at index 0 in the matrix
		imul dx
	    mov cx , ax  ;We will store the product in CX.
	    
	    ; Calculates the second product (subtraction)
	    mov ax , [bp - 4] ;AX contains the determinant of the minor in which the 1th column was removed.
	    mov dx, 0   
		mov dl, [bx+1] ;[BX] contains the element at index 1 in the matrix
		imul dx
	    sub cx , ax ;Now we subtract the product from the value stored in CX.
	    
	    ; Calculates the third product
	    mov ax , [bp - 6]
	    mov dx, 0   
		mov dl, [bx+2] ;[BX] contains the element at index 2 in the matrix
		imul dx
	    add cx , ax
	    
	    mov ax, cx ;Saves the result in AX.
	    mov sp, bp ;"pop" the local variables from the stack by moving the pointer to the top of the stack
	    
		pop bp
		pop si
		pop dx
		pop cx
		pop bx
		ret 2 					;Deletes the matrix address that we put on the stack before calling the routine
	calc_det_size3 endp
	
	
	calc_det_size4 proc  ;Calculates determinant of size 4 and returns the value in AX
	;Assume that the address of the matrix was pushed into the stack before calling the routine.
	
		push bx 				;Saves the contents of the registers we will use
		push cx
		push dx
		push si
		
		push bp          		; Keeping the old BP value
		mov bp, sp       		; BP points to the top of the stack
		
		 
		mov dx ,[bp+12] 		;DX contains the matrix address in memory.
		
	    ;calculate the 3X3 minors and keeps the determinant value in the stack (local variables)
	    mov cx , 4 ;number of iterations
		sub sp, 8 ;Saves space for storing the determinant values ​​of the minors on the stack.
		mov si, -8  ;SI Contains the offset on the stack where the determinant should be stored.

	    CALC_MINORS_SIZE_4:
	    dec cx ;CX now contains the column number that we will remove and get its minor.
	    ; pushing in this order: column number, matrix size, and the matrix address
	    push cx    ; push column
		mov bx , 4 ; BX = size of the matrix
	    push bx	   ; push matrix size
	    push dx    ; push matrix address
	    call getMinor
		mov bx, offset tempMatrixSize3 ;bx contains the minors address in memory
		push bx ;push minor address to the stack
		call calc_det_size3
		mov [bp+si], ax  ;Stores the determinants in the stack (in the local variables area)
		add si, 2
		add cx, 0
	    jnz CALC_MINORS_SIZE_4
	  
		mov bx, dx ;BX contains the matrix address in memory.
		;Calculates the determinant of the original size 4 matrix.
		;Multiply the elements in the first row of the matrix by the determinant of the corresponding minor.
		
	    ; Calculates the first product
	    mov ax, [bp - 2] ;AX contains the determinant of the minor in which the 0th column was removed.
	    mov dx, 0   
		mov dl, [bx] ;[BX] contains the element at index 0 in the matrix
		imul dx
	    mov cx , ax  ;We will store the product in CX.
	    
	    ; Calculates the second product (subtraction)
	    mov ax , [bp - 4] ;AX contains the determinant of the minor in which the 1th column was removed.
	    mov dx, 0   
		mov dl, [bx+1] ;[BX] contains the element at index 1 in the matrix
		imul dx
	    sub cx , ax ;Now we subtract the product from the value stored in CX.
	    
	    ; Calculates the third product
	    mov ax , [bp - 6]
	    mov dx, 0   
		mov dl, [bx+2] ;[BX] contains the element at index 2 in the matrix
		imul dx
	    add cx , ax 
		
	    ; Calculates the forth product (subtraction)
	    mov ax , [bp - 8] ;AX contains the determinant of the minor in which the 3th column was removed.
	    mov dx, 0   
		mov dl, [bx+3] ;[BX] contains the element at index 3 in the matrix
		imul dx
	    sub cx , ax 
		
	    
	    mov ax, cx ;Saves the result in AX.
	    mov sp, bp ;"pop" the local variables from the stack by moving the pointer to the top of the stack
	    
		pop bp
		pop si
		pop dx
		pop cx
		pop bx
		ret 2 					;Deletes the matrix address that we put on the stack before calling the routine
	calc_det_size4 endp
	
	
	calc_det_size5 proc  ;Calculates determinant of size 5 and returns the value in AX
	;Assume that the address of the matrix was pushed into the stack before calling the routine.
	
		push bx 				;Saves the contents of the registers we will use
		push cx
		push dx
		push si
		
		push bp          		; Keeping the old BP value
		mov bp, sp       		; BP points to the top of the stack
		
		 
		mov dx ,[bp+12] 		;DX contains the matrix address in memory.
		
	    ;calculate the 4X4 minors and keeps the determinant value in the stack (local variables)
	    mov cx, 5 ;number of iterations
		sub sp, 10 ;Saves space for storing the determinant values ​​of the minors on the stack.
		mov si, -10 ;SI Contains the offset on the stack where the determinant should be stored.

	    CALC_MINORS_SIZE_5:
	    dec cx ;CX now contains the column number that we will remove and get its minor.
	    ; pushing in this order: column number, matrix size, and the matrix address
	    push cx    ; push column
		mov bx ,5 ; BX = size of the matrix
	    push bx	   ; push matrix size
	    push dx    ; push matrix address
	    call getMinor
		mov bx, offset tempMatrixSize4 ;bx contains the minors address in memory
		push bx ;push minor address to the stack
		call calc_det_size4
		mov [bp+si], ax  ;Stores the determinants in the stack (in the local variables area)
		add si, 2
		add cx, 0
	    jnz CALC_MINORS_SIZE_5
	  
		mov bx, dx ;BX contains the matrix address in memory.
		;Calculates the determinant of the original matrix.
		;Multiply the elements in the first row of the matrix by the determinant of the corresponding minor.
		
	    ; Calculates the first product
	    mov ax, [bp - 2] ;AX contains the determinant of the minor in which the 0th column was removed.
	    mov dx, 0   
		mov dl, [bx] ;[BX] contains the element at index 0 in the matrix
		imul dx
	    mov cx , ax  ;We will store the product in CX.
	    
	    ; Calculates the second product (subtraction)
	    mov ax , [bp - 4] ;AX contains the determinant of the minor in which the 1th column was removed.
	    mov dx, 0   
		mov dl, [bx+1] ;[BX] contains the element at index 1 in the matrix
		imul dx
	    sub cx , ax ;Now we subtract the product from the value stored in CX.
	    
	    ; Calculates the third product
	    mov ax , [bp - 6]
	    mov dx, 0   
		mov dl, [bx+2] ;[BX] contains the element at index 2 in the matrix
		imul dx
	    add cx , ax 
		
	    ; Calculates the forth product (subtraction)
	    mov ax , [bp - 8] ;AX contains the determinant of the minor in which the 3th column was removed.
	    mov dx, 0   
		mov dl, [bx+3] ;[BX] contains the element at index 3 in the matrix
		imul dx
	    sub cx , ax 
	    
	    ; Calculates the fifth product
	    mov ax , [bp - 10]
	    mov dx, 0   
		mov dl, [bx+4] ;[BX] contains the element at index 4 in the matrix
		imul dx
	    add cx , ax 
		
	    mov ax, cx ;Saves the result in AX.
	    mov sp, bp ;"pop" the local variables from the stack by moving the pointer to the top of the stack
	    
		pop bp
		pop si
		pop dx
		pop cx
		pop bx
		ret 2 					;Deletes the matrix address that we put on the stack before calling the routine
	calc_det_size5 endp
	
	
	
	CALC_DAT proc
	    push bx
	    mov bx , N
	    
	    mov ax, offset MAT
	    push ax
	    
	    cmp bx ,2
	    je SIZE_2
	    
	    cmp bx ,3
	    je SIZE_3
	    
	    cmp bx ,4
	    je SIZE_4
	    
	    cmp bx ,5
	    je SIZE_5
	    
	    SIZE_2:
	    call calc_det_size2
	    jmp END_OF_CALC
	    
	    SIZE_3:
	    call calc_det_size3
	    jmp END_OF_CALC
	       
	    SIZE_4:
	    call calc_det_size4
	    jmp END_OF_CALC
	      
	    SIZE_5:	
	    call calc_det_size5
	    
	    
	    END_OF_CALC:
	    pop bx
	    ret
	CALC_DAT endp    
	
	START:
	
		;setting data segment
		mov ax, @data
		mov ds, ax
		;setting extra segment to screen mem
		mov ax,0b800h 
		mov es, ax 
		mov di, 320
		
		call CALC_DAT

		push ax
		call printDet
	

		;return to OS
		mov ax, 4c00h
		int 21h
	End START

