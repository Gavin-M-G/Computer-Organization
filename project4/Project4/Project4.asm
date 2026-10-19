.ORIG x3000

;==================== MAIN ====================
; This is for the block of code;
; int array[] = {2,3,5,0,1};  int total;
; total = sumOfSquares(array, arraySize);
; 
; Main here sets up the stack, puts the array on the stack, hands 
; information to sumOfSquares, and collects the result.  The sumOfSquares 
; function is called with a pointer to the array and the size of the array. 
; The sumOfSquares function returns the sum of squares of the array elements.
;==============================================
MAIN
    LD   R6, EMPTYSTACK     ; initializes the stack pointer

    AND  R0, R0, #0         ; clears r0 and sets it to 0
    ADD  R0, R0, #1         ; sets r0 to 1
    ADD  R6, R6, #-1        ; moves the stack pointer down one slot
    STR  R0, R6, #0         ; mem[R6] = 1 (array[4] = 1)

    AND  R0, R0, #0         ; R0 = 0. this is the value for array[3]
    ADD  R6, R6, #-1        ; makes room for array[3] on the stack. (R6 points to array[3])
    STR  R0, R6, #0         ; mem[R6] = 0 (array[3] = 0)

    ADD  R0, R0, #5         ; sets r0 to 5 (array[2] = 5)
    ADD  R6, R6, #-1        ; makes room for array[2] on the stack. (R6 points to array[2])
    STR  R0, R6, #0         ; mem[R6] = 5 (array[2] = 5)

    ADD  R0, R0, #-2        ; sets r0 to 3 (array[1] = 3)
    ADD  R6, R6, #-1        ; makes room for array[1] on the stack. (R6 points to array[1])
    STR  R0, R6, #0         ; mem[R6] = 3 (array[1] = 3)

    ADD  R0, R0, #-1        ; sets r0 to 2 (array[0] = 2)
    ADD  R6, R6, #-1        ; makes room for array[0] on the stack. (R6 points to array[0])
    STR  R0, R6, #0         ; mem[R6] = 2 (array[0] = 2)

    ADD  R6, R6, #-1        ; reserve a slot for the total, which will be returned from sumOfSquares

    LD   R0, ARRAYSIZE      ; R0 = arraySize which is 5
    ADD  R6, R6, #-1        ; makes room for arraySize on the stack
    STR  R0, R6, #0         ; pushes arraySize onto the stack (R6 points to arraySize)

    ADD  R0, R6, #2         ; R0 points to the start of the array (array[0]) skipping over the total and arraySize on the stack
    ADD  R6, R6, #-1        ; makes room for the pointer to the array on the stack
    STR  R0, R6, #0         ; pushes the pointer to the array onto the stack (R6 points to the pointer to the array)

    JSR  SUMOFSQUARES       ; r7 = address of the next instruction (the return address). PC = address of sumOfSquares. SUMOFSQUARES saves r7 on the stack itself.

    LDR  R0, R6, #0         ; R0 = result from sumOfSquares
    ADD  R6, R6, #3         ; pops 3 words off the stack (the return value slot, the pointer to the array, and arraySize). R6 now points to the total slot
    STR  R0, R6, #0         ; total = result (39)

    HALT
;==================== SUMOFSQUARES ====================
; This is for the block of code;
;  int sumOfSquares(int a[], int arraySize) {
;         int counter = 0; int sum = 0;
;         while (counter < arraySize) {
;             sum = square(a[counter]) + sum;
;             counter = counter + 1;
;         }
;         return sum;
;     }
; this saves the return address and the registers R5 and R7 on the stack and 
; makes room for the local variables, counter and sum and sets them to 0. 
; it loops while counter is less than arraySize, calling square on each 
; element of the array and adding the result to sum.  It returns sum.
;======================================================
SUMOFSQUARES
    ADD  R6, R6, #-1                ; reserve the retern value slot on the stack
    ADD  R6, R6, #-1                ; reserves a slot for the return address on the stack
    STR  R7, R6, #0                 ; saves r7 beccause calling square will overwrite it
    ADD  R6, R6, #-1                ; makes room for r5 on the stack
    STR  R5, R6, #0                 ; saves MAIN's r5 so it can be restored before returning to MAIN
    ADD  R5, R6, #-1                ; r5 = R6 - 1, points to the first local variable (counter)
    ADD  R6, R6, #-2                ; allocate 2 local variables on the stack (counter and sum)

    AND  R0, R0, #0                 ; r0 = 0
    STR  R0, R5, #0                 ; counter = 0 (R5 points to counter)
    STR  R0, R5, #-1                ; sum = 0 (R5 points to sum)

LOOP
    LDR  R0, R5, #0                 ; r0 = counter
    LDR  R1, R5, #5                 ; r1 = arraySize
    NOT  R1, R1                     ; r1 = ~arraySize
    ADD  R1, R1, #1                 ; r1 = -arraySize (two's complement)
    ADD  R0, R0, R1                 ; r0 = counter - arraySize.
    BRzp ENDLOOP                    ; if counter - arraySize >= 0, then counter >= arraySize, so exit the loop 

    LDR  R0, R5, #4                 ; r0 = pointer to the array
    LDR  R1, R5, #0                 ; r1 = counter
    ADD  R0, R0, R1                 ; R0 = pointer to the array + counter, which is the address of a[counter]
    LDR  R0, R0, #0                 ; R0 = mem[a + counter], which is a[counter]
    ADD  R6, R6, #-1                ; makes room for the argument to square on the stack (R6 points to the argument)
    STR  R0, R6, #0                 ; push argument x for square(x)

    JSR  SQUARE                     ; r7 = address of the ldr below, jump to square

    LDR  R0, R6, #0                 ; r0 = return value from square
    ADD  R6, R6, #2                 ; pops the argument and the return value off the stack (R6 points to sum)

    LDR  R1, R5, #-1                ; r1 = current sum
    ADD  R1, R0, R1                 ; r1 = square(a[counter]) + sum
    STR  R1, R5, #-1                ; sum = r1 (store 

    LDR  R0, R5, #0                 ; r0 = counter 
    ADD  R0, R0, #1                 ; r0 = square result + sum
    STR  R0, R5, #0                 ; counter = r0 (store counter + 1)

    BRnzp LOOP                      ; unconditionally branch to the top of the loop

ENDLOOP                             ; the loop has finished. counter >= arraySize, so return sum
    LDR  R0, R5, #-1                ; r0 = sum (39 for the example array)
    STR  R0, R5, #3                 ; write sum into the return value slot on the stack (R5 points to sum)

    ADD  R6, R5, #1                 ; r6 = r5 + 1 = x3FF5. this discards the local variables
    LDR  R5, R6, #0                 ; restore MAIN's r5 from the stack
    ADD  R6, R6, #1                 ; POP the return address off the stack
    LDR  R7, R6, #0                 ; restore r7 = return address to MAIN
    ADD  R6, R6, #1                 ; pop  the return value off the stack (R6 points to the return value slot)
    RET                             ; jump to r7, which is the return address to MAIN
;==================== SQUARE ====================
; This is for the block of code;
;     int square(int x) {
;         int product = 0;
;         product = x * x;
;         return product;
;     }
; On entry the stack has one argument:  x at the top (R6 points at it).
; LC-3 has NO multiply instruction, so x*x is computed like this: 
; 5*5 = 5+5+5+5+5 = 25.
;================================================
SQUARE
    ADD  R6, R6, #-1                 ; reserve the return value slot on the stack
    ADD  R6, R6, #-1                 ; reserve the return address slot on the stack
    STR  R7, R6, #0                  ; save r7 (return address) on the stack
    ADD  R6, R6, #-1                 ; makes room for r5(old frame pointer) on the stack
    STR  R5, R6, #0                  ; save SUMOFSQUARES's r5 on the stack
    ADD  R5, R6, #-1                 ; r5 = location of the local variable 'product'(R5 points to product)
    ADD  R6, R6, #-1                 ; allocate 1 local. r6 = r5 now

    AND  R0, R0, #0                  ; r0 = 0 (this register will hold the product)
    STR  R0, R5, #0                  ; product = 0 (R5 points to product)

    LDR  R1, R5, #4                  ; r1 = x (the argument to square)
    ADD  R3, R1, #0                  ; r3 = x (this register will hold the counter for the loop)
    BRnz MULDONE                     ; if x <= 0, then skip the loop and return product = 0
MULLOOP                              ; 
    ADD  R0, R0, R1                  ; r0 = r0 + x (running total of the product)
    ADD  R3, R3, #-1                 ; counter-- (how many additions are left)
    BRp  MULLOOP                     ; if counter still > 0, add x to the product again
MULDONE
    STR  R0, R5, #0                  ; product = r0 (x*x)

    LDR  R0, R5, #0                  ; r0 = product (return value)
    STR  R0, R5, #3                  ; write into the return value slot on the stack (R5 + 3)

    ADD  R6, R5, #1                  ; r6 = r5 + 1: discard the local variable 'roduct'
    LDR  R5, R6, #0                  ; restore SUMOFSQUARES's r5 from the stack
    ADD  R6, R6, #1                  ; pop the return address off the stack. r6 points to saved r7
    LDR  R7, R6, #0                  ; restore the return address
    ADD  R6, R6, #1                  ; pop the return value off the stack. r6 points to the return value slot
    RET                              ; jump back into SUMOFSQUARES, which will return to MAIN
;==================== DATA ====================
EMPTYSTACK  .FILL x4000          ; stack starts here and grows downward
ARRAYSIZE  .FILL #5             ; global int arraySize = 5

        .END
