`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2015 12:02:18 AM
// Design Name: 
// Module Name: histogram
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


module histogram(
    input clk,
    input [10:0] hcount,
    input [9:0] vcount,
    input blank,
    output [9:0] vaddr,
    input [15:0] vdata,
    output reg [2:0] pixel
    );

    // 1 bin per pixel, 0 to 1023
    assign vaddr = hcount[9:0];

    reg [9:0] hheight; // Height of histogram bar
    reg [9:0] vheight; // The height of pixel above bottom of screen
    reg blank1; // blank pipelined 1

    always @(posedge clk) begin
        // Pipeline stage 1
        hheight <= vdata >> 7;
        vheight <= 10'd767 - vcount;
        blank1 <= blank;

        // Pipeline stage 2
        pixel <= blank1 ? 3'b0 : (vheight < hheight) ? 3'b111 : 3'b0;
    end

endmodule
