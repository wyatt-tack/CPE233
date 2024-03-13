`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
// 
// Create Date: 03/12/2024 03:28:59 PM
// Design Name: I2C Reading Module Simulation source
// Module Name: I2C_Test
// Project Name: OTTER_MCU_GYRO
// Target Devices: Basys 3 Board, Developed for MPU6050 accelerometer
// Tool Versions: 1.0 Test
// Description: Uses state machine to continoutsly read 2 bytes from I2C module at
//              regAddrR and regAddrR+1, and write 1 byte to regAddrW
//              can be manipultated for other I2C commands later
//              Simulation Source 
//////////////////////////////////////////////////////////////////////////////////


module I2C_Test();
   logic CLK;
   logic SDA, SCL;
//set parameters 
logic [7:0] I2CAddr, regAddrR, regAddrW;
logic [15:0] dataR;
logic [7:0] dataW;
    
    I2C Gyro_Reader ( .clk(CLK), .I2CAddr(I2CAddr), .regAddrR(regAddrR), 
                    .regAddrW(regAddrW), .dataR(dataR), .dataW(dataW),
                    .SDA(SDA), .SCL(SCL));
initial CLK = 1'b0;                    
always begin
#5 CLK = ~CLK;
end                    
always begin
#100
I2CAddr = 8'h68;
regAddrR = 8'h3B;
regAddrW = 8'h6B;
dataW = 8'h00;                
end                    
endmodule
