# Assembly Matrix Determinant Calculator

This project implements a determinant calculator for square matrices (2 ≤ N ≤ 5) in **x86 Assembly**.  
The program computes the determinant using **recursive minor expansion** and supports signed 16-bit integer values.

## Visualization (3x3 Example)

This is a simple visualization of a 3x3 matrix and its determinant calculation:

![Matrix Determinant](matrix_recursive_alg.avif)

## Features
- Supports matrix sizes from 2x2 up to 5x5
- Recursive calculation via **Laplace expansion**
- Uses signed 16-bit words for storage
- Separate procedures:
  - `calcDet` → main determinant calculation
  - `getMinor` → builds the (N-1)x(N-1) minor matrix
  - `printDet` → outputs the final result

## How to Run
1. Open **DOSBox** or a **FreeDOS** environment.
2. Assemble and link with:
   ```bash
   ml /Zm matrix.asm
3. Run the program by typing:  
   ```
   matrix.exe
   ```
   
## Code Example

Here is a snippet from the `calcDet` procedure, showing the recursive 
Laplace expansion used to calculate the determinant:

```asm
calcDet proc near
    cmp N, 2             ; Base case: 2x2 matrix
    jne RECURSIVE_CASE
    ; det = ad - bc
    mov ax, MAT[0]
    imul MAT[3]
    mov bx, ax
    mov ax, MAT[1]
    imul MAT[2]
    sub bx, ax
    mov det, bx
    ret

RECURSIVE_CASE:
    ; General case: expand along first row
    mov cx, N            ; Loop over columns
    mov si, 0
    mov det, 0

LOOP_COLS:
    push cx
    mov ax, MAT[si]      ; Get A[0][j]
    call getMinor        ; Build minor matrix
    call calcDet         ; Recursive call
    imul ax, sign        ; Apply sign (-1)^j
    imul ax, MAT[si]     ; Multiply by element
    add det, ax
    pop cx

    inc si
    loop LOOP_COLS

    ret
calcDet endp
