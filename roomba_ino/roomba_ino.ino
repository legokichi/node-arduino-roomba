#include <SoftwareSerial.h>;
SoftwareSerial device(10, 11);

void setup(){
  Serial.begin(9600);
  device.begin(115200);
}

void loop(){
  if(Serial.available() > 0){
    int cmd = Serial.read();
    Serial.write(cmd);
    switch(cmd){
      case 48: motor( 64,  64); break;
      case 49: motor( 64, -64); break;
      case 50: motor(-64,  64); break;
      case 51: motor(-64, -64); break;
      default: motor(  0,   0); break;
    }
  }else{
    motor(0, 0);
  }
  delay(100);
}

void motor(int l, int r){
  byte buffer[] = {
    byte(128), // Start
    byte(132), // FULL
    byte(146), // Drive PWM
    byte(r>>8),
    byte(r),
    byte(l>>8),
    byte(l)
  };
  device.write(buffer, 7);
}
