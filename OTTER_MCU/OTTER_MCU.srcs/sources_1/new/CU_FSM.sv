`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
//
// Create Date: 02/01/2024
// Design Name: Control Unit FSM
// Project Name: OTTER MCU
// Target Devices: Basys 3 Board
// Description: Sends selection signals for timing specific
//              operations in memory of OTTER MCU
//
////////////////////////////////////////////////////////////


module CU_FSM(
input RST, clk,
input INTR,
input [31:0] ir,
output logic PC_WE, RF_WE, memWE2, memRDEN1, memRDEN2, reset,   
output logic csr_WE, int_taken, mret_exec
    );
typedef enum {ST_INIT, ST_FETCH, ST_EXEC, ST_WRITE, ST_INTR} state_type;
state_type NS, PS;
always_ff@(posedge clk) begin //state register
    if(RST == 1) PS<=ST_INIT;
    else PS<=NS;
end    
always_comb begin //input/output logic  
    PC_WE = 0; 
    RF_WE = 0;
    memWE2 = 0;
    memRDEN1 = 0;
    memRDEN2 = 0;
    reset = 0;
    csr_WE = 0;
    int_taken = 0; 
    mret_exec = 0;        
case(PS)
    ST_INIT: begin    
    reset = 1'b1;
    NS = ST_FETCH;
    end
    ST_FETCH: begin
    memRDEN1 = 1'b1;
    NS = ST_EXEC;
    end
    ST_EXEC: begin
        case (ir[6:0]) //op-codes
        7'b0110011: //All R-Type
        begin
            PC_WE = 1; 
            RF_WE = 1;
        end
        7'b0010011: //1st set of I-Type Instructions
        begin
            PC_WE = 1; 
            RF_WE = 1;  
        end
        7'b0000011: //2nd set of I-Type Instructions
        begin
            memRDEN2 = 1;
        end
        7'b1100111: //Last set of I-Type (for jalr)
        begin
            PC_WE = 1; 
            RF_WE = 1; 
        end
        7'b0100011: //All S-Type Instructions
        begin
            PC_WE = 1; 
            memWE2 = 1;          
        end
        7'b1100011: //All B-Type Instructions (include conditions)
        begin
            PC_WE = 1; 
        end
        7'b0110111: //1st set of U-Type (lui)
        begin     
            PC_WE = 1; 
            RF_WE = 1;
        end
        7'b0010111: //2nd set of U-Type (auipc)
        begin   
            PC_WE = 1; 
            RF_WE = 1;
        end
        7'b1101111: //All J-Type instructions (jal)    
        begin    
            PC_WE = 1; 
            RF_WE = 1; 
        end
        7'b1110011: //All CSR instructions 
        begin
            PC_WE = 1;
            if(ir[14:12] == 3'b000)mret_exec = 1'b1;
            else begin
            csr_WE = 1;
            RF_WE = 1; 
            end
        end
        endcase
        
        //state selecter
        if (INTR == 1 && ir[6:0] != 7'b0000011) NS = ST_INTR;//!load+INTR=>INTR
        else if(ir[6:0] == 7'b0000011) NS = ST_WRITE;        //load=>WRITEBACK
        else NS = ST_FETCH;                                  //!load+!INTR=>FETCH
    end
    ST_WRITE: begin
        //state calculator
        if(INTR == 1)NS = ST_INTR;
        else NS = ST_FETCH;
        PC_WE = 1;
        RF_WE = 1;
    end  
    ST_INTR: begin
    int_taken = 1;
    PC_WE = 1;
    NS = ST_FETCH;   
    end
    default: begin
    NS = ST_INIT;
    end  
endcase      
end    
endmodule
