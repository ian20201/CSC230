; main.asm for Hamming assignment
;
; CSC 230: Summer 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-May-18)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (a). In this and other
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
;
; Your task: To compute the Hamming distance between two byte values,
; one in R16, the other in R17. If the first byte is:
;    0b10101101
; and the second byte is:
;    0b10010111
; then the Hamming distance -- that is, the number of corresponding
; bits that are different -- would be 4 (i.e., here bits 5, 4, 3,
; and 1 are different).
;
; In your code, store the computed Hamming-distance value in DISTANCE.
;
; Your solution is free to modify the original values in R16
; and R17.

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========
	ldi r16, 0x8d ;0b10001101
	ldi r17, 0x97 ;0b10010111

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
	.def input1 = r16 ;register r16 as input1
	.def input2 = r17 ;register r17 as input2
	.def solution =  r18 ;defind r18 as solution

	eor r16, r17 ;EXR r16 and r17

	clr r0

countbit:
	lsr r16 ;shift the bit the the end of the right
	breq done ;quit looping  if it is 0
	adc r18, r0 ;add 0 + carry bit
	rjmp countbit 

done:
	adc r18, r0 ;add final shifted 1-bit if appropriate

	sts DISTANCE, r18

; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
stop:
    rjmp stop

    .dseg
    .org 0x202
DISTANCE: .byte 1  ; result of computing Hamming distance of r16 & r17
; ==== END OF "DO NOT TOUCH" SECTION ==========
