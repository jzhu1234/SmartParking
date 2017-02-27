
void setup() {
  Serial.begin(9600);//Remember that the baud must be the same on both arduinos
  Serial.print("A");
}

void loop(){
  while(Serial.available() > 0){
    int a = Serial.read();
    switch(a){
      case 'Z':
        Serial.print("A");
        break;
      default:
        a = a+1;
        Serial.print("B");
        break;
    
    }
  }
}

