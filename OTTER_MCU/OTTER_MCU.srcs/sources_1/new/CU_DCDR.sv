`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
//
// Create Date: 02/01/2024
// Design Name: Control Unit Decoder
// Project Name: OTTER MCU
// Target Devices: Basys 3 Board
// Description: Sends non timing dependent selection signals
//              for data manipulation in otter MCU
//
////////////////////////////////////////////////////////////

module CU_DCDR(
input [31:0] ir,
input br_eq, br_lt, br_ltu,
input int_taken,
output logic [3:0] ALU_FUN,
output logic [1:0] srcA_SEL,
output logic [2:0] srcB_SEL,
output logic [2:0] PC_SEL,
output logic [1:0] RF_SEL
    );
always_comb begin 
    ALU_FUN = 0;
    srcA_SEL = 0;
    srcB_SEL = 0;
    PC_SEL = 0;
    RF_SEL = 0; 
    case (ir[6:0]) //op-codes
    7'b0110011: //All R-Type
    begin
        ALU_FUN = {ir[30], ir[14:12]};
        srcA_SEL = 0;
        srcB_SEL = 0;
        PC_SEL = 0;
        RF_SEL = 3;
    end
    7'b0010011: //1st set of I-Type Instructions
    begin
        if (ir[14:12] == 3'b101) ALU_FUN = {ir[30], ir[14:12]};
        else ALU_FUN = {1'b0, ir[14:12]};
        srcA_SEL = 0;
        srcB_SEL = 1;
        PC_SEL = 0;
        RF_SEL = 3;   
    end
    7'b0000011: //2nd set of I-Type Instructions
    begin
        ALU_FUN = 4'b0000;
        srcA_SEL = 0;
        srcB_SEL = 1;
        PC_SEL = 0;
        RF_SEL = 2;  
    end
    7'b1100111: //Last set of I-Type (for jalr)
    begin
        PC_SEL = 1;
        RF_SEL = 0;
    end
    7'b0100011: //All S-Type Instructions
    begin
        ALU_FUN = 4'b0000;
        srcA_SEL = 0;
        srcB_SEL = 2;
        PC_SEL = 0;
    end
    7'b1100011: //All B-Type Instructions (include conditions)
    begin
        case(ir[14:13])
        2'b00: //equal
        begin
        PC_SEL = {1'b0,(ir[12]^br_eq),1'b0};    
        end
        2'b10: //less than
        begin
        PC_SEL = {1'b0,(ir[12]^br_lt),1'b0};    
        end
        2'b11: //less than unsigned
        begin
        PC_SEL = {1'b0,(ir[12]^br_ltu),1'b0};    
        end
        default:
        begin
        PC_SEL = 0;
        end
        endcase
    end
    7'b0110111: //1st set of U-Type (lui)
    begin     
        ALU_FUN = 4'b1001;
        srcA_SEL = 1;
        PC_SEL = 0;
        RF_SEL = 3;
    end
    7'b0010111: //2nd set of U-Type (auipc)
    begin     //auipc*********************************auipc
        ALU_FUN = 4'b0000;
        srcA_SEL = 1;
        srcB_SEL = 3;
        PC_SEL = 0;
        RF_SEL = 3;
    end
    7'b1101111: //All J-Type instructions (jal)    
    begin    
        PC_SEL = 3;
        RF_SEL = 0;
    end
    7'b1110011: //All CSR instructions 
    begin      
        if(ir[14:12] == 3'b000)PC_SEL = 5;//if mret, branch to mepc
        
        else begin
        RF_SEL = 2'b01;
        srcB_SEL = 3'b100;
        case(ir[14:12])
        3'b011://c
        begin
        ALU_FUN = 4'b0111;
        srcA_SEL = 2'b10;
        end
        3'b010://s
        begin
        ALU_FUN = 4'b0110;
        srcA_SEL = 2'b00;
        end
        3'b001://w
        begin
        ALU_FUN = 4'b1001;
        srcA_SEL = 2'b00;
        end
        endcase
        end
    end
    endcase      
    if(int_taken == 1)PC_SEL = 3'b100;//if interupt branch to ISR

end    
endmodule
