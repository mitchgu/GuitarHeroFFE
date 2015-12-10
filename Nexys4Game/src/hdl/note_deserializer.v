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


module note_deserializer(
    input clk,
    input note_serial_sync,
    input note_serial_data,
    output reg [47:0] active
    );

    reg last_note_serial_sync;
    reg [12:0] counter = 0;
    reg [5:0] serial_counter = 0;

    always @(posedge clk) begin
        if (note_serial_sync & ~last_note_serial_sync) counter <= 1;
        else counter <= counter + 1;
        if (counter == 64) begin
            if (note_serial_sync) begin
                serial_counter <= 0;
            end
            if (serial_counter < 48) active[serial_counter] <= note_serial_data;
            serial_counter <= serial_counter + 1;
        end
    end
endmodule
