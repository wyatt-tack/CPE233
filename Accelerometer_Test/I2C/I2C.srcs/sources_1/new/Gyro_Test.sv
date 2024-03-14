`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
// 
// Create Date: 03/12/2024 03:28:59 PM
// Module Name: Gyro_Test
// Target Devices: Basys 3 Board, Developed for MPU6050 accelerometer
// Tool Versions: 1.0 Test
// Description: Uses I2C reader to read accelerometer
// 
//////////////////////////////////////////////////////////////////////////////////


module Gyro_Test(
   input CLK,
   output logic SDA, SCL, 
   output [7:0] CATHODES,
   output [3:0] ANODES
    );
   logic [7:0] I2CAddr, regAddrR, regAddrW;
   logic [15:0] dataR;
   logic [7:0] dataW;
   // Set I2C address and specific read address /////////////////////////////
   assign I2CAddr = 8'h68;
   assign regAddrR = 8'h3B;
   assign regAddrW = 8'h6B;
   assign dataW = 8'h00;
   // Declare I2C Gyro Reader ///////////////////////////////////////////////
   I2C Gyro_Reader ( .clk(CLK), .I2CAddr(I2CAddr), .regAddrR(regAddrR), 
                    .regAddrW(regAddrW), .dataR(dataR), .dataW(dataW),
                    .SDA(SDA), .SCL(SCL));
    
   // Declare Seven Segment Display /////////////////////////////////////////
   SevSegDisp SSG_DISP (.DATA_IN(dataR), .CLK(CLK), .MODE(1'b0),
                       .CATHODES(CATHODES), .ANODES(ANODES));    
    
endmodule
