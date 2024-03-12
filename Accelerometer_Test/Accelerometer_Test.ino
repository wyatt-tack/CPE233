

#include <Wire.h>

int16_t AccX, AccY;


void gyro_signals(void) {

  Wire.beginTransmission(0x68);
  Wire.write(0x3B);
  Wire.endTransmission(); 
  Wire.requestFrom(0x68,2); //4 to read from Y
//  int16_t AccXLSB = Wire.read() << 8 | Wire.read();
//  int16_t AccYLSB = Wire.read() << 8 | Wire.read();
 AccX = Wire.read() << 8 | Wire.read();
 //AccY = Wire.read() << 8 | Wire.read();


//  AccX=(float)AccX*90/4096;
//  AccY=(float)AccYLSB/4096;

}
void setup() {
  Serial.begin(57600);

  Wire.setClock(400000);
  Wire.begin();

}
void loop() {
  gyro_signals();
  Serial.print("X = "); 
  Serial.println(AccX);
  //Serial.println(AccX, HEX);
  //Serial.print("  Y = ");
  //Serial.println(AccY, HEX);
  delay(50);
}
