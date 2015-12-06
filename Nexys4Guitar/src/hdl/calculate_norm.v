`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2015 12:43:02 AM
// Design Name: 
// Module Name: calculate_norm
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


module calculate_norm(
    input clk,
    input [31:0] mag_squared_tdata,
    input mag_squared_tlast,
    input [11:0] mag_squared_tuser,
    input mag_squared_tvalid,
    output [20:0] norm_tdata,
    output norm_tvalid
    );

    wire in_range;
    assign in_range = ~|mag_squared_tuser[11:10];

    reg [47:0] accumulator_tdata = 0;
    reg accumulator_tvalid;
    always @(posedge clk) begin
        if (mag_squared_tlast) accumulator_tvalid <= 1;
        else if (accumulator_tvalid) begin
            accumulator_tvalid <= 0;
            accumulator_tdata <= 0;
        end
        if (in_range & mag_squared_tvalid & (mag_squared_tuser[9:0] > 72)) 
            accumulator_tdata <= accumulator_tdata + mag_squared_tdata;
    end

    wire [23:0] norm_out;
    norm_sqrt normer (
        .aclk(clk),                                        // input wire aclk
        .s_axis_cartesian_tvalid(accumulator_tvalid),  // input wire s_axis_cartesian_tvalid
        .s_axis_cartesian_tdata(accumulator_tdata),    // input wire [47 : 0] s_axis_cartesian_tdata
        .m_axis_dout_tvalid(norm_tvalid),            // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(norm_out)              // output wire [23 : 0] m_axis_dout_tdata
    );
    assign norm_tdata = norm_out[20:0];

endmodule
