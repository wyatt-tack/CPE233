`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Ethan Vosburg
// 
// Create Date: 03/15/2024 02:09:49 AM
// Module Name: DataIn
// Project Name: BasysBot
// Target Devices: Basys3
// Description: Module to take in data from external basys board though GPIO
// 
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module DataIn(
    // Inputs
    input clk,
    input reset,
    input enable,
    input data0,
    input data1,
    input data2,
    input data3,
    input data4,
    input data5,
    input data6,
    input data7,
    input axisIn,

    // Outputs
    output logic [31:0] data,
    output logic [31:0] axisOut
    );
    
    // Set up data register
    logic [31:0] data_reg;
    logic [31:0] axis_reg;

    // Assign data register to input data
    always_ff @(posedge clk) begin
        if (reset) begin
            data_reg <= 32'b0;
            axis_reg <= 32'b0;
        end
        else if (enable) begin
            data_reg <= {{25{data7}}, data6, data5, data4, data3, data2, data1, data0};
            axisOut <= {31'b0, axisIn};
        end
    end


endmodule
