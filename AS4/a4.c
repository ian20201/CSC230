/* a4.c
 * CSC Summer 2022
 * 
 * Student name:
 * Student UVic ID:
 * Date of completed work:
 *
 *
 * Code provided for Assignment #4
 *
 * Author: Mike Zastre (2022-Jul-19)
 *
 * This skeleton of a C language program is provided to help you
 * begin the programming tasks for A#4. As with the previous
 * assignments, there are "DO NOT TOUCH" sections. You are *not* to
 * modify the lines within these section.
 *
 * You are also NOT to introduce any new program-or file-scope
 * variables (i.e., ALL of your variables must be local variables).
 * YOU MAY, however, read from and write to the existing program- and
 * file-scope variables. Note: "global" variables are program-
 * and file-scope variables.
 *
 * UNAPPROVED CHANGES to "DO NOT TOUCH" sections could result in
 * either incorrect code execution during assignment evaluation, or
 * perhaps even code that cannot be compiled.  The resulting mark may
 * be zero.
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

#define __DELAY_BACKWARD_COMPATIBLE__ 1
#define F_CPU 16000000UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define DELAY1 0.000001
#define DELAY3 0.01

#define PRESCALE_DIV1 8
#define PRESCALE_DIV3 64
#define TOP1 ((int)(0.5 + (F_CPU/PRESCALE_DIV1*DELAY1))) 
#define TOP3 ((int)(0.5 + (F_CPU/PRESCALE_DIV3*DELAY3)))

#define PWM_PERIOD ((long int)500)

volatile long int count = 0;
volatile long int slow_count = 0;


ISR(TIMER1_COMPA_vect) {
	count++;
}


ISR(TIMER3_COMPA_vect) {
	slow_count += 5;
}

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */

void led_state(uint8_t LED, uint8_t state) {
	if(state){
		if(LED == 0)
			PORTL |= 0b10000000; //Turn on the First LED light
		else if(LED == 1)
			PORTL |= 0b00100000; //Turn on the Second LED light
		else if(LED == 2)
			PORTL |= 0b00001000; //Turn on the Third LED light
		else if(LED == 3)
			PORTL |= 0b00000010; //Turn on the Fourth LED light
		else if(LED == 0xf)
			PORTL |= 0b10101010; //Turn on All Four LED light	
	}
	else{
		if(LED == 0)
			PORTL &= ~(0b10000000); //Turn off the First LED light
		else if(LED == 1)
			PORTL &= ~(0b00100000); //Turn off the Second LED light
		else if(LED == 2)
			PORTL &= ~(0b00001000); //Turn off the Third LED light
		else if(LED == 3)
			PORTL &= ~(0b00000010); //Turn off the Fourth LED light
	}
}



void SOS() {
    uint8_t light[] = {
        0x1, 0, 0x1, 0, 0x1, 0,
        0xf, 0, 0xf, 0, 0xf, 0,
        0x1, 0, 0x1, 0, 0x1, 0,
        0x0
    };

    int duration[] = {
        100, 250, 100, 250, 100, 500,
        250, 250, 250, 250, 250, 500,
        100, 250, 100, 250, 100, 250,
        250
    };

	int length = 19;
	
	for(int i = 0; i < length; i++){
		
		if(light[i] == 0x1 || light[i] == 0x2 || light[i] == 0x3 || light[i] == 0x4) //if the light array return 0x01 then call the led_state function to light up ONE light for the dot
			led_state(light[i]-1,light[i]);
		else if(light[i] == 0xf) //if the light array return 0x0f then call the led_state function to light up FOUR light for the dash
			led_state(light[i],light[i]); 
		else if(light[i] == 0) //if the light array return 0 then turn off all the light
			PORTL &= ~(0b10101010); //Turn off All Four LED light
			
		_delay_ms(duration[i]); // call the delay base on the return value from the duration[]
	}
	
}


void glow(uint8_t LED, float brightness) {
	int threshold = PWM_PERIOD * brightness;
	for(;;){
		if(count < threshold){
			led_state(LED,1);
		}else if(count < PWM_PERIOD){
			led_state(LED,0);
		}else{
			count = 0;
			led_state(LED,1);
		}
	}
}



void pulse_glow(uint8_t LED) {
	float brightness = 0;
	int status = 0;
	int threshold;
	for(;;){
		
		threshold = PWM_PERIOD * brightness;
	
		if(status == 0)
		{
			slow_count = 0;
			while(slow_count < PWM_PERIOD){
				if(count < threshold){
					led_state(LED,1);
				}else if(count < PWM_PERIOD){
					led_state(LED,0);
				}else{
					count = 0;							
					led_state(LED,1);
				}
			}
			
			if(brightness >= 1){
				status = 1;
				slow_count = 0;
			}else if(brightness < 1){
				brightness = brightness + 0.1;
			}
				
		}
		
		else if(status == 1){
			slow_count = 0;
			while(slow_count < PWM_PERIOD){
				if(count < threshold){
					led_state(LED,1);
					}else if(count < PWM_PERIOD){
					led_state(LED,0);
					}else{
					count = 0;
					led_state(LED,1);
				}
			}
			
			
			if(brightness <= 0){
				status = 0;
				slow_count = 0;
			}else if(brightness > 0){
				brightness = brightness - 0.1;
			}
						
		}
	
	}
}


void light_show() {
	    uint8_t light[] = {
		    0xf, 0, 0xf, 0, 0xf, 0,
			0x2, 0x3, 0,
			0x1, 0x4, 0,
		    0xf, 0, 0xf, 0, 0xf, 0, 
			0x1, 0x4, 0,
			0x2, 0x3, 0,
		    0x4, 0x3, 0, 0x3, 0x2, 0, 0x2, 0x1, 0, 0x1,
		    0x1, 0x2, 0, 0x2, 0x3, 0, 0x3, 0x4, 0, 0x4,
		    0x4, 0x3, 0, 0x3, 0x2, 0, 0x2, 0x1, 0, 0x1,
		    0x1, 0x2, 0, 0x2, 0x3, 0, 0x3, 0x4, 0, 0x4, 0,
		    0xf, 0, 0xf, 0,
			0x2, 0x3, 0,
			0x2, 0x3, 0,
			0x00
	    };
		
	    int duration[] = {
			150, 250, 150, 250, 150, 250,
			0, 100, 150,
			0, 100, 150,
			150, 250, 150, 250, 150, 250,
			0, 100, 150,
			0, 100, 150,
			50, 50, 0, 0, 50, 0, 0, 50, 0, 50,
			50, 50, 0, 0, 50, 0, 0, 50, 0, 50,
			50, 50, 0, 0, 50, 0, 0, 50, 0, 50,
			50, 50, 0, 0, 50, 0, 0, 50, 0, 50, 250,
			150, 250, 150, 250,
			0, 100, 50,
			0, 100, 50,
			250			  			
	    };

	    int length = 76;
	    
	for(int i = 0; i < length; i++){
		
		if(light[i] == 0x1 || light[i] == 0x2 || light[i] == 0x3 || light[i] == 0x4) //if the light array return 0x01 then call the led_state function to light up ONE light for the dot
		led_state(light[i]-1,light[i]);
		else if(light[i] == 0xf) //if the light array return 0x0f then call the led_state function to light up FOUR light for the dash
		led_state(light[i],light[i]);
		else if(light[i] == 0) //if the light array return 0 then turn off all the light
		PORTL &= ~(0b10101010); //Turn off All Four LED light

			
		_delay_ms(duration[i]); // call the delay base on the return value from the duration[]
	}
}


/* ***************************************************
 * **** END OF FIRST "STUDENT CODE" SECTION **********
 * ***************************************************
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

int main() {
    /* Turn off global interrupts while setting up timers. */

	cli();

	/* Set up timer 1, i.e., an interrupt every 1 microsecond. */
	OCR1A = TOP1;
	TCCR1A = 0;
	TCCR1B = 0;
	TCCR1B |= (1 << WGM12);
    /* Next two lines provide a prescaler value of 8. */
	TCCR1B |= (1 << CS11);
	TCCR1B |= (1 << CS10);
	TIMSK1 |= (1 << OCIE1A);

	/* Set up timer 3, i.e., an interrupt every 10 milliseconds. */
	OCR3A = TOP3;
	TCCR3A = 0;
	TCCR3B = 0;
	TCCR3B |= (1 << WGM32);
    /* Next line provides a prescaler value of 64. */
	TCCR3B |= (1 << CS31);
	TIMSK3 |= (1 << OCIE3A);


	/* Turn on global interrupts */
	sei();
	

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */

/* This code could be used to test your work for part A.

	led_state(0, 1);
	_delay_ms(1000);
	led_state(2, 1);
	_delay_ms(1000);
	led_state(1, 1);
	_delay_ms(1000);
	led_state(2, 0);
	_delay_ms(1000);
	led_state(0, 0);
	_delay_ms(1000);
	led_state(1, 0);
	_delay_ms(1000);
*/

/* This code could be used to test your work for part B.

	SOS();
*/

/* This code could be used to test your work for part C.

	glow(2, 0.01);
*/

/* This code could be used to test your work for part D.

	pulse_glow(3);
*/ 


/* This code could be used to test your work for the bonus part.

	light_show();
*/

/* ****************************************************
 * **** END OF SECOND "STUDENT CODE" SECTION **********
 * ****************************************************
 */
}
