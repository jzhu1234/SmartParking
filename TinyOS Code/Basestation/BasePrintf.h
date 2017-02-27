#ifndef SENSE_H
#define SENSE_H

enum {
  AM_BLINKTORADIO = 6,
  //UART_QUEUE_LEN = 12,
  RADIO_QUEUE_LEN = 12,
  COUNTER_VALUE = 8,
  NODE_LIST_MAX = 10,
  TIMER_PERIOD_MILLI = 250
};

typedef nx_struct RadioMsg {
  nx_uint16_t nodeid;
  nx_uint8_t state;
} RadioMsg;

#endif
