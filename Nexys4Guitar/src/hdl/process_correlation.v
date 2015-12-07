`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2015 07:47:06 AM
// Design Name: 
// Module Name: process_correlation
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

module process_correlation(
    input clk,
    input vclk,
    input [10:0] hcount,
    input [9:0] vcount,
    input blank,
    input [9:0] correlation,
    input correlation_valid,
    output reg [2:0] pixel,
    input thresh_sel,
    input inc_thresh,
    input dec_thresh,
    output reg active,
    output reg [9:0] thresh_high,
    output reg [9:0] thresh_low
    );

    parameter THRESH_HIGH = 450;
    parameter THRESH_LOW = 250;

    initial active = 0;
    initial thresh_low = THRESH_LOW;
    initial thresh_high = THRESH_HIGH;

    reg [9:0] filter_correlation;
    reg write_new_correlation;
    wire [9:0] new_vcorrelation;
    reg read_new_vcorrelation;
    reg [9:0] vcorrelation;
    wire fifo_full, fifo_empty, fifo_reset;
    assign fifo_reset = 0;

    fifo_generator_0 correlation_fifo (
      .rst(fifo_reset),        // input wire rst
      .wr_clk(clk),  // input wire wr_clk
      .rd_clk(vclk),  // input wire rd_clk
      .din(filter_correlation),        // input wire [9 : 0] din
      .wr_en(write_new_correlation),    // input wire wr_en
      .rd_en(read_new_vcorrelation),    // input wire rd_en
      .dout(new_vcorrelation),      // output wire [9 : 0] dout
      .full(fifo_full),      // output wire full
      .empty(fifo_empty)    // output wire empty
    );

    always @(posedge clk) begin
        if (~fifo_full & correlation_valid) begin
            filter_correlation <= (correlation>>5) + filter_correlation - (filter_correlation>>5);
            write_new_correlation <= 1;
        end
        else write_new_correlation <= 0;
    end

    always @(posedge vclk) begin
        if (~fifo_empty) begin
            read_new_vcorrelation <= 1;
            if (blank) vcorrelation <= new_vcorrelation;
        end
        else read_new_vcorrelation <= 0;
        if (hcount == thresh_low) pixel <= 3'b100;
        else if (hcount == thresh_high) pixel <= 3'b010;
        else if (hcount < vcorrelation) pixel <= active ? 3'b011 : 3'b110;
        else pixel <=  3'b000;
        if (inc_thresh) begin
            if (thresh_sel) thresh_high <= thresh_high + 4;
            else thresh_low <= thresh_low + 4;
        end
        if (dec_thresh) begin
            if (thresh_sel) thresh_high <= thresh_high - 4;
            else thresh_low <= thresh_low - 4;
        end
        if (active & (vcorrelation < thresh_low)) active <= 0;
        if (~active & (vcorrelation > thresh_high)) active <= 1; 
    end

endmodule
