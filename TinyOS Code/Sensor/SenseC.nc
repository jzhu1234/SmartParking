
#include "Timer.h"
#include "Sense.h"

module SenseC
{
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli> as Timer0;
    interface Read<uint16_t>;
    interface Packet as RadioPacket;
    interface AMPacket as RadioAMPacket;
    interface AMSend as RadioSend;
    interface Receive as RadioReceive;
    interface SplitControl as RadioControl;
  }
}
implementation
{
  // sampling frequency in binary milliseconds
  uint8_t space_full = 0;
  message_t pkt;
  bool busy = FALSE;
  uint8_t my_parent;

  // Radio Buffer
  enum {
      RADIO_QUEUE_LEN = 12,
  };
  message_t  radioQueueBufs[RADIO_QUEUE_LEN];
  message_t  * ONE_NOK radioQueue[RADIO_QUEUE_LEN];
  uint8_t    radioIn, radioOut;
  bool       radioBusy, radioFull;

  //task void RadioSendTask();
  //Leds
  void DropBlink() {
    call Leds.led2Toggle();
  }
  void FailBlink() {
    call Leds.led0Toggle();
  }
  void SendBlink() {
    call Leds.led1Toggle();
  }
  // Parent Function
  uint8_t GetMyParent(uint8_t nodeid)
  {
      uint8_t parent = -1;

      switch (nodeid)
      {
        case 2:
        case 3:
          parent = 1;
          break;
        case 4:
        case 5:
          parent = 3;
          break;
        default:
          parent = 1;
          break;
      }
      return parent;
  }
  //task void RadioSendTask() {
  void RadioSendFunc(){
    uint8_t len;
    am_addr_t addr;
    message_t* msg;
    RadioMsg *btrpkt;

    atomic{
      if (radioIn == radioOut && !radioFull){
        radioBusy = FALSE;
        return;
      }
      msg = radioQueue[radioOut];

      btrpkt = (RadioMsg*) (call RadioPacket.getPayload(radioQueue[radioOut], sizeof (RadioMsg)));
      len = call RadioPacket.payloadLength(msg);
      addr = call RadioAMPacket.destination(msg);
      if (call RadioSend.send(addr, msg, len) == SUCCESS){
        SendBlink();
      }
      else
      {
        FailBlink();
        RadioSendFunc();
      }
    }
  }
  // Queue Stuff
  message_t* QueueIt(message_t *msg, void *payload, uint8_t len)
  {
    message_t *ret = msg;
    atomic{
      if (!radioFull){
        ret = radioQueue[radioIn];
        radioQueue[radioIn] = msg;
        radioIn = (radioIn + 1) % RADIO_QUEUE_LEN;
        if (radioIn == radioOut){
          radioFull = TRUE;
        }
        if (!radioBusy){
          RadioSendFunc();
          radioBusy = TRUE;
        }
      }
      else{
        DropBlink();
      }
    }
    return ret;
  }
  //Events
  event void Boot.booted() {
    uint8_t i;
    my_parent = GetMyParent (TOS_NODE_ID);
    for (i = 0; i < RADIO_QUEUE_LEN; i++)
        radioQueue[i] = &radioQueueBufs[i];
    radioIn = radioOut = 0;
    radioBusy = FALSE;
    radioFull = TRUE;

    call RadioControl.start();
  }
  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      radioFull = FALSE;
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call RadioControl.start();
    }
  }
  event void RadioControl.stopDone(error_t err){}

  event void Timer0.fired(){
    atomic{
      //Generate Data
      call Read.read();
    }
  }
  event void Read.readDone(error_t result, uint16_t data){
    atomic{
      if (result == SUCCESS){
        if (!radioFull)
        {
          message_t* msg;
          RadioMsg * btrpkt;
          msg = radioQueue[radioIn];
          btrpkt = (RadioMsg*) (call RadioPacket.getPayload(msg, sizeof (RadioMsg)));
          btrpkt->nodeid = TOS_NODE_ID;
          //btrpkt->destid = my_parent;
          if (data > 450){
            btrpkt->state = 0;
          }
          else{
            btrpkt->state = 1;
          }
          //Set packet header data. These info will be adjusted in each hop
          call RadioPacket.setPayloadLength(msg, sizeof (RadioMsg));
          call RadioAMPacket.setDestination(msg, my_parent);
          call RadioAMPacket.setSource(msg, TOS_NODE_ID);

          ++radioIn;
          if(radioIn >=RADIO_QUEUE_LEN)
            radioIn=0;
          if(radioIn == radioOut)
            radioFull = TRUE;
          if (!radioBusy){
            radioBusy = TRUE;
            RadioSendFunc();
          }
        }
        else{
          DropBlink();
        }
      }
    }
  }
  event void RadioSend.sendDone(message_t* msg, error_t error) {
    if (error != SUCCESS)
      FailBlink();
    else
      atomic
      if (msg == radioQueue[radioOut])
      {
        if (++radioOut >= RADIO_QUEUE_LEN)
          radioOut = 0;
        if (radioFull)
          radioFull = FALSE;
      }
      RadioSendFunc();
      //post RadioSendTask();
  }
  event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len){
    atomic{
      if (len == sizeof(RadioMsg)){
        RadioMsg* btrpkt = (RadioMsg*)payload;
        am_addr_t dest = call RadioAMPacket.destination(msg);
        am_addr_t source = call RadioAMPacket.source(msg);
        if (TOS_NODE_ID ==  dest){
          //Check if its from base station
          if(source == 1){
            my_parent = btrpkt->nodeid;
          }
          else{
            call RadioAMPacket.setDestination(msg, my_parent);
            call RadioAMPacket.setSource(msg, TOS_NODE_ID);
            msg = QueueIt(msg, payload, len);
          }
        }
        else{
          DropBlink();
        }
      }
      return msg;
    }
  }
}
