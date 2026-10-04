;================================================================
; Author: Gavin Mefford-Gibbins
; Date: 9/30/2026
; Class: CEG 3310
; This is a program that is supposed to meed these requirememts:
; GETNUM  - Captures a positive two digit (0 - 99) number from the keyboard
; GETOP   - Captures an operation from the keyboard (+, -, or *)
; CALC    - Calculates the correct mathematical result when provided two
;           positive two-digit numbers and an operation
; DISPLAY - Displays up to a 4-digit positive or negative number
;================================================================

; GETNUM : out R0 = number
; GETOP : out R0 = operator (ASCII)
; CALC    : in R0, R1 = numbers, R2 = operator; out R0 = result
; DISPLAY : in R0 = signed value

.ORIG x3000

START
    LEA R0, PROMPT1           ; R0 = address of the prompt text
    PUTS                      ; prints the string that starts at the address in R0
    JSR GETNUM                ; jump to GETNUM, the number typed comes back in R0
    ST  R0, NUM1              ; save it in memory because R0 is about to be reused

    LEA R0, PROMPT_OP
    PUTS
    JSR GETOP                 ; the operator's ASCII code comes back in R0
    ST  R0, OPERATOR

    LEA R0, PROMPT2
    PUTS
    JSR GETNUM
    ST  R0, NUM2

    LD  R0, NUM1              ; load the saved values into the registers CALC expects
    LD  R1, NUM2              ; R1 = second number
    LD  R2, OPERATOR          ; R2 = operator (ASCII)
    JSR CALC                  ; the result comes back in R0
    ST  R0, RESULT            ; save it because R0 is about to be reused for the message

    LEA R0, RESULT_MSG
    PUTS                      ; prints "Result: "
    LD  R0, RESULT            ; LEA overwrote R0, so load the result back in for DISPLAY
    JSR DISPLAY
    LD  R0, MAIN_NL           ; R0 = newline character, DISPLAY doesn't print one
    OUT                       ; move the cursor to the next line

    BR  START                 ; always jump back to the top so it loops forever

NUM1        .FILL #0          ; spots in memory to hold the numbers, operator, and result
NUM2        .FILL #0
OPERATOR    .FILL #0
RESULT      .FILL #0
MAIN_NL     .FILL x000A       ; newline character (10)
PROMPT1     .STRINGZ "Enter first number (0 - 99): "   ; text stored one character per spot, ends with a 0 so PUTS knows where to stop
PROMPT_OP   .STRINGZ "Enter an operation (+, -, *): "
PROMPT2     .STRINGZ "Enter second number (0 - 99): "
RESULT_MSG  .STRINGZ "Result: "


;================================================================
; GETNUM:
; This part reads digits 0-99 by accepting 1 or 2 digits. If the
; user enters one digit, the input can be finished by pressing
; enter. If two digits are entered it is finished automatically.
; anything else should be ignored.
;================================================================
GETNUM
	ST  R7, GETNUM_SAVE7
	ST  R1, GETNUM_SAVE1
	ST  R2, GETNUM_SAVE2
	ST  R3, GETNUM_SAVE3

GETNUM_1                     ; For getting the first digit
	GETC                     ; sets R0 to the value of whatever key is pressed
	LD R2, GETNUM_NEGATIVE   ; loads -48 into R2
	ADD R1, R0, R2           ; Subtracts 48 from number value to get actual number it equals
	BRn GETNUM_1             ; number was below 48 (0-9), ignore and try again
	ADD R2, R1, #-9          ; 
	BRp GETNUM_1             ; number was above 57 (0-9), ignore and try again
	OUT                      ; it's a valid digit, so show it on screen

GETNUM_2                     ; For getting the second digit
	GETC                     ; sets R0 to the value of whatever key is pressed
	LD R2, GETNUM_ENTERLF    ; Set R2 to -10 to check for enter key press
	ADD R3, R0, R2           ; key value minus 10 to check if it is 0 (meaning it was the enter key)
	BRz GETNUM_FINISH        ; yes, so Enter was pressed. The number is one digit.
	LD  R2, GETNUM_ENTERCR   ; R2 = -13
	ADD R2, R0, R2           ; R2 = code - 13
	BRz GETNUM_FINISH        ; zero means Enter (CR). The number is one digit
	LD R2, GETNUM_NEGATIVE   ; loads -48 into R2
	ADD R3, R0, R2           ; Subtracts 48 from number value to get actual number it equals
	BRn GETNUM_2             ; number was below 48 (0-9), ignore and try again
	ADD R2, R3, #-9          ; 
	BRp GETNUM_2             ; number was above 57 (0-9), ignore and try again
	OUT                      ; it's a valid digit, so show it on screen
	; code for turning two separate digits into a double digit number
	ADD R2, R1, R1           ; R2 = 2x     (x is the first digit)
	ADD R1, R2, R2           ; R1 = 4x
	ADD R1, R1, R1           ; R1 = 8x
	ADD R1, R1, R2           ; R1 = 8x + 2x = 10x
	ADD R1, R1, R3           ; R1 = 10x + second digit

GETNUM_FINISH
	LD R0, GETNUM_NEWLINE
	OUT
	ADD R0, R1, #0
	LD R1, GETNUM_SAVE1
	LD R2, GETNUM_SAVE2
	LD R3, GETNUM_SAVE3
	LD R7, GETNUM_SAVE7

RET

GETNUM_SAVE7 .FILL #0
GETNUM_SAVE1 .FILL #0
GETNUM_SAVE2 .FILL #0
GETNUM_SAVE3 .FILL #0
GETNUM_NEGATIVE  .FILL #-48
GETNUM_ENTERLF  .FILL #-10    ; -LF
GETNUM_ENTERCR    .FILL #-13    ; -CR
GETNUM_NEWLINE       .FILL x000A   ; newline character

;================================================================
; GETOP:
; Tests whether one of the operator keys (+,-, or *) was pressed.
; If anything else, ignore.
;================================================================
GETOP
	ST  R7, GETOP_SAVE7       ; back up R7 (GETC and OUT overwrite it)
	ST  R1, GETOP_SAVE1       ; back up R1 (use it as scratch)

GETOP_LOOP
	GETC                      ; R0 = ASCII code of key pressed
	LD  R1, GETOP_PLUSCHECK   ; R1 = -43
	ADD R1, R0, R1            ; R1 = code - 43
	BRz GETOP_OK              ; zero means the key was '+'
	LD  R1, GETOP_MINUSCHECK  ; R1 = -45
	ADD R1, R0, R1            ; R1 = code - 45
	BRz GETOP_OK              ; zero means the key was '-'
	LD  R1, GETOP_MULTCHECK   ; R1 = -42
	ADD R1, R0, R1            ; R1 = code - 42
	BRnp GETOP_LOOP           ; not zero means not '*' either. Ignore it and try again

GETOP_OK
	OUT                       ; echo the operator to the screen
	ADD R1, R0, #0            ; copy the operator into R1 to save it
	LD  R0, GETOP_NEWLINE     ; R0 = newline character
	OUT                       ; move the cursor to the next line
	ADD R0, R1, #0            ; put the operator back into R0 as the return value
	LD  R1, GETOP_SAVE1       ; restore R1
	LD  R7, GETOP_SAVE7       ; restore R7
RET

GETOP_SAVE7    .FILL #0
GETOP_SAVE1    .FILL #0
GETOP_PLUSCHECK  .FILL #-43   ; -'+'
GETOP_MINUSCHECK .FILL #-45   ; -'-'
GETOP_MULTCHECK  .FILL #-42   ; -'*'
GETOP_NEWLINE  .FILL x000A    ; new line character

;================================================================
; CALC:
; Calculates the operations (R2 displayed in ASCII) between R0 (first number) 
; and R1 (second number) and leaves it as the result in R0.
;================================================================
CALC
	ST R2, CALC_SAVE2
	ST R3, CALC_SAVE3

	LD R3, CALC_CHECK_ADD       ; R3 = -43
	ADD R3, R2, R3              ; zero if R2 was '+'
	BRz CALC_ADD
	LD R3, CALC_CHECK_SUBTRACT  ; R3 = -45
	ADD R3, R2, R3              ; zero if R2 was '-'
	BRz CALC_SUBTRACT
	LD R3, CALC_CHECK_MULTIPLY  ; R3 = -42
	ADD R3, R2, R3              ; zero if R2 was '*'
	BRz CALC_MULTIPLY
	BR CALC_FINISH              ; not a known operator, so leave R0 alone and leave

CALC_ADD
	ADD R0, R0, R1              ; R0 = first number + second number
	BR CALC_FINISH              ; skip over the other operations

CALC_SUBTRACT
	NOT R3, R1                  ; R3 = R1 with all its bits flipped
	ADD R3, R3, #1              ; adding 1 makes it -R1
	ADD R0, R0, R3              ; R0 = first number + (-second number)
	BR CALC_FINISH

CALC_MULTIPLY
	ADD R2, R0, #0              ; R2 = copy of the first number
	AND R0, R0, #0              ; R0 = 0, this is the running total
	ADD R3, R1, #0              ; R3 = copy of the second number (counts how many adds are left)
	BRz CALC_FINISH             ; second number is 0, so the answer is 0 already
MULTIPLY_LOOP
	ADD R0, R0, R2              ; add the first number to the running total
	ADD R3, R3, #-1             ; one less add left to do
	BRp MULTIPLY_LOOP           ; still positive means more adds left, so go again

CALC_FINISH
	LD  R2, CALC_SAVE2          ; restore R2 and R3 (R0 stays as the result)
	LD  R3, CALC_SAVE3
	RET

CALC_SAVE2    .FILL #0
CALC_SAVE3    .FILL #0
CALC_CHECK_ADD  .FILL #-43      ; -'+'
CALC_CHECK_SUBTRACT .FILL #-45  ; -'-'
CALC_CHECK_MULTIPLY  .FILL #-42 ; -'*'

;================================================================
; DISPLAY:
; This prints the signed number in R0 but only up to 4 digits. 
; Also prints a '-' for negative numbers and makes sure to skip
; leading 0s. Doesn't print a new line.
;================================================================
DISPLAY
	ST  R7, DISPLAY_SAVE7
	ST  R1, DISPLAY_SAVE1
	ST  R2, DISPLAY_SAVE2
	ST  R3, DISPLAY_SAVE3
	ST  R4, DISPLAY_SAVE4
	ST  R5, DISPLAY_SAVE5

ADD R1, R0, #0                ; R1 = working copy of the number and sets the BRn, BRz, BRp note
	BRz DISPLAY_NUMBERZERO    ; exactly 0: special case
	BRp DISPLAY_START         ; positive: nothing to fix. prints
	NOT R1, R1                ; negative: flip it to positive
	ADD R1, R1, #1
	LD  R0, DISPLAY_MINUS     ; R0 = '-'
	OUT                       ; print the minus sign
	BR  DISPLAY_START

DISPLAY_NUMBERZERO
	LD  R0, DISPLAY_ZERO      ; R0 = '0'
	OUT                       ; print single zero
	BR  DISPLAY_END

DISPLAY_START
	LEA R2, DISPLAY_POWERS    ; R2 = address of the table (-1000, -100, -10, -1, 0)
	AND R5, R5, #0            ; R5 = 0 nothing prints yet

DISPLAY_NEXT                  ; runs once per power of ten
	LDR R3, R2, #0            ; R3 = the table entry R2 points at
	BRz DISPLAY_END           ; hit the 0 at the end of the table: done
	AND R4, R4, #0            ; R4 = 0: digit counter (how many times it fits)

DISPLAY_POWERSUBTRACT
	ADD R1, R1, R3            ; subtract the power of ten
	BRn DISPLAY_UNDO          ; went below zero: that was one too many
	ADD R4, R4, #1            ; it fit, so count it
	BR  DISPLAY_POWERSUBTRACT ; try again

DISPLAY_UNDO
	NOT R3, R3                ; flip the table entry to positive
	ADD R3, R3, #1
	ADD R1, R1, R3            ; add it back: R1 is now the remainder

	ADD R4, R4, #0            ; look at the digit
	BRp DISPLAY_PRINT         ; nonzero digit: always print
	ADD R5, R5, #0            ; digit is 0. Has it printed anything yet?
	BRz DISPLAY_ADVANCE       ; no: it's a leading zero, skip it

DISPLAY_PRINT
	ADD R5, R5, #1            ; remember that something was printed
	LD  R0, DISPLAY_ZERO      ; R0 = 48
	ADD R0, R0, R4            ; R0 = 48 + digit = the digit's character
	OUT                       ; print it

DISPLAY_ADVANCE
	ADD R2, R2, #1            ; move the pointer to the next table entry
	BR  DISPLAY_NEXT

DISPLAY_END
	LD  R1, DISPLAY_SAVE1
	LD  R2, DISPLAY_SAVE2
	LD  R3, DISPLAY_SAVE3
	LD  R4, DISPLAY_SAVE4
	LD  R5, DISPLAY_SAVE5
	LD  R7, DISPLAY_SAVE7
	RET

DISPLAY_SAVE7 .FILL #0
DISPLAY_SAVE1 .FILL #0
DISPLAY_SAVE2 .FILL #0
DISPLAY_SAVE3 .FILL #0
DISPLAY_SAVE4 .FILL #0
DISPLAY_SAVE5 .FILL #0
DISPLAY_ZERO  .FILL #48       ; '0'
DISPLAY_MINUS .FILL #45       ; '-'
DISPLAY_POWERS .FILL #-1000
	.FILL #-100
	.FILL #-10
	.FILL #-1
	.FILL #0

.END
