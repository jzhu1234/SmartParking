
void setup() {
  Serial.begin(9600);//Remember that the baud must be the same on both arduinos
  
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
        Serial.print(a);
        break;
    
    }
  }
}

