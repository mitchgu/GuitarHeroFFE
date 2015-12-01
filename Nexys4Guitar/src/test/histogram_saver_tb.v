`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2015 01:08:20 AM
// Design Name: 
// Module Name: histogram_saver_tb
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


module histogram_saver_tb( );

    reg clk;
    reg start;
    wire [9:0] vaddr;
    wire [31:0] sd_address;
    wire sd_wr, sd_ready, sd_ready_for_next_byte;
    wire [7:0] sd_din;
    wire saving;

    wire sd_cs, sd_mosi, sd_miso, sd_sclk;
    sd_controller sdc(
        .cs(sd_cs), // Connect to SD_DAT[3].
        .mosi(sd_mosi), // Connect to SD_CMD.
        .miso(sd_miso), // Connect to SD_DAT[0].
        .sclk(sd_sclk), // Connect to SD_SCK.
                    // For SPI mode, SD_DAT[2] and SD_DAT[1] should be held HIGH. 
                    // SD_RESET should be held LOW.

        .rd(0),   // Read-enable. When [ready] is HIGH, asseting [rd] will 
                    // begin a 512-byte READ operation at [address]. 
                    // [byte_available] will transition HIGH as a new byte has been
                    // read from the SD card. The byte is presented on [dout].
        .dout(), // Data output for READ operation.
        .byte_available(), // A new byte has been presented on [dout].

        .wr(sd_wr),   // Write-enable. When [ready] is HIGH, asserting [wr] will
                    // begin a 512-byte WRITE operation at [address].
                    // [ready_for_next_byte] will transition HIGH to request that
                    // the next byte to be written should be presentaed on [din].
        .din(sd_din), // Data input for WRITE operation.
        .ready_for_next_byte(sd_ready_for_next_byte), // A new byte should be presented on [din].

        .reset(0), // Resets controller on assertion.
        .ready(sd_ready), // HIGH if the SD card is ready for a read or write operation.
        .address(sd_address),   // Memory address for read/write operation. This MUST 
                                // be a multiple of 512 bytes, due to SD sectoring.
        .clk(clk),  // 25 MHz clock.
        .status() // For debug purposes: Current state of controller.
    );
    assign sd_miso = 1;

    reg ready;
    histogram_saver dut (
        .clk(clk),
        .start(start),
        .slot(0),
        .vaddr(vaddr),
        .vdata(16'b0),
        .sd_ready(ready),
        .sd_address(sd_address),
        .sd_wr(sd_wr),
        .sd_din(sd_din),
        .sd_ready_for_next_byte(1),
        .saving(saving)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        start = 0;

        #100;

        start = 1;
        #10;
        start = 0;
        ready = 1;
        #20;
        ready = 0;
        #5120;
        ready = 1;
        #20;
        ready = 0;
        #5120;
        ready = 1;
        #20;
        ready = 0;
        #5120;
        ready = 1;
        #20;
        ready = 0;
        #5120;
        ready = 1;
    end
endmodule
