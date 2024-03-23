`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
//
// Create Date: 02/07/2024
// Design Name: 3x8 Multiplexor
// Project Name: OTTER MCU
// Target Devices: Basys 3 Board
// Description: 8x32 bit input 3 bit select multiplexor
// 
//////////////////////////////////////////////////////////////
module Mux_3x8(
input [2:0] SEL, //initialize select, output, and inputs
input [31:0] MUX_0, MUX_1, MUX_2, MUX_3, MUX_4, MUX_5, MUX_6, MUX_7,
output logic [31:0] MUX_out
 );
 always_comb
 begin
 case(SEL) //select on multiplexor for inputs
 0: MUX_out = MUX_0;
 1: MUX_out = MUX_1;
 2: MUX_out = MUX_2;
 3: MUX_out = MUX_3;
 4: MUX_out = MUX_4;
 5: MUX_out = MUX_5;
 6: MUX_out = MUX_6;
 7: MUX_out = MUX_7;
 default: MUX_out = 32'h00000000;
 endcase
 end
endmodule