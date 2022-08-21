; reverse.asm
; CSC 230: Summer 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-May-18)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (b). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: To reverse the bits in the word IN1:IN2 and to store the
; result in OUT1:OUT2. For example, if the word stored in IN1:IN2 is
; 0xA174, then reversing the bits will yield the value 0x2E85 to be
; stored in OUT1:OUT2.

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
    ; These first lines store a word into IN1:IN2. You may
    ; change the value of the word as part of your coding and
    ; testing.
    ;
    ldi R16, 0x74
    sts IN1, R16
    ldi R18, 0xA1
    sts IN2, R18
    
    ; This code only swaps the order of the bytes from the
    ; input word to the output word. This clearly isn't enough
    ; so you may modify or delete these lines as you wish.
    ;
	lds R16, IN1
	

	ldi r17, 0x00 ;set r17 to be 0
	ldi r19, 0x00 ;set r19 to be 0
	ldi r20, 0x08

shifting:
	lsr r16	
	adc r17, r0 
	dec r20 ;conter -1
	breq end ;quit looping  if it is 0
	rol r17
	rjmp shifting


end:
	sts OUT2, R17
//End of the first shifting

    lds R18, IN2
	ldi r20, 0x08

	CLZ 

shifting2:
	lsr r18	
	adc r19, r0 
	dec r20 ;conter -1
	breq end2;quit looping  if it is 0
	rol r19
	rjmp shifting2


end2:
	sts OUT1, R19
//End of the second shifting

; **** END OF "STUDENT CODE" SECTION ********** 



; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
stop:
    rjmp stop

    .dseg
    .org 0x200
IN1:	.byte 1
IN2:	.byte 1
OUT1:	.byte 1
OUT2:	.byte 1
; ==== END OF "DO NOT TOUCH" SECTION ==========
