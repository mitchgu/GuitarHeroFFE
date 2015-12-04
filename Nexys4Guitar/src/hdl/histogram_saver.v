`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2015 10:56:54 PM
// Design Name: 
// Module Name: histogram_saver
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


module histogram_saver(
    input clk,
    input reset,
    input start,
    input [6:0] slot,
    output reg [9:0] vaddr,
    input [15:0] vdata,
    input sd_ready,
    output reg [31:0] sd_address,
    output reg sd_wr,
    output reg [7:0] sd_din,
    input sd_ready_for_next_byte,
    output reg saving
    );
    
    parameter STANDBY = 2'b00;
    parameter INIT = 2'b01;
    parameter START = 2'b10;
    parameter SAVE = 2'b11;
    parameter MSHALF = 0;
    parameter LSHALF = 1;

    reg [1:0] save_state = STANDBY;
    reg next_half = MSHALF;
    reg [1:0] sector = 2'b00;
    reg last_ready;

    always @(posedge clk) begin
        last_ready <= sd_ready_for_next_byte;
        case (save_state)
            STANDBY: begin
                saving <= 0;
                if (start) begin
                    sd_address <= slot << 11;
                    sector <= 2'b00;
                    vaddr <= 10'b0;
                    saving <= 1;
                    save_state <= INIT;
                end
            end
            INIT: begin
                if (sd_ready) begin
                    save_state <= START;
                    sd_wr <= 1;
                    sd_din <= 8'hFF;
                    next_half <= MSHALF;
                end
            end
            START: begin
                if(~sd_ready) begin
                    save_state <= SAVE;
                    sd_wr <= 0;
                end
            end
            SAVE: begin
                if(sd_ready) begin
                    if (&sector) save_state <= STANDBY;
                    else begin
                        sector <= sector + 1;
                        vaddr[9:8] <= sector + 1;
                        vaddr[7:0] <= 0;
                        sd_address <= sd_address + 512;
                        save_state <= INIT;
                    end
                end
                else if(sd_ready_for_next_byte & ~last_ready) begin
                    if (next_half == LSHALF) begin
                        sd_din <= vdata[7:0];
                        next_half <= MSHALF;
                        vaddr <= vaddr + 1;
                    end
                    else begin
                        sd_din <= vdata[15:8];
                        next_half <= LSHALF;
                    end
                end
            end
            default: save_state <= STANDBY;
        endcase
        if (reset) begin
            save_state <= STANDBY;
        end
    end

endmodule
