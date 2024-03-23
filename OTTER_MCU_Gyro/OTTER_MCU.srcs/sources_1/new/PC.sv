`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO 
// Engineer: Wyatt Tack
// 
// Create Date: 01/16/2024 
// Design Name: PC Register
// Project Name: OTTER MCU
// Target Devices: Basys 3 Board
// Description: 32 Bit Register for Program Counter
//              on OTTER MCU 
// 
//////////////////////////////////////////////////////////////////////////////////

module PC(
input[31:0] PC_in,
input reset,
input PC_WE,
input clk,
output logic[31:0] PC_count
    );
always_ff@(posedge clk)
    begin
    if (reset == 1)
        PC_count <=0;
    else if (PC_WE == 1)
        PC_count <=PC_in;   
    end
endmodule
