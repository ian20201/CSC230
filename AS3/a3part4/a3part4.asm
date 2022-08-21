; a3part4.asm
; CSC 230: Summer 2022
;
; Student name:
; Student ID:
; Date of completed work:
;
; *******************************
; Code provided for Assignment #3
;
; Author: Mike Zastre (2022-Jul-02)
; 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#3. As with A#2, there are 
; "DO NOT TOUCH" sections. You are *not* to modify the lines
; within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; I have added for this assignment an additional kind of section
; called "TOUCH CAREFULLY". The intention here is that one or two
; constants can be changed in such a section -- this will be needed
; as you try to test your code on different messages.
;


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
;
; In this "DO NOT TOUCH" section are:
;
; (1) assembler directives setting up the interrupt-vector table
;
; (2) "includes" for the LCD display
;
; (3) some definitions of constants we can use later in the
;     program
;
; (4) code for initial setup of the Analog Digital Converter (in the
;     same manner in which it was set up for Lab #4)
;     
; (5) code for setting up our three timers (timer1, timer3, timer4)
;
; After all this initial code, your own solution's code may start.
;

.cseg
.org 0
	jmp reset

; location in vector table for TIMER1 COMPA
;
.org 0x22
	jmp timer1

; location in vector table for TIMER4 COMPA
;
.org 0x54
	jmp timer4

.include "m2560def.inc"
.include "lcd_function_defs.inc"
.include "lcd_function_code.asm"

.cseg

; These two constants can help given what is required by the
; assignment.
;
#define MAX_PATTERN_LENGTH 10
#define BAR_LENGTH 6

; All of these delays are in seconds
;
#define DELAY1 0.5
#define DELAY3 0.1
#define DELAY4 0.01


; The following lines are executed at assembly time -- their
; whole purpose is to compute the counter values that will later
; be stored into the appropriate Output Compare registers during
; timer setup.
;

#define CLOCK 16.0e6 
.equ PRESCALE_DIV=1024  ; implies CS[2:0] is 0b101
.equ TOP1=int(0.5+(CLOCK/PRESCALE_DIV*DELAY1))

.if TOP1>65535
.error "TOP1 is out of range"
.endif

.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif


reset:
	; initialize the ADC converter (which is neeeded
	; to read buttons on shield). Note that we'll
	; use the interrupt handler for timer4 to
	; read the buttons (i.e., every 10 ms)
	;
	ldi temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
	sts ADCSRA, temp
	ldi temp, (1 << REFS0)
	sts ADMUX, r16


	; timer1 is for the heartbeat -- i.e., part (1)
	;
    ldi r16, high(TOP1)
    sts OCR1AH, r16
    ldi r16, low(TOP1)
    sts OCR1AL, r16
    ldi r16, 0
    sts TCCR1A, r16
    ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
    sts TCCR1B, temp
	ldi r16, (1 << OCIE1A)
	sts TIMSK1, r16

	; timer3 is for the LCD display updates -- needed for all parts
	;
    ldi r16, high(TOP3)
    sts OCR3AH, r16
    ldi r16, low(TOP3)
    sts OCR3AL, r16
    ldi r16, 0
    sts TCCR3A, r16
    ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)
    sts TCCR3B, temp

	; timer4 is for reading buttons at 10ms intervals -- i.e., part (2)
    ; and part (3)
	;
    ldi r16, high(TOP4)
    sts OCR4AH, r16
    ldi r16, low(TOP4)
    sts OCR4AL, r16
    ldi r16, 0
    sts TCCR4A, r16
    ldi r16, (0 << WGM42) | (0 << CS42) | (1 << CS40)
    sts TCCR4B, temp
	ldi r16, (1 << OCIE4A)
	sts TIMSK4, r16

    ; flip the switch -- i.e., enable the interrupts
    sei

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================


; *********************************************
; **** BEGINNING OF "STUDENT CODE" SECTION **** 
; *********************************************

	.def DATAL=r24
	.def DATAH=r25

	;definitions for using the analog to digital conversion
	.equ ADCL_BTN=0x78
	.equ ADCH_BTN=0x79
	.equ BOUNDARY=0x3E8

	.equ MAX_POS=5 ;Defind the max position of the Two Decimal
	
	clr r16
	sts BUTTON_CURRENT, r16
	sts BUTTON_PREVIOUS, r16
	sts BUTTON_COUNT, r16
	sts BUTTON_COUNT+1, r16
	sts BUTTON_LENGTH, r16 ;Initialized the Buttom length to 0
	;sts DISPLAY_TEXT, r16

	ldi XH, high(DOTDASH_PATTERN)
	ldi XL, low(DOTDASH_PATTERN)
	ldi r16, ' '
	ldi r17, 10 ;Counter
	clean: 
		st X+,r16
		dec r17
		tst r17
		brne clean
	;initialize Dot and Dash on LCD

;======================================================
;====================Start quote from Lab08============
;======================================================
	;initialize the LCD display
	rcall lcd_init

	;now display some characters
	ldi r16, 0 ;row
	ldi r17, 0 ;column
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

;======================================================
;===========START Basic Character for Display==========
;======================================================

	ldi r16, '<'
	sts CHAR_ONE, r16

	ldi r16, ' '
	sts CHAR_TWO, r16

	ldi r16, '>'
	sts CHAR_THREE, r16

	ldi r16, ' '
	sts CHAR_FOUR, r16

	ldi r16, ' '
	sts CHAR_FIVE, r16

	ldi r16, '*'
	sts CHAR_SIX, r16

;======================================================
;============END Basic Character for Display===========
;======================================================

;======================================================
;====================END quote from Lab08==============
;======================================================
	;now display "00000"
	ldi r16, 1 ;row
	ldi r17, 11 ;column
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	ldi r16, '0'
	push r16
	rcall lcd_putchar
	pop r16

	ldi r16, '0'
	push r16
	rcall lcd_putchar
	pop r16

	ldi r16, '0'
	push r16
	rcall lcd_putchar
	pop r16

	ldi r16, '0'
	push r16
	rcall lcd_putchar
	pop r16

	ldi r16, '0'
	push r16
	rcall lcd_putchar
	pop r16

	;now display "      " 6 spaces
	ldi r16, 1 ;row
	ldi r17, 0 ;column
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16

	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16

	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16

	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16

	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16

	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16
;======================================================
;====================Start quote from Lab08============
;======================================================

; #############################################
; ##### BEGINNING OF "MAIN LOOP" SECTION ###### 
; #############################################

start:
	
	; Timer 3 polling
    in r16, TIFR3
    sbrs r16, OCF3A

    rjmp blink_loop

    ldi r16, (1<<OCF3A)
    out TIFR3, r16
    rjmp start
	

blink_loop:
	;Display '<' and make a change
	ldi r16, 0  ; <- change the row
	ldi r17, 14 ; <- change the column
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	lds r16, CHAR_ONE
	push r16
	rcall lcd_putchar
	pop r16

	;Display '>' and make a change
	ldi r16, 0 ; <- change the row
	ldi r17, 15; <- change the column
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16


	lds r16, CHAR_THREE
	push r16
	rcall lcd_putchar
	pop r16
;======================================================
;====================END quote from Lab08==============
;======================================================

;######################################################
;###################### Part2 #########################
;######################################################

	;Display '0' and make a change
	ldi r16, 1 ; <- change the row
	ldi r17, 11; <- change the column
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	lds r17,BUTTON_COUNT
	lds r16,BUTTON_COUNT+1
	push r17
	push r16

	ldi r17,high(DISPLAY_TEXT)
	ldi r16,low(DISPLAY_TEXT)
	push r17
	push r16
	rcall to_decimal_text

	pop r16
	pop r17
	pop r16
	pop r17


	lds r16, DISPLAY_TEXT+0
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DISPLAY_TEXT+1
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DISPLAY_TEXT+2
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DISPLAY_TEXT+3
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DISPLAY_TEXT+4
	push r16
	rcall lcd_putchar
	pop r16
	
;######################################################
;###################### Part3 #########################
;######################################################

	;Display '      ' six spaces and make a change 
	ldi r16, 1; <- change the row
	ldi r17, 0; <- change the column
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16


	lds r16, CHAR_FIVE
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, CHAR_FIVE
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, CHAR_FIVE
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, CHAR_FIVE
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, CHAR_FIVE
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, CHAR_FIVE
	push r16
	rcall lcd_putchar
	pop r16


;######################################################
;###################### Part4 #########################
;######################################################

;======================================================
;==================Check Dot or DASH===================
;======================================================
	
	push r16
	push r17
	push r18
	push r19
	push r20
	push ZH
	push ZL
	push XH
	push XL
	

	lds r16, BUTTON_LENGTH
	cpi r16, 0x01 ;Compare with 1 if it =< 1 then do nothing
	brlo displayDOTandDASH

	lds r17, BUTTON_COUNT+1
	cpi r17, 11   ;Branch if the BUTTON_COUNT+1 are higher or equal to 11
	brsh displayDOTandDASH

	ldi ZH, high(DOTDASH_PATTERN)
	ldi ZL, low(DOTDASH_PATTERN)

	cpi r17, 1    ;If this is the firt Dot or DASH that need to display then jump to display directly
	breq StoreDotOrDash
	
	ldi r18, 1
	clr r19
	Location_Loop:
		add ZL, r18
		adc ZH, r19
		dec r17
		cpi r17, 1
		brne Location_Loop
	;Find Location, loop to the lastest position of DOTDASH_PATTERN

	StoreDotOrDash:
		cpi r16,20
		brsh storeDashs
		;Store Dot
		ldi r20,'.'
		st Z, r20 ;Store Dot to Z
		rjmp displayDOTandDASH

		storeDashs:
			ldi r20,'-'
			st Z, r20 ;Store Dash to Z

displayDOTandDASH:
	ldi r16, 0; <- change the row
	ldi r17, 0; <- change the column
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	
	lds r16, DOTDASH_PATTERN+0
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DOTDASH_PATTERN+1
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DOTDASH_PATTERN+2
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DOTDASH_PATTERN+3
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DOTDASH_PATTERN+4
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DOTDASH_PATTERN+5
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DOTDASH_PATTERN+6
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DOTDASH_PATTERN+7
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DOTDASH_PATTERN+8
	push r16
	rcall lcd_putchar
	pop r16

	lds r16, DOTDASH_PATTERN+9
	push r16
	rcall lcd_putchar
	
	pop r16
	pop XL
	pop XH
	pop ZL
	pop ZH
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	
	rjmp start
	;rjmp blink_loop

stop:
    rjmp stop

; #############################################
; ######## END OF "MAIN LOOP" SECTION ######### 
; #############################################

;======================================================
;================Start quote from Lab08================
;======================================================
timer1:
	push r16
	in r16,SREG ;Prevent Change on StatusRegister for I/O
	
	;how many registers you are going to use?
	;preserve the values on the stack
	;also save the status register
	push r16
	push r17
	;read CHAR_ONE into, say, r16 and 
	;read CHAR_TWO into, say r17
	;store r16 in CHAR_TWO
	;store r17 in CHAR_ONE <- now, they are swapped
	lds r16, CHAR_ONE
	lds r17, CHAR_TWO
	sts CHAR_ONE, r17
	sts CHAR_TWO, r16

	pop r17
	pop r16
	;restore the status register and the registers that you used

	push r16
	push r17
	;read CHAR_THREE into, say, r16 and 
	;read CHAR_FOUR into, say r17
	;store r16 in CHAR_FOUR
	;store r17 in CHAR_THREE <- now, they are swapped
	lds r16, CHAR_THREE
	lds r17, CHAR_FOUR
	sts CHAR_THREE, r17
	sts CHAR_FOUR, r16

	pop r17
	pop r16
	;restore the status register and the registers that you used

	out SREG,r16 ;Prevent Change on StatusRegister, for I/O
	pop r16
	reti
;======================================================		
;=====================End quote from Lab08=============
;======================================================

; Note there is no "timer3" interrupt handler as we must use this
; timer3 in a polling style within our main program.


timer4:
	
	push ZH
	push ZL
	push r16
	in r16,SREG ;Prevent Change on StatusRegister for I/O
	push r16
	push r17
	push r23

	rcall check_button
	lds r16, BUTTON_CURRENT
	lds r17, BUTTON_PREVIOUS
	lds ZH, BUTTON_COUNT
	lds ZL, BUTTON_COUNT+1

	cpi r16, 0
	breq cleanLENGTH

beginContinue:

	cpi r16, 0x01 ;Check if the bottom has been press
	breq compare_r17
	rjmp jamp

compare_r17: ;Check if the Buttom's PREVIOUS status are Release or not
	
	cpi r17, 0x00 ;Check if the bottom just got press, if so the PREVIOUS status must be 0
	;cpi r17, 0x01 ;========================TEST CODE FOR SEMI AUTO ADDING=======================	
	breq addNumber
	cpi r17, 0x01
	breq Increasement
	rjmp jamp

addNumber: ;add Number if the buttom has been press

	push r16
	lds r16, BUTTON_LENGTH
	inc r16
	sts BUTTON_LENGTH, r16
	pop r16
	;Add one to BUTTON_LENGTH


	push r16
	push r17
	;read CHAR_FIVE into, say, r16 and 
	;read CHAR_SIX into, say r17
	;store r16 in CHAR_SIX
	;store r17 in CHAR_FIVE <- now, they are swapped
	lds r16, CHAR_FIVE
	lds r17, CHAR_SIX
	sts CHAR_FIVE, r17
	sts CHAR_SIX, r16

	pop r17
	pop r16
	
	adiw ZH:ZL,1
	sts BUTTON_COUNT, ZH
	sts BUTTON_COUNT+1, ZL

	rjmp jamp

Increasement:
	push r16
	lds r16, BUTTON_LENGTH
	inc r16
	cpi r16,0xff ;compare BUTTON_LENGTH with the largest the r16 can be if so set r16 to 20 maintain it's status
	breq special
continue:
	sts BUTTON_LENGTH, r16
	pop r16
	;Add one to BUTTON_LENGTH
	rjmp jamp

special:
	ldi r16,0x20
	rjmp continue

cleanLENGTH:
	push r16
	ldi r16, 0
	sts BUTTON_LENGTH, r16
	pop r16
	;Clean the BUTTON_LENGTH
	rjmp beginContinue

sign_change: ;Change the sign for the display if the buttom has been release

	push r16
	push r17
	;read CHAR_FIVE into, say, r16 and 
	;read CHAR_SIX into, say r17
	;store r16 in CHAR_SIX
	;store r17 in CHAR_FIVE <- now, they are swapped
	lds r16, CHAR_FIVE
	lds r17, CHAR_SIX
	sts CHAR_FIVE, r17
	sts CHAR_SIX, r16

	pop r17
	pop r16

	rjmp jamp2

jamp: ;Check if the buttom has been release



	cpi r16,0x00
	breq compare_r17_2
	rjmp jamp2

compare_r17_2: ;use the r17 to confirm the buttom was been press before

	cpi r17,0x01
	breq sign_change
	rjmp jamp2

jamp2: ;Final step of the findish the timer4
	sts BUTTON_PREVIOUS, r16 ;Save the current buttom satus in BUTTON_PREVIOUS
	

	pop r23
	pop r17
	pop r16
	out SREG,r16 ;Prevent Change on StatusRegister, for I/O
	pop r16
	pop ZL
	pop ZH
	reti
;======================================================
;==========Start quote from hex-to-decimal.pdf=========
;======================================================
to_decimal_text:
	.def countL=r18
	.def countH=r19
	.def factorL=r20
	.def factorH=r21
	.def multiple=r22
	.def pos=r23
	.def zero=r0
	.def ascii_zero=r16

	push countH
	push countL
	push factorH

	push factorL
	push multiple
	push pos
	push zero
	push ascii_zero
	push YH
	push YL
	push ZH
	push ZL
	in YH, SPH
	in YL, SPL

	.set PARAM_OFFSET = 16
	ldd countH, Y+PARAM_OFFSET+3
	ldd countL, Y+PARAM_OFFSET+2

	andi countH, 0b01111111
	clr zero
	clr pos
	ldi ascii_zero, '0'

to_decimal_next: 
	
	clr multiple

to_decimal_10000:
	cpi pos, 0
	brne to_decimal_1000
	ldi factorL, low(10000)
	ldi factorH, high(10000)
	rjmp to_decimal_loop

to_decimal_1000:
	cpi pos, 1
	brne to_decimal_100
	ldi factorL, low(1000)
	ldi factorH, high(1000)
	rjmp to_decimal_loop

to_decimal_100:
	cpi pos, 2
	brne to_decimal_10
	ldi factorL, low(100)
	ldi factorH, high(100)
	rjmp to_decimal_loop

to_decimal_10:
	cpi pos, 3
	brne to_decimal_1
	ldi factorL, low(10)
	ldi factorH, high(10)
	rjmp to_decimal_loop

to_decimal_1:
	mov multiple, countL
	rjmp to_decimal_write

to_decimal_loop:
	inc multiple
	sub countL, factorL
	sbc countH, factorH
	brpl to_decimal_loop
	dec multiple
	add countL, factorL
	adc countH, factorH

to_decimal_write:
	ldd ZH, Y+PARAM_OFFSET+1
	ldd ZL, Y+PARAM_OFFSET+0
	add ZL, pos
	adc ZH, zero
	add multiple, ascii_zero
	st Z, multiple
	inc pos
	cpi pos, MAX_POS
	breq to_decimal_exit
	rjmp to_decimal_next

to_decimal_exit:
	pop ZL
	pop ZH
	pop YL
	pop YH
	pop ascii_zero
	pop zero
	pop pos
	pop multiple
	pop factorL
	pop factorH
	pop countL
	pop countH
	.undef countL
	.undef countH
	.undef factorL
	.undef factorH
	.undef multiple
	.undef pos
	.undef zero
	.undef ascii_zero
	ret
;======================================================
;=============END quote from hex-to-decimal.pdf========
;======================================================

;======================================================
;================Start quote from Lab 04===============
;======================================================
check_button:
	; start a2d
	lds	r16, ADCSRA

	; bit 6 =1 ADSC (ADC Start Conversion bit), remain 1 if conversion not done
	; ADSC changed to 0 if conversion is done
	ori r16, 0x40 ; 0x40 = 0b01000000
	sts	ADCSRA, r16

	; wait for it to complete, check for bit 6, the ADSC bit
wait:	
	lds r16, ADCSRA
	andi r16, 0x40
	brne wait

	; read the value, use XH:XL to store the 10-bit result
	lds DATAL, ADCL_BTN
	lds DATAH, ADCH_BTN

	clr r23
	; if DATAH:DATAL < BOUNDARY:BOUNDARY
	;     r23=1  "right" button is pressed
	; else
	;     r23=0
	ldi r16,low(BOUNDARY)
	ldi	r17,high(BOUNDARY)
	cp DATAL, r16
	cpc DATAH, r17
	brsh skip		
	ldi r23,1

skip:
	sts BUTTON_CURRENT, r23	
	ret
;======================================================
;================End quote from Lab 04=================
;======================================================



; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION ********** 
; ***************************************************


; ################################################
; #### BEGINNING OF "TOUCH CAREFULLY" SECTION ####
; ################################################

; The purpose of these locations in data memory are
; explained in the assignment description.
;

.dseg
CHAR_ONE:  .byte 1
CHAR_TWO:  .byte 1
CHAR_THREE:.byte 1
CHAR_FOUR: .byte 1
;Character setup for the <> sign
CHAR_FIVE: .byte 1
CHAR_SIX:  .byte 1
;Character setup for the * sign
PULSE: .byte 1
COUNTER: .byte 2
DISPLAY_TEXT: .byte 16
BUTTON_CURRENT: .byte 1
BUTTON_PREVIOUS: .byte 1
BUTTON_COUNT: .byte 2
BUTTON_LENGTH: .byte 1
DOTDASH_PATTERN: .byte MAX_PATTERN_LENGTH

; ##########################################
; #### END OF "TOUCH CAREFULLY" SECTION ####
; ##########################################
