#ifndef BLINKTOSERIAL_H
#define BLINKTOSERIAL_H

enum {
  AM_BLINKTOSERIAL = 6,
  TIMER_PERIOD_MILLI = 250
};

typedef nx_struct BlinkToSerialMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} BlinkToSerialMsg;

#endif