/*  TEST CODE FOR MPU-6050 GYROMETER
 *  
 *  Designer -- Wyatt Tack
 *  
 *  USES I2C to read 2 bytes from 
 *  gyrometer X axis, developed
 *  for waveform analyzing to impliment 
 *  as perefrial on OTTER MCU for
 *  MMIO
 */
#include <Wire.h>
int8_t AccX;
void I2C_signals(void) {
  Wire.beginTransmission(0x68); 
  Wire.write(0x6B);
  Wire.write(0x00);
  Wire.endTransmission();
  Wire.beginTransmission(0x68);
  Wire.write(0x3C); 
  Wire.endTransmission(); 
  Wire.requestFrom(0x68,2);
 AccX = Wire.read() << 8 | Wire.read();
}
void setup() {
  Serial.begin(9600);
  Wire.setClock(100000);
  Wire.begin();
}
void loop() {
  I2C_signals();
  Serial.print("X = "); 
  Serial.println(AccX);
}
