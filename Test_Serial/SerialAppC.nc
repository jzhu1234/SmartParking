#include "IRobot.h"

configuration SerialApp{
}
implementation{
	components MainC;
	components SerialActiveMessageC as Serial;
	components LedsC;
	components SerialC as App;
	components Atm128Uart0C as uart; ///opt/tinyos-2.x/tos/chips/atm128
	components new TimerMilliC() as Timer0;
	
	App.Boot -> MainC.Boot;
	App.Leds -> LedsC.Leds;
	App.SerialControl -> Serial;
	App.UartByte -> uart.UartByte;
	App.UartStream -> uart.UartStream;
	App.Timer0 -> Timer0;
	
}