`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Ethan Vosburg
// 
// Create Date: 03/15/2024 03:39:20 AM
// Module Name: StepperDriver
// Project Name: BasysBot
// Target Devices: Basys3
// Description: This module will take in a 32 bit number and then out put the
//             correct signals to drive the stepper motor.
// 
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module StepperDriver(
    // Inputs
    input clk,
    input halt,
    input [31:0] accVal,

    // Outputs
    output logic pole1,
    output logic pole2,
    output logic pole3,
    output logic pole4
    );

    // Set up clock register
    logic [31:0] clk_reg = 0;
    logic sclk = 0;
    logic [31:0] accVal_reg;
    
    assign accVal_reg = 300000 - (accVal * 100);
    // Create sclk of 2ms with a 100MHz clock
    always_ff @(posedge clk) begin
        
        if (halt) begin
            // Do Nothing
        end
        else if (clk_reg >= 100000) begin
            sclk <= ~sclk;
            clk_reg <= 0;
        end
        else begin
            clk_reg <= clk_reg + 1;
        end
    end

    typedef enum {pole_1, pole_2, pole_3, pole_4} pole_type;
    pole_type pole, next_pole;

    always_ff @(posedge sclk) begin
        if (halt) begin
            // Do Nothing
        end
        else begin
            pole <= next_pole;
        end
    end

    // Pole state machine
    always_comb begin
        case(pole)
            pole_1: begin
                pole1 = 1;
                pole2 = 0;
                pole3 = 0;
                pole4 = 0;
            end
            pole_2: begin
                pole1 = 0;
                pole2 = 1;
                pole3 = 0;
                pole4 = 0;
            end
            pole_3: begin
                pole1 = 0;
                pole2 = 0;
                pole3 = 1;
                pole4 = 0;
            end
            pole_4: begin
                pole1 = 0;
                pole2 = 0;
                pole3 = 0;
                pole4 = 1;
            end
            default: begin
                pole1 = 0;
                pole2 = 0;
                pole3 = 0;
                pole4 = 0;
            end
        endcase
    end

endmodule
