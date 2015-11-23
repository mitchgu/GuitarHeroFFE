`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2015 05:25:56 PM
// Design Name: 
// Module Name: process_fft_tb
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


module process_fft_tb();

    reg clk;
    reg ready;
    reg [14:0] count;

    wire [11:0] faddr;
    wire [9:0] haddr;
    wire [15:0] hdata;
    wire hwe, error;

    process_fft dut(
        .clk(clk),
        .fhead(12'b0),
        .faddr(faddr),
        .fdata(16'h93DA),
        .ready(ready),
        .haddr(haddr),
        .hdata(hdata),
        .hwe(hwe),
        .error(error));

    always #5 clk = !clk;
    initial begin
        clk = 0;
        count = 0;
        ready = 0;

        #100;

        ready = 1;
        #10;
        ready = 0;
        #70000;
        ready = 1;
        #10;
        ready = 0;
        #70000;

    end

endmodule
