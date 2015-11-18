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
    input [15:0] sample,
    input ready,
    output reg [11:0] haddr,
    output reg [15:0] hdata,
    output reg hwe
    );

    wire [31:0] sample_data;
    wire send_valid, send_ready;
    wire [63:0] fft_data;
    wire [15:0] user_data;
    wire recv_valid;
    reg recv_ready;

    // INSTANTIATE 4096 POINT 16-BIT FFT IP
    // Don't really care about config channel or the events
    // The sending and receiving channels are AXI4-STREAM
    xfft_0 guitar_fft (
        .aclk(clk),                       // input wire aclk
        .s_axis_config_tdata(0),          // input wire [7 : 0] s_axis_config_tdata
        .s_axis_config_tvalid(0),         // input wire s_axis_config_tvalid
        .s_axis_config_tready(),          // output wire s_axis_config_tready
        .s_axis_data_tdata(sample_data),  // input wire [31 : 0] s_axis_data_tdata
        .s_axis_data_tvalid(send_valid),  // input wire s_axis_data_tvalid
        .s_axis_data_tready(send_ready),  // output wire s_axis_data_tready
        .s_axis_data_tlast(0),            // input wire s_axis_data_tlast
        .m_axis_data_tdata(fft_data),     // output wire [63 : 0] m_axis_data_tdata
        .m_axis_data_tuser(user_data),    // output wire [15 : 0] m_axis_data_tuser
        .m_axis_data_tvalid(recv_valid),  // output wire m_axis_data_tvalid
        .m_axis_data_tready(recv_ready),  // input wire m_axis_data_tready
        .m_axis_data_tlast(),             // output wire m_axis_data_tlast
        .event_frame_started(),           // output wire event_frame_started
        .event_tlast_unexpected(),        // output wire event_tlast_unexpected
        .event_tlast_missing(),           // output wire event_tlast_missing
        .event_status_channel_halt(),     // output wire event_status_channel_halt
        .event_data_in_channel_halt(),    // output wire event_data_in_channel_halt
        .event_data_out_channel_halt()    // output wire event_data_out_channel_halt
    );
    
    // Get a signed version of the sample by subtracting half the max
    wire signed [15:0] sample_signed = sample - (1 << 15);
    // Set real part of input to the audio sample and imaginary part to 0
    assign sample_data = {16'b0, sample_signed};

    // Split FFT output into real and imaginary parts
    wire signed [15:0] real_part, imag_part;
    // The FFT gives us an absurd 29 bits but let's just use 16
    assign real_part = fft_data[28:13];
    assign imag_part = fft_data[60:45];

    // Pull out the FFT index
    wire [11:0] fft_index;
    assign fft_index = user_data[11:0];

    // SENDING LOGIC
    // Assert valid once our oversampling is done
    // Hopefully every time this happens, the FFT core is ready
    assign send_valid = ready;

    // RECEIVING LOGIC
    reg [1:0] recv_state;
    reg sqrt_start;
    wire sqrt_done;
    reg [31:0] rere, imim, sqrt_in;
    wire [15:0] sqrt_out;

    // INSTANTIATE SQRT Module
    sqrt_0 sqrt_fft (
        .aclk(clk),                           // input wire aclk
        .s_axis_cartesian_tvalid(sqrt_start), // input wire s_axis_cartesian_tvalid
        .s_axis_cartesian_tdata(sqrt_in),     // input wire [31 : 0] s_axis_cartesian_tdata
        .m_axis_dout_tvalid(sqrt_done),       // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(sqrt_out)          // output wire [15 : 0] m_axis_dout_tdata
    );

    always @(posedge clk) begin
        // Defaults
        hwe <= 0;
        sqrt_start <= 0;
        case (recv_state)
            2'd0: begin
                // Wait for a valid fft output
                if (recv_valid & recv_ready) begin
                    // fft output is ready
                    // square the parts and assign haddr and move on
                    // deassert ready while we calculate the magnitude
                    recv_state <= 2'd1;
                    haddr <= fft_index;
                    rere <= real_part * real_part;
                    imim <= imag_part * imag_part;
                    recv_ready <= 0;
                end
                else recv_ready <= 1;
            end
            2'd1: begin 
                // Sum the square of each part and start sqrt
                recv_state <= 3'd2;
                // Hopefully this won't overflow...
                sqrt_in <= rere + imim;
                sqrt_start <= 1;
                recv_ready <= 0;
            end
            2'd2: begin
                // Wait for sqrt to finish
                if (sqrt_done) begin
                    // sqrt finished, output data and assert hwe
                    recv_state <= 2'd0;
                    hdata <= sqrt_out;
                    hwe <= 1;
                    recv_ready <= 1;
                end
            end
            default: recv_state <= 2'd0;
        endcase
    end


endmodule
