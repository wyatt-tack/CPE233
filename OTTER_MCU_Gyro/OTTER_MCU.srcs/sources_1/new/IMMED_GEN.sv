`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
//
// Create Date: 01/24/2024
// Design Name: IMMED_GEN
// Project Name: OTTER MCU
// Target Devices: Basys 3 Board
// Description: Generates Immediate numbers needed from
//              different instruction types in assembly
//
//////////////////////////////////////////////////////////////
module IMMED_GEN(
input [31:0] Instruction, //full machine code
output [31:0] U_Type, I_Type, S_Type, J_Type, B_Type
    ); //5 assignments of concatination for different types
assign U_Type = {Instruction[31:12], {12{1'b0}}};    
assign I_Type = {{21{Instruction[31]}}, Instruction[30:20]};     
assign S_Type = {{21{Instruction[31]}}, Instruction[30:25], 
                    Instruction[11:7]};      
assign J_Type = {{12{Instruction[31]}}, Instruction[19:12], Instruction[20], 
                    Instruction[30:21], 1'b0};     
assign B_Type = {{20{Instruction[31]}}, Instruction[7], Instruction[30:25], 
                    Instruction[11:8], 1'b0};     
endmodule
