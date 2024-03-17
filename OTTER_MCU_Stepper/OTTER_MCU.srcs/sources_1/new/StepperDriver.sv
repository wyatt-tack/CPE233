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
    logic reverse_flag = 0;
    
    // Create sclk of 2ms with a 100MHz clock
    always_ff @(posedge clk) begin
        
        if (halt) begin
            // Do Nothing
        end
        else if (clk_reg >= accVal) begin
            // Replace accVal with 1000000 for constant speed testing
            sclk <= ~sclk;
            clk_reg <= 0;
        end
        else begin
            clk_reg <= clk_reg + 1;
        end
    end

    typedef enum {pole_1, pole_2, pole_3, pole_4} pole_type;
    pole_type pole, next_pole, reverse_next_pole;

    // Initially set pole states since there is not initial state
    initial begin
        pole = pole_1;
        next_pole = pole_2;
        reverse_next_pole = pole_3;
    end

    // State logic for stepper motor
    always_ff @(posedge sclk) begin
        if (halt) begin
            // Do Nothing
        end
        else if (!reverse_flag) begin
            pole <= next_pole;
        end
        else begin
            pole <= reverse_next_pole;
        end
    end

    // Pole state machine
    // Controls the pole of the stepper motor to trigger steps
    always_comb begin
        case(pole)
            pole_1: begin
                pole1 = 1;
                pole2 = 0;
                pole3 = 0;
                pole4 = 0;
                next_pole = pole_2;
                reverse_next_pole = pole_4;
            end
            pole_2: begin
                pole1 = 0;
                pole2 = 1;
                pole3 = 0;
                pole4 = 0;
                next_pole = pole_3;
                reverse_next_pole = pole_1;
            end
            pole_3: begin
                pole1 = 0;
                pole2 = 0;
                pole3 = 1;
                pole4 = 0;
                next_pole = pole_4;
                reverse_next_pole = pole_2;
            end
            pole_4: begin
                pole1 = 0;
                pole2 = 0;
                pole3 = 0;
                pole4 = 1;
                next_pole = pole_1;
                reverse_next_pole = pole_3;
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
