#include "AM.h"
#include "Serial.h"
#include "IRobot.h"

module SerialC {
	uses {
		interface Boot;
		interface Leds;
		interface Timer<TMilli> as Timer0;
		interface SplitControl as SerialControl; //to start and stop serial section of system
		interface UartByte; //for sending and receiving one byte at a time -- no interrupts here
		interface UartStream; //multiple byte send and receive, byte level receive interrupt

	}
}
implementation {
	
	uint8_t counter;
	
	void setLeds(uint16_t val) {
		if (val & 0x01)
		  call Leds.led0On();
		else 
		  call Leds.led0Off();
		if (val & 0x02)
		  call Leds.led1On();
		else
		  call Leds.led1Off();
		if (val & 0x04)
		  call Leds.led2On();
		else
		  call Leds.led2Off();
	}
	
	event void Boot.booted() {
		uartIn = uartOut = 0;
		uartBusy = FALSE;
		uartFull = TRUE;
		
		counter = 0;
		
		call SerialControl.start()
	}
	
	event SerialControl.startDone(){
		if(error == SUCCESS) {
			uartFull = FALSE;
			//Start Timer0
			call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
		}
		else {
			call SerialControl.start();//try again
		}
	}
	event void Timer0.fired(){
		//Everytime Timer0 is fired, we update counter and sent that through UART
		if (!uartBusy) {
			//Update counter
			counter++;
			if(call(UartStream.send(&counter, 1)) == SUCCESS){
				uartBusy = TRUE;
			}	
		}
	}
	
	async event void UartStream.sendDone(uint8_t * buf, uint16_t len, error_t error) {
		if(error != FAIL) {
			uartBusy = FALSE;
			}
		}
	}
	
	async event void UartStream.receivedByte(uint8_t byte) {
		setLeds(byte);
	}

	