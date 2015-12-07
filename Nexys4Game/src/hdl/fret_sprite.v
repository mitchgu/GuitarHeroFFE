`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2015 08:43:17 PM
// Design Name: 
// Module Name: fret_sprite
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


module fret_sprite(
    input clk,
    input [10:0] hcount,
    input [9:0] vcount,
    input [9:0] x,
    output [9:0] paddr,
    input [12:0] pdata,
    output reg [12:0] pixel
    );

    parameter Y = 512;
    parameter W = 32;
    parameter H = 32;

    wire [10:0] xidx;
    wire [9:0] yidx;
    assign xidx = hcount - x;
    assign yidx = vcount - Y;
    wire in_sprite;
    assign in_sprite = ((xidx >= 0) & (xidx < W)) & (yidx >= 0) & (yidx < H);
    assign paddr = in_sprite ? xidx + (yidx<<5) : 0;
    reg was_in_sprite;

    always @(posedge clk) begin
        was_in_sprite <= in_sprite;
        pixel <= was_in_sprite ? pdata : 13'b0;
    end

endmodule
