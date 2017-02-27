#ifndef SENSE_H
#define SENSE_H

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 250
};

typedef nx_struct RadioMsg {
  nx_uint16_t nodeid;
  nx_uint8_t state;
} RadioMsg;

#endif
