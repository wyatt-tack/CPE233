`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
//
// Create Date: 02/07/2024
// Design Name: OTTER MCU Test Bench
// Project Name: OTTER MCU
// Target Devices: Basys 3 Board
// Description: OTTER Microprocessor simulation source
//              
//
////////////////////////////////////////////////////////////

module OTTER_MCU_TB();
logic RST, CLK;
logic INTR;
logic [31:0] IOBUS_IN;
logic IOBUS_WR;
logic [31:0] IOBUS_OUT, IOBUS_ADDR;

OTTER_MCU UUT (.RST(RST), .CLK(CLK), .IOBUS_IN(IOBUS_IN), 
    .IOBUS_WR(IOBUS_WR), .IOBUS_OUT(IOBUS_OUT), 
    .IOBUS_ADDR(IOBUS_ADDR), .INTR(INTR));
always begin
#5
CLK = 0;
#5
CLK = 1;
end
always begin
#10
INTR = 0;
IOBUS_IN = 1;
RST = 1;
#10;
RST = 0;
#600;
INTR = 1;
#50;
INTR = 0;
#1000000;    
end
endmodule
