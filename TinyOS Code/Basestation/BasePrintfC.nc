#include "printf.h"
#include "BasePrintf.h"
#include "AM.h"

module BasePrintfC @safe() {
  uses {
    interface Boot;
    interface Leds;
    interface Packet;
    interface AMPacket;
    interface AMSend;
    interface Receive;
    interface SplitControl as AMControl;

    //Serial
    interface SplitControl as SerialControl;
    interface AMSend as UartSend[am_id_t id];
    interface Receive as UartReceive[am_id_t id];
    interface Packet as UartPacket;
    interface AMPacket as UartAMPacket;
  }
}
implementation {

  message_t pkt;
  bool busy = FALSE;
  uint16_t nodeidlist[NODE_LIST_MAX];
  //uint16_t parentlist[NODE_LIST_MAX];
  int8_t diechecker[NODE_LIST_MAX];
  int8_t state[NODE_LIST_MAX];
  uint8_t counter[NODE_LIST_MAX];
  uint8_t bufferlength = 0;

  //Declare functions
  void CheckDeath();
  int8_t CheckNodeID(uint16_t nodeid);
  int8_t AddNodeID(uint16_t nodeid);

////////////////////////////////////////////////////////////////////////////////
// User Defined Function
////////////////////////////////////////////////////////////////////////////////
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
  void CheckDeath(){
    uint8_t i;
    uint8_t sum = 0;
    //Calculate total number
    for(i=0;i<NODE_LIST_MAX;i++){
      if(nodeidlist[i] != 0){
        sum += diechecker[i];
      }
    }

    if (sum == bufferlength && sum != 0){
      //Check if there are any zeroes
      for(i=0;i<NODE_LIST_MAX;i++){
        //Dropped or dead node
        if(diechecker[i] == 0){
          printf("Lost Connection with Node %u.\n",nodeidlist[i]);
          //Remove node
          nodeidlist[i] = 0;
          diechecker[i] = -1;
          state[i] = -1;
          counter[i] = 0;
          printfflush();
        }
        else if (diechecker[i] > 0){
          diechecker[i] = 0;
        }
      }
    }
  }
  //Returns TRUE if node is in the list or has been added
  int8_t CheckNodeID(uint16_t nodeid){
    bool present = FALSE;
    uint8_t i;
    for(i=0;i<NODE_LIST_MAX;i++){
      if(nodeidlist[i] == nodeid){
        present = TRUE;
        return i;
      }
	  }
	  if (present == FALSE){
		  i = AddNodeID(nodeid);
		  return i;
	  }
  }
  //Returns true if node has been added. Returns false if not
  int8_t AddNodeID(uint16_t nodeid){
    uint8_t i;
  	for(i=0;i<NODE_LIST_MAX;i++){
  		//Find a free spot. If spot found, initialize components
  		if(nodeidlist[i] == 0){
  			nodeidlist[i] = nodeid;
  			diechecker[i] = 0;
  			state[i] = 0;
        counter[i] = 0;
  			bufferlength++;
  			printf("Parking Space %u has been Added.\n",nodeid);
  			printfflush();
  			return i;
  		}
  	}
  	if (i==NODE_LIST_MAX){
  		printf("Cannot Add Node %u.\n",nodeid);
  		printfflush();
  		return -1;
  	}
  }


////////////////////////////////////////////////////////////////////////////////
// Setup
////////////////////////////////////////////////////////////////////////////////

  event void Boot.booted() {
    uint8_t i;
    for(i=0;i<NODE_LIST_MAX;i++){
      nodeidlist[i] = 0;
      diechecker[i] = -1;
      state[i] = -1;
      counter[i] = 0 ;
    }
    if (call AMControl.start() == EALREADY)
      busy = FALSE;
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call SerialControl.start();
    }
    else {
      call AMControl.start();
    }
  }
  event void AMControl.stopDone(error_t err) {
  }

  event void SerialControl.startDone(error_t err) {
    if (err == SUCCESS) {
      busy = FALSE;
    }
    else {
      call SerialControl.start();
    }
  }
  event void SerialControl.stopDone(error_t err) {
  }

////////////////////////////////////////////////////////////////////////////////
// Radio Communication
////////////////////////////////////////////////////////////////////////////////

  void PrintStates(){
    uint8_t i;
    printf("///////////////////////////////////\n");
    for(i=0;i<NODE_LIST_MAX;i++){
      if(nodeidlist[i] != 0){
        printf("Parking Space %u: ",nodeidlist[i]);
        if(state[i] == 0){
          printf("Empty.\n");
        }
        else if(state[i] == 1){
          printf("Full.\n");
        }
      }
    }
    printf("///////////////////////////////////\n");
    printfflush();
  }
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(RadioMsg)) {
      RadioMsg* btrpkt = (RadioMsg*)payload;
      am_addr_t dest = call AMPacket.destination(msg);
      //Checks to see if node is going to right destination
      if(dest == TOS_NODE_ID){
      //Check if node is in id list. CheckNodeID returns the index value of nodeid in index list
        int8_t index = CheckNodeID(btrpkt->nodeid);
        if(index != -1){
          setLeds(btrpkt->nodeid);
          if(btrpkt->state != state[index]){
    			  counter[index]++;
    			  if(counter[index] == COUNTER_VALUE){
    				  state[index] = btrpkt->state;
    				  counter[index] = 0;
              PrintStates();
    				}
  			  }
          else{
            counter[index] = 0;
          }
          //Check if we need to check if a node has died.
          diechecker[index]++;
          CheckDeath();
  		  }
  	  }
    }
  return msg;
  }
  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }
////////////////////////////////////////////////////////////////////////////////
// Serial Communication
////////////////////////////////////////////////////////////////////////////////
  event message_t *UartReceive.receive[am_id_t id](message_t *msg,void *payload,uint8_t len) {
    atomic{
      if (!busy){
        uint8_t len;
        am_id_t id;
        am_addr_t addr,source;
        len = call UartPacket.payloadLength(msg);
        addr = call UartAMPacket.destination(msg);
        source = call UartAMPacket.source(msg);
        id = call UartAMPacket.type(msg);

        call Packet.clear(msg);
        call AMPacket.setSource(msg, source);

        if (call AMSend.send(addr, msg, len) == SUCCESS){
          printf("Successfully sent package.\n");
          printfflush();
        }
        else{
          printf("Could not send package.\n");
          printfflush();
        }
      }
      return msg;
    }
  }
  event void UartSend.sendDone[am_id_t id](message_t* msg, error_t error) {}
}
