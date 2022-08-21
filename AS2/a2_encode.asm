; a2_morse.asm
; CSC 230: Summer 2022
;
; Student name: Yu-Lun Chen [Ian]

; Student ID: V00887293
; Date of completed work: 2022/06/24
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2019-Jun-12)
; 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are 
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

.include "m2560def.inc"

.cseg
.equ S_DDRB=0x24
.equ S_PORTB=0x25
.equ S_DDRL=0x10A
.equ S_PORTL=0x10B

	
.org 0
	; Copy test encoding (of 'sos') into SRAM
	;
	ldi ZH, high(TESTBUFFER)
	ldi ZL, low(TESTBUFFER)
	ldi r16, 0x30
	st Z+, r16
	ldi r16, 0x37
	st Z+, r16
	ldi r16, 0x30
	st Z+, r16
	clr r16
	st Z, r16

	; initialize run-time stack
	ldi r17, high(0x21ff)
	ldi r16, low(0x21ff)
	out SPH, r17
	out SPL, r16

	; initialize LED ports to output
	ldi r17, 0xff
	sts S_DDRB, r17
	sts S_DDRL, r17

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION **** 
; ***************************************************

	; If you're not yet ready to execute the
	; encoding and flashing, then leave the
	; rjmp in below. Otherwise delete it or
	; comment it out.

	;rjmp stop

    ; The following seven lines are only for testing of your
    ; code in part B. When you are confident that your part B
    ; is working, you can then delete these seven lines. 
	;ldi r17, high(TESTBUFFER)
	;ldi r16, low(TESTBUFFER)
	;push r17
	;push r16
	;rcall flash_message
    ;pop r16
	;pop r17
   
; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION ********** 
; ***************************************************


; ################################################
; #### BEGINNING OF "TOUCH CAREFULLY" SECTION ####
; ################################################

; The only things you can change in this section is
; the message (i.e., MESSAGE01 or MESSAGE02 or MESSAGE03,
; etc., up to MESSAGE09).
;

	; encode a message
	;
	ldi r17, high(MESSAGE02 << 1)
	ldi r16, low(MESSAGE02 << 1)
	push r17
	push r16
	ldi r17, high(BUFFER01)
	ldi r16, low(BUFFER01)
	push r17
	push r16
	rcall encode_message
	pop r16
	pop r16
	pop r16
	pop r16

; ##########################################
; #### END OF "TOUCH CAREFULLY" SECTION ####
; ##########################################


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
	; display the message three times
	;
	ldi r18, 3
main_loop:
	ldi r17, high(BUFFER01)
	ldi r16, low(BUFFER01)
	push r17
	push r16
	rcall flash_message
	dec r18
	tst r18
	brne main_loop


stop:
	rjmp stop
; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================


; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION **** 
; ****************************************************


flash_message:
				push r16
				push YH	; Y is the stack pointer
				push YL
				push ZH ; Z buffer locate
				push ZL

				.set PARAM_OFFSET = 9

				in YH, SPH
				in YL, SPL

				ldd ZH, Y + PARAM_OFFSET + 1
				ldd ZL, Y + PARAM_OFFSET

				load_loop:
								 ld r16, Z+
								 call morse_flash
								 cpi r16, 0 							; Compare with 0, make sure it is not 0
								 brne load_loop					;loop if it is not 0

			
				pop ZL
				pop ZH
				pop YL
				pop YH
				pop r16

				ret

morse_flash:
				cpi r16,0											;Run if it is not 0
				breq zero_finish

				cpi r16, 0xff										;Test if it is Special Case
				breq special_case 
						
				
				ldi r19, 0x00 ;tmp counter
				ldi r22, 0x00 ;tmp store

				mov r20, r16 ;copy input into r20
				mov r21, r16 ;copy input into r21

				ldi r17, 0b00001111
				and r20, r17 ;clear high 4 bit for r20 for the message for the Morse Code
				ldi r17, 0b11110000
				and r21, r17 ;clear low 4 bit for the r21 for the length of the Morse Code, This is also use as counter

				lsr r21
				lsr r21
				lsr r21
				lsr r21
				//Rotate the r21 4bit to the right
				
				mov r19,r21
				
				push r22
				reverse:
						ror r20
						rol r22
						dec r19
						cpi r19, 0x00
						breq end
						rjmp reverse
				end:
						mov r20,r22
						pop r22

						push r22
				flash_loop:
							
							ror r20
							rol r22
							cpi r22, 0x00
							breq led_dot ;run led_dot it Z flag = 0
							rjmp led_dash
				resume:
							clr r22
							
							dec r21 ;conter -1
							brne flash_loop ;looping  if it is not 0


				finish:				
							pop r20			
							ret
				zero_finish:
							ret

; ****************************************************
; ****** BEGINNING OF MORSE FLASE FUNCTION ****** 
; ****************************************************
special_case:													;Special Case for r16 = 0xff
				call leds_off
				;call delay_long
				;call delay_long
				;call delay_long
				ret
led_dash:															;Turn on the LED for Dash
				call leds_on
				;call delay_long
				call leds_off
				;call delay_long
				rjmp resume
led_dot:															;Turn om the LED for Dot
				call leds_on
				;call delay_short
				call leds_off
				;call delay_long
				rjmp resume

; ****************************************************
; ********* END OF MORSE FLASE FUNCTION ********** 
; ****************************************************

leds_on:
				push r16
				ldi r16, 0b00000010
				out PORTB, r16
				pop r16
				ret



leds_off:	
				push r16
				ldi r16, 0b00000000
				out PORTB, r16
				pop r16
				ret



encode_message:
				push XH	; X is the buffer
				push XL
				push YH	; Y is the stack pointer
				push YL
				push ZH ; Z is the where the message stored
				push ZL
								
				.set PARAM_OFFSET = 9
				
				in YH, SPH
				in YL, SPL
				
				
						
				ldd XH, Y + PARAM_OFFSET + 2 ; 9 + 2
				ldd XL, Y + PARAM_OFFSET + 1 ;9 + 1	

				ldd ZH, Y + PARAM_OFFSET + 4 ; 9 + 4
				ldd ZL, Y + PARAM_OFFSET + 3 ; 9 + 3

				encode:			
								

								ldi r20, 0							; Use r20 to hold dots or dashes

								lpm r19, Z+						; Load the next letter into r19
								cpi r19, 0							; Compare with 0, make sure it is not 0
								breq complete_encoding
								
								
								
								cpi r19, 0x20					; Compare with 0x20 (ASCII Space), make sure it is space or not
								breq space_encode
								
								call alphabet_encode
								
				store:
								st X+,r0						; Store the  r0 into X
								clr r19
								rjmp encode
				
				space_encode:
								ldi r21, 0xff
								mov r0, r21
								rjmp store

				complete_encoding:								
								pop ZL
								pop ZH
								pop YL
								pop YH
								pop XL
								pop XH
								ret



alphabet_encode:
			push ZH
			push ZL


			ldi ZH, high(ITU_MORSE<<1)		; Load ITU_MORSE into the Z
			ldi ZL, low(ITU_MORSE<<1)
			lpm r22, Z+										;Load the letter from  Z that containg ITU_MORSE to r22
			ldi r23, 0x01									;Set r23 to 1 for dash
			ldi r21, 0x00									;Counter set 0
			ldi r20, 0x00									;set r20 to 0 for holding Morse Code

			find_letter:
								cp r19,r22					;Compare the letter in r19 with the letter from the stack
								breq assign_sign			;If r22 and r19 are equal leave loop, start assign morse sign to the label
								lpm r22, Z+					;If not lopp uptil find the letter we want
								rjmp find_letter
			assign_sign:
								lpm r22, Z+					;load the next Morse code into the r22
								cpi r22, 0						;Compare the r22 to the 0 if r22 = 0 exit the loop
								breq exit_loop
								
								cpi r22, 0x2D				;Compare the r22 to 0x2D if r22 = 0x2D, then it will be dash
								breq dash
								
								rjmp dot

			dash:
								lsl r20							;Shif the r20 to the left to make 0 for next symbol
								add r20, r23
								inc r21							;Counter add 1
								rjmp assign_sign
			dot:
								inc r21							;Counter add 1
								rjmp assign_sign

			exit_loop:
								lsl r21
								lsl r21
								lsl r21
								lsl r21

								or r20,r21						;or r20 with r21(size) to get full Morse code

								mov r0,r20					;copy r20 to r0
													
								pop ZL
								pop ZH
								
															
								ret
										
								


; **********************************************
; **** END OF SECOND "STUDENT CODE" SECTION **** 
; **********************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

delay_long:
	rcall delay
	rcall delay
	rcall delay
	ret

delay_short:
	rcall delay
	ret

; When wanting about a 1/5th of second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit
	
	ldi r17, 0xff
delay_busywait_loop2:
	dec	r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret



.org 0x1000

ITU_MORSE: .db "a", ".-", 0, 0, 0, 0, 0
	.db "b", "-...", 0, 0, 0
	.db "c", "-.-.", 0, 0, 0
	.db "d", "-..", 0, 0, 0, 0
	.db "e", ".", 0, 0, 0, 0, 0, 0
	.db "f", "..-.", 0, 0, 0
	.db "g", "--.", 0, 0, 0, 0
	.db "h", "....", 0, 0, 0
	.db "i", "..", 0, 0, 0, 0, 0
	.db "j", ".---", 0, 0, 0
	.db "k", "-.-", 0, 0, 0, 0
	.db "l", ".-..", 0, 0, 0
	.db "m", "--", 0, 0, 0, 0, 0
	.db "n", "-.", 0, 0, 0, 0, 0
	.db "o", "---", 0, 0, 0, 0
	.db "p", ".--.", 0, 0, 0
	.db "q", "--.-", 0, 0, 0
	.db "r", ".-.", 0, 0, 0, 0
	.db "s", "...", 0, 0, 0, 0
	.db "t", "-", 0, 0, 0, 0, 0, 0
	.db "u", "..-", 0, 0, 0, 0
	.db "v", "...-", 0, 0, 0
	.db "w", ".--", 0, 0, 0, 0
	.db "x", "-..-", 0, 0, 0
	.db "y", "-.--", 0, 0, 0
	.db "z", "--..", 0, 0, 0
	.db 0, 0, 0, 0, 0, 0, 0, 0

MESSAGE01: .db "a a a", 0
MESSAGE02: .db "sos", 0
MESSAGE03: .db "a box", 0
MESSAGE04: .db "dairy queen", 0
MESSAGE05: .db "the shape of water", 0, 0
MESSAGE06: .db "top gun maverick", 0, 0
MESSAGE07: .db "obi wan kenobi", 0, 0
MESSAGE08: .db "oh canada our own and native land", 0
MESSAGE09: .db "is that your final answer", 0

; First message ever sent by Morse code (in 1844)
MESSAGE10: .db "what god hath wrought", 0


.dseg
.org 0x200
BUFFER01: .byte 128
BUFFER02: .byte 128
TESTBUFFER: .byte 4

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================
