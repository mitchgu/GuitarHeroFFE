`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2015 02:16:55 AM
// Design Name: 
// Module Name: process_fft
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

module correlator(
    input clk,
    input [15:0] magnitude_tdata,
    input magnitude_tlast,
    input [11:0] magnitude_tuser,
    input magnitude_tvalid,
    output reg [41:0] dot_product,
    output reg dot_product_valid,
    output [81:0] debug
    );

    parameter REF_MIF = "../mif/00.mif";

    wire in_range;
    assign in_range = ~|magnitude_tuser[11:10];

    wire less_than_72;
    assign less_than_72 = (magnitude_tuser[9:0] < 72);

    // Inferred bram
    reg [15:0] ref_mag [0:1023];
    initial $readmemb(REF_MIF, ref_mag);
    
    reg dot_ce, dot_clr;
    reg [15:0] dot_a;
    reg [15:0] dot_b;
    wire [47:0] dot_p;
    reg [15:0] mag_a;
    reg [15:0] ref_a;
    dot_product dotter (
      .CLK(clk),    // input wire CLK
      .CE(dot_ce),      // input wire CE
      .SCLR(dot_clr),  // input wire SCLR
      .A(dot_a),        // input wire [15 : 0] A
      .B(dot_b),        // input wire [15 : 0] B
      .P(dot_p)        // output wire [41 : 0] P
    );

    reg [5:0] dot_product_timer = 0;
    always @(posedge clk) begin
        dot_a <= less_than_72 ? 16'b0 : magnitude_tdata;
        dot_b <= less_than_72 ? 16'b0 : ref_mag[magnitude_tuser[9:0]];

        dot_product_timer <= {dot_product_timer[4:0], 1'b0};

        if (magnitude_tvalid) begin
            dot_ce <= in_range;
        end
        if (magnitude_tlast) begin
            dot_product_timer[0] <= 1;
            dot_ce <= 1;
        end
        if (dot_product_timer[4]) begin
            dot_product <= dot_p[41:0];
            dot_product_valid <= 1;
            dot_ce <= 0;
            dot_clr <= 1;
        end
        else if (dot_product_timer[5]) begin
            dot_product_valid <= 0;
            dot_clr <= 0;
        end
    end
    assign debug = {dot_a,dot_b,dot_p,dot_ce,dot_clr};

endmodule