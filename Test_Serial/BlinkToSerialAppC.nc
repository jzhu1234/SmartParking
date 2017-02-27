#include <Timer.h>
#include "BlinkToSerial.h"

configuration BlinkToSerialAppC {
}
implementation {
  components MainC;
  components LedsC;
  components BlinkToSerialC as App;
  components new TimerMilliC() as Timer0;
  components SerialActiveMessageC;
  components new SerialAMSenderC(AM_BLINKTOSERIAL);
  components new SerialAMReceiverC(AM_BLINKTOSERIAL);

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Packet -> SerialAMSenderC;
  App.AMPacket -> SerialAMSenderC;
  App.AMControl -> SerialActiveMessageC;
  App.AMSend -> SerialAMSenderC;
  App.Receive -> SerialAMReceiverC;
}