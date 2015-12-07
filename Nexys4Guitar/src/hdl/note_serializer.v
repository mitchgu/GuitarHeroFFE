`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2015 02:13:39 AM
// Design Name: 
// Module Name: note_serializer
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


module note_serializer(
    input clk,
    input [47:0] active,
    output reg note_serial_sync,
    output reg note_serial_data
    );

    reg [6:0] counter = 0;
    reg [5:0] serial_counter = 0;

    always @(posedge clk) begin
        counter <= counter + 1;
        if (~|counter) begin
            if (&serial_counter) note_serial_sync <= 1;
            else note_serial_sync <= 0;
            if (serial_counter < 48) note_serial_data <= active[serial_counter];
            else note_serial_data <= 0;
            serial_counter <= serial_counter + 1;
        end
    end
endmodule
