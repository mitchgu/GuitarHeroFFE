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


module process_fft(
    input clk,
    input [11:0] fhead,
    output reg [11:0] faddr,
    input [15:0] fdata,
    input ready,
    output [9:0] haddr,
    output [15:0] hdata,
    output hwe,
    output reg error
    );

    reg [31:0] frame_data;
    reg frame_last, send_valid;
    wire send_ready;
    wire [63:0] fft_data;
    wire [23:0] magnitude_data;
    wire [11:0] magnitude_index;
    wire recv_valid;
    wire frame_started, last_missing, last_unexpected;

    fft_mag fft_mag_1(
        .clk(clk),
        .cfg_tdata(8'b0),
        .cfg_tready(),
        .cfg_tvalid(0),
        .frame_tdata(frame_data),
        .frame_tlast(frame_last),
        .frame_tready(send_ready),
        .frame_tvalid(send_valid),
        .magnitude_tdata(magnitude_data),
        .magnitude_tuser(magnitude_index),
        .magnitude_tvalid(recv_valid),
        .event_frame_started(frame_started),
        .event_tlast_missing(last_missing),
        .event_tlast_unexpected(last_unexpected),
        .event_data_in_channel_halt(),
        .event_data_out_channel_halt(),
        .event_status_channel_halt());
    
    // Get a signed version of the sample by subtracting half the max
    wire signed [15:0] fdata_signed = fdata - (1 << 15);

    // SENDING LOGIC
    // Once our oversampling is done,
    // Start at the frame bram head and send all 4096 buckets of bram.
    // Hopefully every time this happens, the FFT core is ready
    reg sending;
    reg [11:0] send_count;
    wire [11:0] next_send_count;
    assign next_send_count = send_count + 1;
    initial begin
        sending = 0;
        send_count = 0;
        error = 0;
    end

    always @(posedge clk) begin
        send_valid <= 0; // Normally do not send
        frame_last <= 0; // Normally not the end of a frame
        if (!sending) begin
            if (ready) begin // When a new sample shifts in
                faddr <= fhead; // Start reading at the new head
                send_count <= 0; // Reset send_count
                sending <= 1; // Advance to next state
            end
        end
        else begin
            if (last_missing) begin
                // If core thought the frame ended
                sending <= 0; // reset to state 0
            end
            else begin
                frame_data <= {16'b0, fdata_signed}; // Send the prev sample (signed) to fft
                send_valid <= 1; // Signal to fft a sample is ready
                if (&send_count) begin
                    // If we're at last sample
                    frame_last <= 1; // Tell the core
                    if (send_ready) sending <= 0; // Reset to state 0
                end
                if (send_ready) begin // If the fft module was ready
                    faddr <= faddr + 1; // Switch to read next sample
                    send_count <= send_count + 1; // increment send_count 
                end
            end
        end
        error <= error | last_missing | last_unexpected;
    end

    // RECEIVING LOGIC
    assign hdata = magnitude_data[15:0];
    assign haddr = magnitude_index[9:0];
    assign hwe = (magnitude_index[11:10] == 0) ? recv_valid: 0;

endmodule
