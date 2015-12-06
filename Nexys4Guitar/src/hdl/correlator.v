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
    input [20:0] norm_tdata,
    input norm_tvalid,
    output reg [41:0] dot_product,
    output reg [31:0] normalizer,
    output reg dot_product_valid,
    output [82:0] debug
    );

    parameter REF_MIF = "../mif/00.mif";
    parameter NORM_REF = 21'd0;

    wire in_range;
    assign in_range = ~|magnitude_tuser[11:10];

    wire less_than_72;
    assign less_than_72 = (magnitude_tuser[9:0] < 72);

    // Inferred bram
    reg [15:0] ref_mag [0:1023];
    initial $readmemb(REF_MIF, ref_mag);
    
    reg dot_ce, dot_clr, dot_sel;
    wire [15:0] dot_a;
    wire [15:0] dot_b;
    wire [47:0] dot_p;
    reg [15:0] norm_a;
    reg [15:0] mag_a;
    reg [15:0] ref_a;
    wire [15:0] norm_round;
    assign norm_round = (NORM_REF + 5'b10000) >> 5;
    assign dot_a = (dot_sel) ? norm_a : mag_a;
    assign dot_b = (dot_sel) ? norm_round : ref_a;
    dot_product dotter (
      .CLK(clk),    // input wire CLK
      .CE(dot_ce),      // input wire CE
      .SCLR(dot_clr),  // input wire SCLR
      .SEL(dot_sel),
      .A(dot_a),        // input wire [15 : 0] A
      .B(dot_b),        // input wire [15 : 0] B
      .P(dot_p)        // output wire [41 : 0] P
    );

    reg [4:0] dot_product_timer = 0;
    reg [5:0] normalizer_timer = 0;
    always @(posedge clk) begin
        mag_a <= less_than_72 ? 16'b0 : magnitude_tdata;
        ref_a <= less_than_72 ? 16'b0 : ref_mag[magnitude_tuser[9:0]];

        dot_product_timer <= {dot_product_timer[3:0], 1'b0};
        normalizer_timer <= {normalizer_timer[4:0], 1'b0};

        if (magnitude_tvalid) begin
            dot_ce <= in_range;
        end
        if (magnitude_tlast) begin
            dot_product_timer[0] <= 1;
            dot_ce <= 1;
        end
        if (dot_product_timer[4]) dot_product <= dot_p[41:0];
        if (norm_tvalid) begin
            norm_a <= (norm_tdata + 5'b10000)>>5;
            dot_sel <= 1;
            dot_ce <= 1;
            normalizer_timer[0] <= 1;
        end 
        if (normalizer_timer[4]) begin
            normalizer <= dot_p[31:0];
            dot_product_valid <= 1;
            dot_sel <= 0;
            dot_ce <= 0;
            dot_clr <= 1;
        end
        else if (normalizer_timer[5]) begin
            dot_product_valid <= 0;
            dot_clr <= 0;
        end
    end
    assign debug = {dot_a,dot_b,dot_p,dot_ce,dot_sel,dot_clr};

endmodule