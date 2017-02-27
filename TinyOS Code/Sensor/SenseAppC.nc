#include "Sense.h"

configuration SenseAppC
{
}
implementation {

  components SenseC as App, MainC, LedsC, new TimerMilliC() as Timer0, new PhotoC() as Sensor;
  components ActiveMessageC;
  components new AMSenderC(AM_BLINKTORADIO);
  components new AMReceiverC(AM_BLINKTORADIO);

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC.Leds;
  App.Timer0 -> Timer0;
  App.Read -> Sensor;
  App.RadioPacket -> AMSenderC.Packet;
  App.RadioAMPacket -> AMSenderC.AMPacket;
  App.RadioSend -> AMSenderC.AMSend;
  App.RadioReceive -> AMReceiverC;
  App.RadioControl -> ActiveMessageC;
}
