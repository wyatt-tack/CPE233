`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
//
// Create Date: 02/01/2024
// Design Name: Branch Condition Generator
// Project Name: OTTER MCU
// Target Devices: Basys 3 Board
// Description: Generates the 3 conditions between rs1 and rs2 
//              being =, <, and < Signed on OTTER MCU
//
//////////////////////////////////////////////////////////////

module Branch_Cond_Gen(
input [31:0] rs1, rs2,
output logic br_eq, br_lt, br_ltu
    );
always_comb //combinational block, set conditonals to binary
begin       //true/false based on evaluation:
  br_eq = (rs1 == rs2);
  br_lt = ($signed(rs1) < $signed(rs2));
  br_ltu = (rs1 < rs2); 
end    
endmodule
