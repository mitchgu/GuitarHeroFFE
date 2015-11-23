`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2015 01:46:21 AM
// Design Name: 
// Module Name: xadc_oversample256
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Oversamples the xadc output 256x, adding 4 bits of precision.
// Add 256 samples together, divide by 16. (shift right 4 bits with rounding)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module oversample16(
    input clk,
    input [11:0] sample,
    input eoc,
    output reg [13:0] oversample,
    output reg done
    );

    reg [3:0] counter = 0;
    reg [15:0] accumulator = 0;

    always @(posedge clk) begin
        if (eoc) begin
            // Conversion has ended and we can read a new sample
            if (&counter) begin // If counter is full (16 accumulated)
                // Get final total, divide by 4 with (very limited) rounding.
                oversample <= (accumulator + sample + 2'b10) >> 2;
                done <= 1;
                // Reset accumulator
                accumulator <= 0;
            end
            else begin
                // Else add to accumulator as usual
                accumulator <= accumulator + sample;
                done <= 0;
            end
            counter <= counter + 1;
        end
    end
endmodule

module oversample256(
    input clk,
    input [11:0] sample,
    input eoc,
    output reg [15:0] oversample,
    output reg done
    );

    reg [7:0] counter = 0;
    reg [19:0] accumulator = 0;

    always @(posedge clk) begin
        done <= 0;
        if (eoc) begin
            // Conversion has ended and we can read a new sample
            if (&counter) begin // If counter is full (256 accumulated)
                // Get final total, divide by 16 with rounding.
                oversample <= (accumulator + sample + 4'b0111) >> 4;
                done <= 1;
                // Reset accumulator
                accumulator <= 0;
            end
            else begin
                // Else add to accumulator as usual
                accumulator <= accumulator + sample;
            end
            counter <= counter + 1;
        end
    end
endmodule
