
void setup() {
  Serial.begin(9600);//Remember that the baud must be the same on both arduinos
}

void loop(){
  while(Serial.available() > 0){
    int a = Serial.read();
    /*
    switch(a){
      case 'A':
        Serial.print("Sensor A: ");
        break;
      case 'B':
        Serial.print("Sensor B: ");
        break;
      case '0':
        Serial.println("Empty.");
        break;
      case '1':
        Serial.println("Full.");
        break;
    }
    */
  }
}

