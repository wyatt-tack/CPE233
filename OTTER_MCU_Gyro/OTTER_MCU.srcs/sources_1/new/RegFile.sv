`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
//
// Create Date: 01/16/2024
// Design Name: RegFile
// Project Name: OTTER MCU
// Target Devices: Basys 3 Board
// Description: Array of 32x32 registers for RAM 
//              on OTTER MCU
//
//////////////////////////////////////////////////////////////

module RegFile(
input en,
input [4:0] adr1,  //two asyncrhonous register reads
input [4:0] adr2,  //and one address, write, and enable
input [4:0] w_adr, //synchronous destination register
input [31:0] w_data,
input clk,
output logic[31:0] rs1,
output logic[31:0] rs2
    );
logic [31:0] RAM [0:31]; //set up 32x32 registers
always_ff@(posedge clk) //write data,
begin                   //functions as register ffs
    if(en == 1)         //syncrhonously
        RAM [w_adr] <= w_data;
end    
always_comb             //asynchronous read from RAM
begin                   //with 0 condition (x0 always = 0)
    if (adr1 != 0)
        rs1 = RAM [adr1];
    else
        rs1 = 0;
    if (adr2 != 0)
        rs2 = RAM [adr2];
    else
        rs2 = 0;    
end        
endmodule
