
char a;
char str[4] = {'S','B','K','G'};
void setup(){
  Serial.begin(9600);
  Serial1.begin(9600);
  Serial2.begin(9600);
  while(!Serial){
    ;
  }
  Serial.println("Serial Ready");
  while(!Serial2){
    ;
  }
  Serial.println("Serial 2 Ready");
}   

void loop() {
 
  //Send character from serial to serial1
  int index = rand()%4;
  Serial.print("Sent: ");
  Serial.print(str[index]);
  Serial.print("\t");
  Serial1.write(str[index]);
  delay(100);
  if (Serial2.available()>0) {
    delay(100); //allows all serial sent to be received together
    a = Serial2.read();
    Serial.print("Received: ");
    Serial.print(a);
  }
  Serial.println("");
  delay(1000);
}   
  


