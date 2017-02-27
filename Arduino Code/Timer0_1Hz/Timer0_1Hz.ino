//Created by John Zhu
//Timer Program. It will simply toggle a LED on and off every second

//Timer Registers
//TCCRx - Timer/Counter Control Register. The prescaler can be configured here. 1, 8, 64, 256, 1024
//TCNTx - Timer/Counter Register. The actual timer value is stored here.
//OCRx - Output Compare Register
//ICRx - Input Capture Register (only for 16bit timer) - Timer1
//TIMSKx - Timer/Counter Interrupt Mask Register. To enable/disable timer interrupts.
//TIFRx - Timer/Counter Interrupt Flag Register. Indicates a pending timer interrupt.

// Equations
//(timer speed (Hz)) = (Arduino clock speed (16MHz)) / prescaler
// interrupt frequency (Hz) = (Arduino clock speed 16,000,000Hz) / (prescaler * (compare match register + 1))
// For interrupt frequency of 1 Hz and prescaler of 1024, compare match register = 15624

int x;
void setup(){
	//Clear all interrupts
  Serial.begin(57600);
  
	noInterrupts();           // disable all interrupts
	TCCR1A = 0;				  // Clear both registers
	TCCR1B = 0;
	TCNT1 = 0;				  // Clear timer
	
	// set compare match register for 1hz increments
	//OCR1A = 15624;            // Compare match register
  OCR1A = 3905;            // Compare match register
	TCCR1B |= (1 << WGM12);   // CTC mode
	TCCR1B |= (1 << CS12| 1 << CS10);    // 1024 prescaler 
	TIMSK1 |= (1 << OCIE1A);   // enable timer compare interrupt
	interrupts();             // enable all interrupts
	//Serial.println("Started");
  x = 0;
}

ISR(TIMER1_COMPA_vect)          // timer compare interrupt service routine
{
  while (Serial.available() > 0) {
    char inByte = Serial.read();
    Serial.write(inByte);
    Serial.write(".");
  }
}
void UartSend()
{
  //Need to wrap packet in message buffer
  //dest address,link source address, msg length, groupID, handlerID, source address (ID), packet 
  //LSB
  uint8_t buf[12] = {6,0,1,0,6,0,4,0,0,256,256,0};
  //uint8_t buf[12] = {0,256,256,0,0,4,0,6,0,1,0,6};
  //uint_8_t buf[12] = {0,256,256,0,0,4,0,6,0,1,0,6};
  Serial.write(buf,sizeof(buf));
  //Serial.println((char*)buf);
  /*
  Serial.write(0);
  Serial.write(256);
  Serial.write(256);
  Serial.write(0);
  //Length
  Serial.write(0);
  Serial.write(4);
  Serial.write(0);
  Serial.write(6);
  Serial.write(0);
  Serial.write(1);
  //Packet
  Serial.write(0);
  Serial.write(6);
  */
}
void loop(){
}

