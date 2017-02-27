/*
* Ultrasonic Sensor HC-SR04 and Arduino Tutorial
*
* Crated by Dejan Nedelkovski,
* www.HowToMechatronics.com
*
*/
// defines pins numbers
const int trigPin = 12;
const int echoPin = 11;
const int trigPin1 = 3;
const int echoPin1 = 2;
const int trigPin2 = 39;
const int echoPin2 = 37;
// defines variables
long duration;
int distance;
long durationn;
int distance1;
long durationnn;
int distance2;
void setup() {
pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
pinMode(echoPin, INPUT); // Sets the echoPin as an Input
pinMode(trigPin1, OUTPUT); // Sets the trigPin as an Output
pinMode(echoPin1, INPUT); // Sets the echoPin as an Input
pinMode(trigPin2, OUTPUT); // Sets the trigPin as an Output
pinMode(echoPin2, INPUT); // Sets the echoPin as an Input
pinMode(41,OUTPUT);
pinMode(35,OUTPUT);
digitalWrite(41,HIGH);
digitalWrite(35,LOW);
Serial.begin(9600); // Starts the serial communication
}
void loop() {
// Clears the trigPin
digitalWrite(trigPin, LOW);
delayMicroseconds(2);
// Sets the trigPin on HIGH state for 10 micro seconds
digitalWrite(trigPin, HIGH);

delayMicroseconds(10);
digitalWrite(trigPin, LOW);

// Reads the echoPin, returns the sound wave travel time in microseconds
duration = pulseIn(echoPin, HIGH);
distance= duration*0.034/2;
Serial.print("Distance: ");
Serial.println(distance);

delayMicroseconds(20);

digitalWrite(trigPin1, LOW);

delayMicroseconds(2);
// Sets the trigPin on HIGH state for 10 micro seconds

digitalWrite(trigPin1, HIGH);
delayMicroseconds(10);

digitalWrite(trigPin1, LOW);
durationn = pulseIn(echoPin1, HIGH);

// Calculating the distance

distance1= durationn*0.034/2;
// Prints the distance on the Serial Monitor

Serial.print("DISTANCE: ");
Serial.println(distance1);

delayMicroseconds(20);

digitalWrite(trigPin2, LOW);

delayMicroseconds(2);
// Sets the trigPin on HIGH state for 10 micro seconds
digitalWrite(trigPin2, HIGH);

delayMicroseconds(10);
digitalWrite(trigPin2, LOW);

// Reads the echoPin, returns the sound wave travel time in microseconds
durationnn = pulseIn(echoPin2, HIGH);
distance2= durationnn*0.034/2;
Serial.print("Dist: ");
Serial.println(distance2);

delayMicroseconds(20);
}
