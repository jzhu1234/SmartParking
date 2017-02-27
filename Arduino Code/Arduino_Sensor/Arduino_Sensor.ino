// Test code for Arduino
//Every second, it will read from ultrasound sensor

int trigpins[3] = {};
int echopins[3] = {};

char a;
char str[4] = {'S','B','K','G'};

// False - No Car, True - Car is there
boolean states[3] = {False,False,False};

void setup(){
	//Serial connection
	Serial.begin(9600);
	Serial1.begin(9600);
	Serial2.begin(9600);
	while(!Serial1){
		;
	}
	Serial.println("Serial Ready");
	while(!Serial2){
		;
	}
	Serial.println("Serial 2 Ready");
	}   
	
	//Set up states and pin connections
	sensor1 = False;
	sensor2 = False;
	sensor3 = False;
	for(i=0;i<3;i++){
		pinMode(trigpins[i],OUTPUT);
		pinMode(echopins[i],INPUT);
	}
	
	//Set up interrupts
	noInterrupts();           // disable all interrupts
	TCCR0A = 0;				  // Clear both registers
	TCCR0B = 0;
	TCNT0 = 0;				  // Clear timer
	
	// set compare match register for 1hz increments
	OCR0A = 15624;            // Compare match register
	TCCR0A |= (1 << WGM01);   // CTC mode
	TCCR0B |= (1 << CS02| 1 << CS00);    // 1024 prescaler 
	TIMSK0 |= (1 << OCIE0A);   // enable timer compare interrupt
	interrupts();             // enable all interrupts
	
}

unsigned long ping(int trigpin,int echoPin)
{ 
	long duration, distance;
	digitalWrite(trigPin, LOW);  // Added this line
	delayMicroseconds(2); // Added this line
	digitalWrite(trigPin, HIGH);
	delayMicroseconds(10); // Added this line
	digitalWrite(trigPin, LOW);
	duration = pulseIn(echoPin, HIGH);
	distance = (duration/2) / 29.1;
	if (distance < 10) {  //Centimeters
		Serial.println("Car is here");
		return(True);
	}
	else {
		Serial.println("No car");
		return(False);
	}
	
}

ISR(TIMER0_COMPA_vect)          // timer compare interrupt service routine
{
	boolean states_new[3];
	boolean send = False;  //False-no changes, True- Changes
	for(i=0,i<3;i++){
		states_new[i] = ping(trigpins[i],echopins[i])
		//If there are any changes to state, we want to send it
		if (states_new[i] != states[i]){
			send = True
		}
	}
	if(send){
		int index = rand()%4;
		Serial.print("Sent: ");
		Serial.print(str[index]);
		Serial.print("\t");
		Serial1.write(str[index]);
		delay(50); // Give time for serial to send. Purpose is for debugging
		if (Serial2.available()>0) {
			a = Serial2.read();
			Serial.print("Received: ");
			Serial.print(a);
		}
		Serial.println("");
	}
	
  
}
