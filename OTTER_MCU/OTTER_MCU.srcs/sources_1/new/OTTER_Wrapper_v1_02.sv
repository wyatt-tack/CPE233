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
   input CLK,
   input BTNL,
   input BTNC,
   input [15:0] SWITCHES,
   output logic [15:0] LEDS,
   output [7:0] CATHODES,
   output [3:0] ANODES,
   output logic SCL,
   inout SDA,
   output logic [7:0] outReg
   );
    // INPUT PORT IDS ///////////////////////////////////////////////////////
    // Right now, the only possible inputs are the switches
    // In future labs you can add more MMIO, and you'll have
    // to add constants here for the mux below
    localparam SWITCHES_AD = 32'h11000000;
        //I2C reading Data
    localparam I2CDATAREAD_AD = 32'h110000C0;
    
    // OUTPUT PORT IDS //////////////////////////////////////////////////////
    // In future labs you can add more MMIO
    localparam LEDS_AD    = 32'h11000020; //32'h11000020
    localparam SSEG_AD    = 32'h11000040; //32'h11000040
        //I2C Adressed and written data
    localparam I2CSLAVE_AD = 32'h11000080;
    localparam I2CREADREG_AD = 32'h11000090;
    localparam I2CWRITEREG_AD = 32'h110000a0;
    localparam I2CDATAWRITE_AD = 32'h110000b0;
    localparam OUTREG_AD = 32'h110000d0;
    
   // Signals for connecting OTTER_MCU to OTTER_wrapper /////////////////////
   logic clk_50 = 0;
    
   logic [31:0] IOBUS_out, IOBUS_in, IOBUS_addr;
   logic s_reset, intr, IOBUS_wr;
   
   // Registers for buffering inputs   /////////////////////////////////////
   logic [7:0] I2CdataR;
   
   // Registers for buffering outputs  /////////////////////////////////////
   logic [15:0] r_SSEG;
     
   logic [7:0] I2CAddr, I2CregAddrR, I2CregAddrW;
   logic [7:0] I2CdataW;
    
   // Declare OTTER_CPU ////////////////////////////////////////////////////
   OTTER_MCU OTTER_MCU (.RST(s_reset), .CLK(clk_50), .INTR(intr),
                  .IOBUS_OUT(IOBUS_out), .IOBUS_IN(IOBUS_in),
                  .IOBUS_ADDR(IOBUS_addr), .IOBUS_WR(IOBUS_wr));

   // Declare Seven Segment Display /////////////////////////////////////////
   SevSegDisp SSG_DISP (.DATA_IN(r_SSEG), .CLK(CLK), .MODE(1'b1),
                       .CATHODES(CATHODES), .ANODES(ANODES)); 
   
   // Declare button debouncer/oneshot for interupts
   Debouncer Debouncer1 (.CLK_50(clk_50), .RST(), .BTN(BTNL), .OneShot(intr));
   
   // Declare I2C breakout module
   I2C I2C ( .clk(CLK), .I2CAddr(I2CAddr), .regAddrR(I2CregAddrR), 
            .regAddrW(I2CregAddrW), .dataR(I2CdataR), .dataW(I2CdataW), 
            .SCL(SCL), .SDAin(SDA));
                           
   // Clock Divider to create 50 MHz Clock //////////////////////////////////
   always_ff @(posedge CLK) begin
       clk_50 <= ~clk_50;
   end
   
   // Connect Signals ///////////////////////////////////////////////////////
   assign s_reset = BTNC;
  
   
   // Connect Board input peripherals (Memory Mapped IO devices) to IOBUS
   always_comb begin
        case(IOBUS_addr)
            SWITCHES_AD:    IOBUS_in = {16'b0, SWITCHES};
            //for I2C readable data
            I2CDATAREAD_AD: IOBUS_in = {24'b0, I2CdataR};
            default:        IOBUS_in = 32'b0;    // default bus input to 0
        endcase
    end
   
   
   // Connect Board output peripherals (Memory Mapped IO devices) to IOBUS
    always_ff @ (posedge clk_50) begin
        if(IOBUS_wr)
            case(IOBUS_addr)
                LEDS_AD: LEDS   <= IOBUS_out[15:0];
                SSEG_AD: r_SSEG <= IOBUS_out[15:0];
                //for I2C Adresses and Data
                I2CSLAVE_AD:        I2CAddr <= IOBUS_out[7:0]; 
                I2CREADREG_AD:      I2CregAddrR <= IOBUS_out[7:0]; 
                I2CWRITEREG_AD:     I2CregAddrW <= IOBUS_out[7:0];
                I2CDATAWRITE_AD:    I2CdataW <= IOBUS_out[7:0];
                OUTREG_AD:          outReg <= IOBUS_out[7:0];
            endcase
    end
   
   endmodule
