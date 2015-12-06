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
    output reg [2:0] pixel
    );

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
        pixel <= (hcount < vcorrelation) ? 3'b111 : 3'b000;
    end

endmodule
