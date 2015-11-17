`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2015 12:44:48 AM
// Design Name: 
// Module Name: clock_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_divider(
    input clock_104mhz,
    output reg clock_104,
    output reg clock_104_256
    );

    reg counter_104[5:0] = 0; // Count to 54
    reg counter_256[6:0] = 0; // Count to 128

    always @(posedge clock_104mhz) begin
        if (counter_104 == 6'd51) begin
            counter_104 <= 0;
            counter_256 <= counter_256 + 1;
            clock_104 <= ~clock_104;
        end
        else counter_104 <= counter_104 + 1;
        if (&counter_256) clock_104_256 <= ~clock_104_256;
    end
endmodule
