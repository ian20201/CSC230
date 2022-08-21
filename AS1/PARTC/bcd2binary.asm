; bcd2binary.asm
; CSC 230: Summer 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-May-18)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (c). In this and other
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
; Your task: Given a binary-coded decimal (BCD) number stored in
; R16, conver this number into the usual binary representation,
; and store in BCD2BINARY.
;

    .cseg
    .org 0

    .equ TEST1=0x99 ; 99 decimal, equivalent to 0b01100011
    .equ TEST2=0x81 ; 81 decimal, equivalent to 0b01010001
	.equ TEST3=0x20 ; 20 decimal, equivalent to 0b00010100
	 
	ldi r16, TEST1

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
	ldi r17, 0b00001111
	ldi r18, 0b11110000
	ldi r19, 0x09

	mov r20, r16 ;copy input into r20

	and r20, r17 ;clear high 4 bit for r20

	and r16, r18 ;clear low 4 bit for the r19

	lsr r16
	lsr r16
	lsr r16
	lsr r16
	//Rotate the r16 4bit to the right

	mov r21, r16 ;copy r16 to r21

multiplying:
	add r16,r21
	dec r19
	breq done;quit looping  if it is 0
	rjmp multiplying
// multiplying 10 times
done:
	add r16, r20
	
	sts BCD2BINARY, r16

; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
end:
	rjmp end


.dseg
.org 0x200
BCD2BINARY: .byte 1
; ==== END OF "DO NOT TOUCH" SECTION ==========
