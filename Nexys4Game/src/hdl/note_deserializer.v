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

    reg [6:0] counter = 0;
    reg [5:0] serial_counter = 0;

    always @(posedge clk) begin
        counter <= counter + 1;
        if (~|counter) begin
            if (note_serial_sync) begin
                serial_counter <= 0;
            end
            if (serial_counter < 48) active[serial_counter] <= note_serial_data;
        end
    end
endmodule
