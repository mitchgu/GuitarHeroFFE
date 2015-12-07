`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2015 09:56:14 PM
// Design Name: 
// Module Name: bg_display
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


module bg_display(
    input clk,
    input clk2,
    input vsync,
    input blank,
    output reg [11:0] pixel_out
    );

    reg [17:0] bg_addr = 0;
    wire [7:0] bg_data;
    blk_mem_gen_0 bg_mem (
      .clka(clk2),    // input wire clka
      .addra(bg_addr),  // input wire [17 : 0] addra
      .douta(bg_data)  // output wire [7 : 0] douta
    );

    reg [5:0] current_idx = 0;
    reg [1:0] current_run_left = 0;
    wire [11:0] pixel;
    dist_mem_gen_1 bg_colors (
        .a(current_idx),  // input wire [5 : 0] addra
        .spo(pixel)  // output wire [11 : 0] douta
    );

    always @(posedge clk) begin
        if (~blank) begin
            if (current_run_left == 0) begin
                bg_addr <= bg_addr + 1;
                current_idx <= bg_data[5:0];
                current_run_left <= bg_data[7:6];
            end
            else begin
                current_run_left <= current_run_left - 1;
            end
            pixel_out <= pixel;
        end
        else pixel_out <= 12'b0;
        if (~vsync) begin
            bg_addr <= 0;
            current_run_left <= 0;
            current_idx <= 0;
        end
    end
/*
    ila_0 lifesaver (
        .clk(clk), // input wire clk
        .probe0(hcount), // input wire [10:0]  probe0  
        .probe1(vcount), // input wire [9:0]  probe1 
        .probe2(blank), // input wire [0:0]  probe2 
        .probe3(bg_addr), // input wire [17:0]  probe3 
        .probe4(bg_data), // input wire [7:0]  probe4 
        .probe5(pixel), // input wire [11:0]  probe5 
        .probe6(current_idx), // input wire [1:0]  probe6 
        .probe7(current_run_left) // input wire [0:0]  probe7
    );*/

endmodule
