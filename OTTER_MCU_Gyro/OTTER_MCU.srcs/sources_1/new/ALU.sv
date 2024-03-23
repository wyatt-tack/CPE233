`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
//
// Create Date: 01/24/2024
// Design Name: ALU
// Project Name: OTTER MCU
// Target Devices: Basys 3 Board
// Description: Arithmatic Logic Unit, processes functions 
//              on OTTER MCU
//
//////////////////////////////////////////////////////////////

module ALU(
input [31:0] ALU_srcA, 
input [31:0] ALU_srcB,
input [3:0] ALU_FUN,
output logic [31:0] result
);
always_comb
begin
case (ALU_FUN)
    4'b0000: result = ALU_srcA + ALU_srcB; //add
    4'b1000: result = ALU_srcA - ALU_srcB; //sub
    4'b0110: result = ALU_srcA | ALU_srcB; //or
    4'b0111: result = ALU_srcA & ALU_srcB; //and
    4'b0100: result = ALU_srcA ^ ALU_srcB; //xor
    4'b0101: result = ALU_srcA >> ALU_srcB[4:0]; //SRL
    4'b0001: result = ALU_srcA << ALU_srcB[4:0]; //SLL
    4'b1101: result = $signed(ALU_srcA) >>> ALU_srcB[4:0]; //SRA
    4'b0010: if($signed(ALU_srcA) < $signed(ALU_srcB)) 
                    result = 32'h00000001; //SLT
           else result = 32'h00000000;
    4'b0011: if(ALU_srcA < ALU_srcB) 
                    result = 32'h00000001; //SLTU
           else result = 32'h00000000;
    4'b1001: result = ALU_srcA; //LUI-copy
    default: result = 32'hafafbcbc;
endcase
end
endmodule
