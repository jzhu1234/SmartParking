void setup() {
  // put your setup code here, to run once:
  Serial.begin(57600,SERIAL_8O1);
}

void loop() {
  // put your main code here, to run repeatedly:
  if(Serial.available()){
    int a = Serial.read();
    Serial.println(a);  
  }
}

