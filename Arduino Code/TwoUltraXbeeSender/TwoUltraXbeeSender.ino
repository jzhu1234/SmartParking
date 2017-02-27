int trigPin[2] = {39,36};
int echoPin[2] = {37,38};
int VCC[2] = {41,34};
int GND[2] = {35,40};

bool state_A = false;
bool state_B = false;

const int SENSOR_A = 0;
const int SENSOR_B = 1;

void setup(){
  //Setup serial
  Serial.begin(9600);
  
  //Setup Timer
  noInterrupts();           // disable all interrupts
  TCCR1A = 0;         // Clear both registers
  TCCR1B = 0;
  TCNT1 = 0;          // Clear timer
  
  // set compare match register for 1hz increments
  OCR1A = 15624;            // Compare match register
  //OCR1A = 3905;            // Compare match register
  TCCR1B |= (1 << WGM12);   // CTC mode
  TCCR1B |= (1 << CS12| 1 << CS10);    // 1024 prescaler 
  TIMSK1 |= (1 << OCIE1A);   // enable timer compare interrupt
  interrupts();             // enable all interrupts

  //Setup Pins
  int i;
  for(i=0;i<2;i++){
    pinMode(trigPin[i], OUTPUT); // Sets the trigPin as an Output
    pinMode(VCC[i],OUTPUT);
    pinMode(GND[i],OUTPUT);
    pinMode(echoPin[i], INPUT); // Sets the echoPin as an Input
    digitalWrite(VCC[i],HIGH);
    digitalWrite(GND[i],LOW);
  }
}

ISR(TIMER1_COMPA_vect)          // timer compare interrupt service routine
{
  bool state_A_new = Trigger(SENSOR_A);
  bool state_B_new = Trigger(SENSOR_B);

  if(state_A_new != state_A or state_B_new != state_B){
    Serial.print("A");
    if(state_A_new){
      Serial.print("1");
    }
    else{
      Serial.print("0");  
    }
    Serial.print("B");
    if(state_B_new){
      Serial.print("1");
    }
    else{
      Serial.print("0");  
    }
    state_A = state_A_new;
    state_B = state_B_new;
  }
}

bool Trigger(int sensor){
  digitalWrite(trigPin[sensor], LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin[sensor], HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin[sensor], LOW);
  long duration = pulseIn(echoPin[sensor], HIGH);
  int distance = duration*0.034/2;
  if (distance > 65){
    return false;
  }
  else{
    return true;
  }
}
void loop(){
  
}

