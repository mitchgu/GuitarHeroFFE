`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2015 01:46:21 AM
// Design Name: 
// Module Name: xadc_oversample256
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Oversamples the xadc output 256x, adding 4 bits of precision.
// Add 256 samples together, divide by 16. (shift right 4 bits with rounding)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module xadc_oversample256(
    input clk,
    input vp,
    input vn,
    input en,
    input reset,
    output reg [15:0] oversample,
    output reg done
    );

    wire eoc;
    wire [15:0] sample_reg;
    reg [7:0] counter = 0;
    reg [19:0] accumulator = 0;

    // INSTANTIATE XADC GUITAR 1 INPUT
    xadc_guitar xadc_guitar_1 (
        .dclk_in(clk),         // Master clock for DRP and XADC. 
        .di_in(0),             // DRP input info (0 becuase we don't need to write)
        .daddr_in(6'h13),      // The DRP register address for the third analog aux
        .den_in(1),            // DRP enable line high (we want to read)
        .dwe_in(0),            // DRP write enable low (never write)
        .drdy_out(),           // DRP ready signal (unused)
        .do_out(sample_reg),   // DRP output from register (the ADC data)
        .reset_in(reset),      // reset line
        .vp_in(0),             // dedicated/built in analog channel on bank 0
        .vn_in(0),             // can't use this analog channel b/c of nexys 4 setup
        .vauxp3(vp),           // The third analog auxiliary input channel
        .vauxn3(vn),           // Choose this one b/c it's on JXADC header 1
        .channel_out(),        // Not useful in sngle channel mode
        .eoc_out(eoc),         // Pulses high on end of ADC conversion
        .alarm_out(),          // Not useful
        .eos_out(),            // End of sequence pulse, not useful
        .busy_out()            // High when conversion is in progress. unused.
    );

    always @(posedge clk) begin
        if (eoc) begin
            // Conversion has ended and we can read a new sample
            if (&counter) begin // If counter is full (256 accumulated)
                // Get final total, divide by 16 with rounding.
                oversample <= (accumulator + counter + 4'b0111) >> 4;
                done <= 1;
                // Reset accumulator
                accumulator <= 0;
            end
            else begin
                // Else add to accumulator as usual
                accumulator <= accumulator + sample_reg;
                done <= 0;
            end
            counter <= counter + 1;
        end
    end

endmodule
