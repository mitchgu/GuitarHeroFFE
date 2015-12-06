`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2015 03:05:37 PM
// Design Name: 
// Module Name: process_div
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


module process_div(
    input clk,
    input [42*48-1:0] dot_product_f,
    input [32*48-1:0] normalizer_f,
    input [1*48-1:0] dot_product_valid,
    output wire [10*48-1:0] correlation_f,
    output reg correlations_valid 
    );

    wire [41:0] dot_product [0:47];
    wire [31:0] normalizer [0:47];
    reg [9:0] correlation [0:47];

    assign dot_product[0] = dot_product_f[0*42 +: 42];
    assign dot_product[1] = dot_product_f[1*42 +: 42];
    assign dot_product[2] = dot_product_f[2*42 +: 42];
    assign dot_product[3] = dot_product_f[3*42 +: 42];
    assign dot_product[4] = dot_product_f[4*42 +: 42];
    assign dot_product[5] = dot_product_f[5*42 +: 42];
    assign dot_product[6] = dot_product_f[6*42 +: 42];
    assign dot_product[7] = dot_product_f[7*42 +: 42];
    assign dot_product[8] = dot_product_f[8*42 +: 42];
    assign dot_product[9] = dot_product_f[9*42 +: 42];
    assign dot_product[10] = dot_product_f[10*42 +: 42];
    assign dot_product[11] = dot_product_f[11*42 +: 42];
    assign dot_product[12] = dot_product_f[12*42 +: 42];
    assign dot_product[13] = dot_product_f[13*42 +: 42];
    assign dot_product[14] = dot_product_f[14*42 +: 42];
    assign dot_product[15] = dot_product_f[15*42 +: 42];
    assign dot_product[16] = dot_product_f[16*42 +: 42];
    assign dot_product[17] = dot_product_f[17*42 +: 42];
    assign dot_product[18] = dot_product_f[18*42 +: 42];
    assign dot_product[19] = dot_product_f[19*42 +: 42];
    assign dot_product[20] = dot_product_f[20*42 +: 42];
    assign dot_product[21] = dot_product_f[21*42 +: 42];
    assign dot_product[22] = dot_product_f[22*42 +: 42];
    assign dot_product[23] = dot_product_f[23*42 +: 42];
    assign dot_product[24] = dot_product_f[24*42 +: 42];
    assign dot_product[25] = dot_product_f[25*42 +: 42];
    assign dot_product[26] = dot_product_f[26*42 +: 42];
    assign dot_product[27] = dot_product_f[27*42 +: 42];
    assign dot_product[28] = dot_product_f[28*42 +: 42];
    assign dot_product[29] = dot_product_f[29*42 +: 42];
    assign dot_product[30] = dot_product_f[30*42 +: 42];
    assign dot_product[31] = dot_product_f[31*42 +: 42];
    assign dot_product[32] = dot_product_f[32*42 +: 42];
    assign dot_product[33] = dot_product_f[33*42 +: 42];
    assign dot_product[34] = dot_product_f[34*42 +: 42];
    assign dot_product[35] = dot_product_f[35*42 +: 42];
    assign dot_product[36] = dot_product_f[36*42 +: 42];
    assign dot_product[37] = dot_product_f[37*42 +: 42];
    assign dot_product[38] = dot_product_f[38*42 +: 42];
    assign dot_product[39] = dot_product_f[39*42 +: 42];
    assign dot_product[40] = dot_product_f[40*42 +: 42];
    assign dot_product[41] = dot_product_f[41*42 +: 42];
    assign dot_product[42] = dot_product_f[42*42 +: 42];
    assign dot_product[43] = dot_product_f[43*42 +: 42];
    assign dot_product[44] = dot_product_f[44*42 +: 42];
    assign dot_product[45] = dot_product_f[45*42 +: 42];
    assign dot_product[46] = dot_product_f[46*42 +: 42];
    assign dot_product[47] = dot_product_f[47*42 +: 42];
    assign normalizer[0] = normalizer_f[0*32 +: 32];
    assign normalizer[1] = normalizer_f[1*32 +: 32];
    assign normalizer[2] = normalizer_f[2*32 +: 32];
    assign normalizer[3] = normalizer_f[3*32 +: 32];
    assign normalizer[4] = normalizer_f[4*32 +: 32];
    assign normalizer[5] = normalizer_f[5*32 +: 32];
    assign normalizer[6] = normalizer_f[6*32 +: 32];
    assign normalizer[7] = normalizer_f[7*32 +: 32];
    assign normalizer[8] = normalizer_f[8*32 +: 32];
    assign normalizer[9] = normalizer_f[9*32 +: 32];
    assign normalizer[10] = normalizer_f[10*32 +: 32];
    assign normalizer[11] = normalizer_f[11*32 +: 32];
    assign normalizer[12] = normalizer_f[12*32 +: 32];
    assign normalizer[13] = normalizer_f[13*32 +: 32];
    assign normalizer[14] = normalizer_f[14*32 +: 32];
    assign normalizer[15] = normalizer_f[15*32 +: 32];
    assign normalizer[16] = normalizer_f[16*32 +: 32];
    assign normalizer[17] = normalizer_f[17*32 +: 32];
    assign normalizer[18] = normalizer_f[18*32 +: 32];
    assign normalizer[19] = normalizer_f[19*32 +: 32];
    assign normalizer[20] = normalizer_f[20*32 +: 32];
    assign normalizer[21] = normalizer_f[21*32 +: 32];
    assign normalizer[22] = normalizer_f[22*32 +: 32];
    assign normalizer[23] = normalizer_f[23*32 +: 32];
    assign normalizer[24] = normalizer_f[24*32 +: 32];
    assign normalizer[25] = normalizer_f[25*32 +: 32];
    assign normalizer[26] = normalizer_f[26*32 +: 32];
    assign normalizer[27] = normalizer_f[27*32 +: 32];
    assign normalizer[28] = normalizer_f[28*32 +: 32];
    assign normalizer[29] = normalizer_f[29*32 +: 32];
    assign normalizer[30] = normalizer_f[30*32 +: 32];
    assign normalizer[31] = normalizer_f[31*32 +: 32];
    assign normalizer[32] = normalizer_f[32*32 +: 32];
    assign normalizer[33] = normalizer_f[33*32 +: 32];
    assign normalizer[34] = normalizer_f[34*32 +: 32];
    assign normalizer[35] = normalizer_f[35*32 +: 32];
    assign normalizer[36] = normalizer_f[36*32 +: 32];
    assign normalizer[37] = normalizer_f[37*32 +: 32];
    assign normalizer[38] = normalizer_f[38*32 +: 32];
    assign normalizer[39] = normalizer_f[39*32 +: 32];
    assign normalizer[40] = normalizer_f[40*32 +: 32];
    assign normalizer[41] = normalizer_f[41*32 +: 32];
    assign normalizer[42] = normalizer_f[42*32 +: 32];
    assign normalizer[43] = normalizer_f[43*32 +: 32];
    assign normalizer[44] = normalizer_f[44*32 +: 32];
    assign normalizer[45] = normalizer_f[45*32 +: 32];
    assign normalizer[46] = normalizer_f[46*32 +: 32];
    assign normalizer[47] = normalizer_f[47*32 +: 32];
    assign correlation_f[0*10 +: 10] = correlation[0];
    assign correlation_f[1*10 +: 10] = correlation[1];
    assign correlation_f[2*10 +: 10] = correlation[2];
    assign correlation_f[3*10 +: 10] = correlation[3];
    assign correlation_f[4*10 +: 10] = correlation[4];
    assign correlation_f[5*10 +: 10] = correlation[5];
    assign correlation_f[6*10 +: 10] = correlation[6];
    assign correlation_f[7*10 +: 10] = correlation[7];
    assign correlation_f[8*10 +: 10] = correlation[8];
    assign correlation_f[9*10 +: 10] = correlation[9];
    assign correlation_f[10*10 +: 10] = correlation[10];
    assign correlation_f[11*10 +: 10] = correlation[11];
    assign correlation_f[12*10 +: 10] = correlation[12];
    assign correlation_f[13*10 +: 10] = correlation[13];
    assign correlation_f[14*10 +: 10] = correlation[14];
    assign correlation_f[15*10 +: 10] = correlation[15];
    assign correlation_f[16*10 +: 10] = correlation[16];
    assign correlation_f[17*10 +: 10] = correlation[17];
    assign correlation_f[18*10 +: 10] = correlation[18];
    assign correlation_f[19*10 +: 10] = correlation[19];
    assign correlation_f[20*10 +: 10] = correlation[20];
    assign correlation_f[21*10 +: 10] = correlation[21];
    assign correlation_f[22*10 +: 10] = correlation[22];
    assign correlation_f[23*10 +: 10] = correlation[23];
    assign correlation_f[24*10 +: 10] = correlation[24];
    assign correlation_f[25*10 +: 10] = correlation[25];
    assign correlation_f[26*10 +: 10] = correlation[26];
    assign correlation_f[27*10 +: 10] = correlation[27];
    assign correlation_f[28*10 +: 10] = correlation[28];
    assign correlation_f[29*10 +: 10] = correlation[29];
    assign correlation_f[30*10 +: 10] = correlation[30];
    assign correlation_f[31*10 +: 10] = correlation[31];
    assign correlation_f[32*10 +: 10] = correlation[32];
    assign correlation_f[33*10 +: 10] = correlation[33];
    assign correlation_f[34*10 +: 10] = correlation[34];
    assign correlation_f[35*10 +: 10] = correlation[35];
    assign correlation_f[36*10 +: 10] = correlation[36];
    assign correlation_f[37*10 +: 10] = correlation[37];
    assign correlation_f[38*10 +: 10] = correlation[38];
    assign correlation_f[39*10 +: 10] = correlation[39];
    assign correlation_f[40*10 +: 10] = correlation[40];
    assign correlation_f[41*10 +: 10] = correlation[41];
    assign correlation_f[42*10 +: 10] = correlation[42];
    assign correlation_f[43*10 +: 10] = correlation[43];
    assign correlation_f[44*10 +: 10] = correlation[44];
    assign correlation_f[45*10 +: 10] = correlation[45];
    assign correlation_f[46*10 +: 10] = correlation[46];
    assign correlation_f[47*10 +: 10] = correlation[47];

    reg [31:0] divisor_tdata;
    reg [41:0] dividend_tdata;
    reg divide_tvalid;
    wire correlation_tvalid;
    wire [79:0] correlation_tdata;
    correlate_div corrediv (
        .aclk(clk),                                      // input wire aclk
        .s_axis_divisor_tvalid(divide_tvalid),    // input wire s_axis_divisor_tvalid
        .s_axis_divisor_tdata(divisor_tdata),      // input wire [31 : 0] s_axis_divisor_tdata
        .s_axis_dividend_tvalid(divide_tvalid),  // input wire s_axis_dividend_tvalid
        .s_axis_dividend_tdata({6'h00,dividend_tdata}),    // input wire [47 : 0] s_axis_dividend_tdata
        .m_axis_dout_tvalid(correlation_tvalid),          // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(correlation_tdata)            // output wire [79 : 0] m_axis_dout_tdata
    );

    reg sending = 0;
    reg receiving = 0;
    reg [5:0] send_index = 0;
    reg [5:0] recv_index = 0;
    reg correlation_tvalid_last = 0;
    always @(posedge clk) begin
        correlation_tvalid_last <= correlation_tvalid;
        if (dot_product_valid[0]) begin
            sending <= 1;
        end
        if (correlation_tvalid & ~correlation_tvalid_last) begin
            receiving <= 1;
        end
        if (sending) begin
            divisor_tdata <= normalizer[send_index];
            dividend_tdata <= dot_product[send_index];
            divide_tvalid <= 1;
            if (send_index == 47) begin
                sending <= 0;
                send_index <= 0;
            end
            else send_index <= send_index + 1;
        end
        else divide_tvalid <= 0;
        if (receiving) begin
            correlation[recv_index] <= correlation_tdata[41:32];
            if (recv_index == 47) begin
                receiving <= 0;
                recv_index <= 0;
                correlations_valid <= 1;
            end
            else recv_index <= recv_index + 1;
        end
        else begin
            correlations_valid <= 0;
        end
    end

endmodule
