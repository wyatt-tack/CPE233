# CPE233_Final
Final Project for CPE-233 at Cal Poly. 
Uses Risc-V ISA on a 32 bit MCU for Both stepper motor control and 
I2C data read/writing for an MPU-6050 accelerometer.
Code written in system verilog for uploading to Basys-3 FPGA breakout
Assembly code written in 32 bit RISC-V ISA (RARS used for assembling to .mem files)

--Gyro uses Specific I2C module
--Stepper uses Specific Stepper motor module
--OTTER_MCU is general project for basic MCU with only Basys-3 included pereferials
	--No Assembly Code provided, but machine code memory file included tests all RISC-V instructions