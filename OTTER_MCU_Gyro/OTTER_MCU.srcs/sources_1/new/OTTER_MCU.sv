`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
//
// Create Date: 02/07/2024
// Design Name: OTTER MCU
// Project Name: OTTER MCU
// Target Devices: Basys 3 Board
// Description: OTTER Microprocessor
//              
//
////////////////////////////////////////////////////////////

module OTTER_MCU(
input RST, CLK,
input INTR,
input [31:0] IOBUS_IN,
output IOBUS_WR,
output [31:0] IOBUS_OUT, IOBUS_ADDR
    );
logic[31:0] PC_count, PC_in, PC_next, ir, rs1, rs2, ALU_srcA, ALU_srcB, result, w_data, DOUT2;
logic [31:0] J_Type, B_Type, U_Type, I_Type, S_Type;
logic [31:0] jalr, branch, jal;
logic br_eq, br_lt, br_ltu;
logic [3:0] ALU_FUN;
logic [2:0] srcB_SEL, PC_SEL;
logic [1:0] srcA_SEL, RF_SEL; 
logic PC_WE, RF_WE, memWE2, memRDEN1, memRDEN2, reset;  

logic [31:0] mepc, mtvec, mstatus, csr_RD;
logic mret_exec, int_taken, csr_WE;
logic intr;

assign intr = INTR & mstatus[3];
assign PC_next = PC_count + 4;
assign IOBUS_OUT = rs2;
assign IOBUS_ADDR = result;

Mux_3x8 Mux_PC (.SEL(PC_SEL), .MUX_0(PC_next), .MUX_1(jalr), .MUX_2(branch), .MUX_3(jal), .MUX_4(mtvec), .MUX_5(mepc), .MUX_out(PC_in));
PC PC (.PC_in(PC_in), .reset(reset), .PC_WE(PC_WE), .clk(CLK), .PC_count(PC_count));    
Memory Memory (.MEM_CLK(CLK), .MEM_RDEN1(memRDEN1), .MEM_RDEN2(memRDEN2), .MEM_WE2(memWE2), 
    .MEM_ADDR1(PC_count[15:2]), .MEM_ADDR2(result), .MEM_DIN2(rs2), .MEM_SIZE(ir[13:12]), .MEM_SIGN(ir[14]), 
    .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR), .MEM_DOUT1(ir), .MEM_DOUT2(DOUT2));
Mux_2x4 Mux_RF (.SEL(RF_SEL), .MUX_0(PC_next), .MUX_1(csr_RD), .MUX_2(DOUT2), .MUX_3(result), .MUX_out(w_data));
RegFile RegFile (.en(RF_WE), .adr1(ir[19:15]), .adr2(ir[24:20]), .w_adr(ir[11:7]), .w_data(w_data), .clk(CLK), .rs1(rs1), .rs2(rs2));
IMMED_GEN IMMED_GEN (.Instruction(ir), .U_Type(U_Type), .I_Type(I_Type), .S_Type(S_Type), .J_Type(J_Type), .B_Type(B_Type));
Branch_Add_Gen Branch_Add_Gen (.PC(PC_count), .JType(J_Type), .BType(B_Type), .IType(I_Type), .rs1(rs1), .jal(jal), 
    .branch(branch), .jalr(jalr));
Mux_2x4 Mux_ALU_A (.SEL(srcA_SEL), .MUX_0(rs1), .MUX_1(U_Type), .MUX_2(~rs1), .MUX_out(ALU_srcA));
Mux_3x8 Mux_ALU_B (.SEL(srcB_SEL), .MUX_0(rs2), .MUX_1(I_Type), .MUX_2(S_Type), .MUX_3(PC_count), .MUX_4(csr_RD), .MUX_out(ALU_srcB));
ALU ALU (.ALU_srcA(ALU_srcA), .ALU_srcB(ALU_srcB), .ALU_FUN(ALU_FUN), .result(result));
Branch_Cond_Gen Branch_Cond_Gen (.rs1(rs1), .rs2(rs2), .br_eq(br_eq), .br_lt(br_lt), .br_ltu(br_ltu));
CU_DCDR CU_DCDR (.ir(ir), .int_taken(int_taken), .br_eq(br_eq), .br_lt(br_lt), .br_ltu(br_ltu), .ALU_FUN(ALU_FUN), .srcA_SEL(srcA_SEL), .srcB_SEL(srcB_SEL), 
    .PC_SEL(PC_SEL), .RF_SEL(RF_SEL));
CU_FSM CU_FSM (.RST(RST), .INTR(intr), .clk(CLK), .ir(ir), .PC_WE(PC_WE), .RF_WE(RF_WE), .memWE2(memWE2), .memRDEN1(memRDEN1), 
    .memRDEN2(memRDEN2), .reset(reset), .csr_WE(csr_WE), .int_taken(int_taken), .mret_exec(mret_exec));  
CSR CSR (.clk(CLK), .reset(reset), .mret_exec(mret_exec), .int_taken(int_taken), .csr_WE(csr_WE), .ir(ir), .PC(PC_count), .WD(result), .CSR_mstatus(mstatus), 
        .CSR_mepc(mepc), .CSR_mtvec(mtvec), .csr_RD(csr_RD));
    
endmodule
