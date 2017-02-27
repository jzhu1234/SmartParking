#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "BasePrintf.h"

configuration BasePrintfAppC{
}
implementation {
  components MainC, PrintfC, BasePrintfC, SerialStartC;
  components LedsC;
  //components new TimerMilliC();
  components ActiveMessageC,SerialActiveMessageC as Serial;
  components new AMReceiverC(AM_BLINKTORADIO);
  components new AMSenderC(AM_BLINKTORADIO);

  BasePrintfC.Boot -> MainC;
  BasePrintfC.Leds -> LedsC;

  BasePrintfC.Packet -> AMSenderC;
  BasePrintfC.AMPacket -> AMSenderC;
  BasePrintfC.AMControl -> ActiveMessageC;
  BasePrintfC.AMSend -> AMSenderC;
  BasePrintfC.Receive -> AMReceiverC;

  //Serial
  BasePrintfC.SerialControl -> Serial;
  BasePrintfC.UartSend -> Serial;
  BasePrintfC.UartReceive -> Serial.Receive;
  BasePrintfC.UartPacket -> Serial;
  BasePrintfC.UartAMPacket -> Serial;


  //BasePrintfC.Timer -> TimerMilliC;
}
