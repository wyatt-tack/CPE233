`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: J. Calllenes
//           P. Hummel
//
// Create Date: 01/20/2019 10:36:50 AM
// Module Name: OTTER_Wrapper
// Target Devices: OTTER MCU on Basys3
// Description: OTTER_WRAPPER with Switches, LEDs, and 7-segment display
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Updated MMIO Addresses, signal names
/////////////////////////////////////////////////////////////////////////////

module OTTER_Wrapper(
   // Inputs
   input CLK,
   input BTNL,
   input BTNC,
   input [15:0] SWITCHES,
   input [7:0] JB,
   input JC,
   
   // Outputs
   output logic [15:0] LEDS,
   output [7:0] CATHODES,
   output [3:0] ANODES,
   output logic [7:0] JA
   );
       
    // INPUT PORT IDS ///////////////////////////////////////////////////////
    // Right now, the only possible inputs are the switches
    // In future labs you can add more MMIO, and you'll have
    // to add constants here for the mux below
    localparam SWITCHES_AD = 32'h11000000;
    localparam DATA        = 32'h11000120; // Data in from External Board
    localparam AXIS        = 32'h11000140; // Axis bit from External Board
           
    // OUTPUT PORT IDS //////////////////////////////////////////////////////
    // In future labs you can add more MMIO
    localparam LEDS_AD     = 32'h11000020; //32'h11000020
    localparam SSEG_AD     = 32'h11000040; //32'h11000040
    localparam JA_AD       = 32'h11000100; // Stepper Motors
    
   // Signals for connecting OTTER_MCU to OTTER_wrapper /////////////////////
   logic clk_50 = 0;
    
   logic [31:0] IOBUS_out, IOBUS_in, IOBUS_addr, data, axis, STEPPER;
   logic s_reset, intr, IOBUS_wr;
   
   // Registers for buffering outputs  /////////////////////////////////////
   logic [15:0] r_SSEG;
    
   // Declare OTTER_CPU ////////////////////////////////////////////////////
   OTTER_MCU OTTER_MCU (.RST(s_reset), .CLK(clk_50), .INTR(intr),
                  .IOBUS_OUT(IOBUS_out), .IOBUS_IN(IOBUS_in),
                  .IOBUS_ADDR(IOBUS_addr), .IOBUS_WR(IOBUS_wr));

   // Declare Seven Segment Display /////////////////////////////////////////
   SevSegDisp SSG_DISP (.DATA_IN(r_SSEG), .CLK(CLK), .MODE(1'b0),
                       .CATHODES(CATHODES), .ANODES(ANODES));
   
   // Declare button debouncer/oneshot for interupts
   Debouncer Debouncer1 (.CLK_50(clk_50), .RST(), .BTN(BTNL), .OneShot(intr));
   
   // Declare Data In ///////////////////////////////////////////////////////
   DataIn dataIn(
        .clk(clk_50),
        .reset(s_reset),
        .enable(1'b1),
        .data0(JB[0]),
        .data1(JB[1]),
        .data2(JB[2]),
        .data3(JB[3]),
        .data4(JB[4]),
        .data5(JB[5]),
        .data6(JB[6]),
        .data7(JB[7]),
        .axisIn(JC),
        .data(data),
        .axisOut(axis)
   );

   // Declare Stepper Driver ////////////////////////////////////////////////
   StepperDriver StepperDriver1(
        .clk(CLK),
        .halt(1'b0),
        .accVal(STEPPER),
        .pole1(JA[0]),
        .pole2(JA[1]),
        .pole3(JA[2]),
        .pole4(JA[3])
   );

   // Declare Stepper Driver 2 //////////////////////////////////////////////
    StepperDriver StepperDriver2(
        .clk(CLK),
        .halt(1'b0),
        .accVal(STEPPER),
        .pole1(JA[4]),
        .pole2(JA[5]),
        .pole3(JA[6]),
        .pole4(JA[7])
    );
                           
   // Clock Divider to create 50 MHz Clock //////////////////////////////////
   always_ff @(posedge CLK) begin
       clk_50 <= ~clk_50;
   end
   
   // Connect Signals ///////////////////////////////////////////////////////
   assign s_reset = BTNC;
  
   
   // Connect Board input peripherals (Memory Mapped IO devices) to IOBUS
   always_comb begin
        case(IOBUS_addr)
            SWITCHES_AD: IOBUS_in = {16'b0,SWITCHES};
            DATA: IOBUS_in = data;
            AXIS: IOBUS_in = axis;
            default:     IOBUS_in = 32'b0;    // default bus input to 0
        endcase
    end
   
   
   // Connect Board output peripherals (Memory Mapped IO devices) to IOBUS
    always_ff @ (posedge clk_50) begin
        if(IOBUS_wr)
            case(IOBUS_addr)
                LEDS_AD: LEDS   <= IOBUS_out[15:0];
                SSEG_AD: r_SSEG <= IOBUS_out[15:0];
                JA_AD: STEPPER <= IOBUS_out[31:0];
            endcase
    end
   
   endmodule
