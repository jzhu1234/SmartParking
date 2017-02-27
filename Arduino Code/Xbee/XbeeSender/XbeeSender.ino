char msg = ' '; //contains the message from arduino sender
const int trigPin = 39;
const int echoPin = 37;
const int VCC = 41;
const int GND = 35;
long duration;
int distance;

void setup() {
  Serial.begin(9600);//Remember that the baud must be the same on both arduinos
  //Pin Modes
  pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
  pinMode(VCC,OUTPUT);
  pinMode(GND,OUTPUT);
  pinMode(echoPin, INPUT); // Sets the echoPin as an Input

  digitalWrite(VCC,HIGH);
  digitalWrite(GND,LOW);
}

void loop() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance= duration*0.034/2;
  //Sensor A
  Serial.print("A");
  if(distance > 70){
    Serial.print("0");
  }
  else{
    Serial.print("1"); 
  }
  delay(1000);
}
