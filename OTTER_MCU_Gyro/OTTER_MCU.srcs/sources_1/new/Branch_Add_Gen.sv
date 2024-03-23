`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
//
// Create Date: 02/01/2024
// Design Name: Branch Address Generator
// Project Name: OTTER MCU
// Target Devices: Basys 3 Board
// Description: Generates the jumped to adress based on the  
//              current PC and immediates for Jump types,
//              and RS2
//////////////////////////////////////////////////////////////
module Branch_Add_Gen(
input [31:0] PC, JType, BType, IType, rs1,
output logic [31:0] jal, branch, jalr
);
always_comb 
begin                      //set next program address as what 
    jal = PC + JType;      //each instruction is defined as 
    branch = PC + BType;   //in assember manual   
    jalr = rs1 + IType;      
end    
endmodule
