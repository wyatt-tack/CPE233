`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
//
// Create Date: 02/29/2024
// Design Name: Control Status Registers
// Project Name: OTTER MCU
// Target Devices: Basys 3 Board
// Description: Registers that hold data for interupts
//              
////////////////////////////////////////////////////////////

module CSR(
input clk,
input reset, mret_exec, int_taken, csr_WE,
input [31:0] ir, PC, WD,
output logic[31:0] CSR_mstatus, CSR_mepc, CSR_mtvec, 
output logic[31:0] csr_RD
    );

always_ff@(posedge clk) 
begin                  
    if(csr_WE == 1)      //write data synchronously
        begin
        case(ir[31:20])
        12'h305: CSR_mtvec <= WD;
        12'h341: CSR_mepc <= WD;        
        12'h300: CSR_mstatus <= WD;
        endcase
        end
    if(int_taken == 1)  //when interupt
        begin
        CSR_mepc <= PC;
        CSR_mstatus[7] <= CSR_mstatus[3];
        CSR_mstatus[3] <= 1'b0;
        end
    if(reset == 1)      //if reset
        begin
        CSR_mtvec <= 0;
        CSR_mepc <= 0;        
        CSR_mstatus <= 0;
        end
    if(mret_exec == 1)  //when intr end, reset status enable
        begin
        CSR_mstatus[3] <= CSR_mstatus[7];
        CSR_mstatus[7] <= 1'b0;
        end   
end 
always_comb begin      
    case(ir[31:20])     //output asynch read
        12'h305: csr_RD = CSR_mtvec;
        12'h341: csr_RD = CSR_mepc;        
        12'h300: csr_RD = CSR_mstatus;
        default: csr_RD = 0;
    endcase    
 
 
end    
endmodule
