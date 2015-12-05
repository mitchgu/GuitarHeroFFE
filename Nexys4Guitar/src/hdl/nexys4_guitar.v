//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Create Date: 11/12/2015 V1.0
// Design Name: Guitar Hero: Fast Fourier Edition
// Module Name: ghffe_nexys4
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

module nexys4_guitar (
    input CLK100MHZ,
    input[15:0] SW, 
    input BTNC, BTNU, BTNL, BTNR, BTND,
    input AD3P, AD3N,
    output[3:0] VGA_R, 
    output[3:0] VGA_B, 
    output[3:0] VGA_G,
    output VGA_HS, 
    output VGA_VS, 
    output AUD_PWM, AUD_SD,
    output SD_RESET,
    output SD_SCK,
    output SD_CMD, 
    inout [3:0] SD_DAT,
    output LED16_B, LED16_G, LED16_R,
    output LED17_B, LED17_G, LED17_R,
    output[15:0] LED, // LEDs above switches
    output[7:0] SEG,  // segments A-G (0-6), DP (7)
    output[7:0] AN    // Display 0-7
    );

    wire clk_104mhz;
    wire clk_65mhz;
    wire clk_25mhz;

    // SETUP CLOCK
    // 104Mhz clock for XADC
    // It divides by 4 and runs the ADC clock at 26Mhz
    // And the ADC can do one conversion in 26 clock cycles
    // So the sample rate is 1Msps (not posssible w/ 100Mhz)
    clk_wiz_0 clockgen(
        .clk_in1(CLK100MHZ),
        .clk_out1(clk_104mhz),
        .clk_out2(clk_65mhz),
        .clk_out3(clk_25mhz));


    wire [15:0] sample_reg;
    wire eoc, xadc_reset;
    // INSTANTIATE XADC GUITAR 1 INPUT
    xadc_guitar xadc_guitar_1 (
        .dclk_in(clk_104mhz),  // Master clock for DRP and XADC. 
        .di_in(0),             // DRP input info (0 becuase we don't need to write)
        .daddr_in(6'h13),      // The DRP register address for the third analog aux
        .den_in(1),            // DRP enable line high (we want to read)
        .dwe_in(0),            // DRP write enable low (never write)
        .drdy_out(),           // DRP ready signal (unused)
        .do_out(sample_reg),   // DRP output from register (the ADC data)
        .reset_in(xadc_reset), // reset line
        .vp_in(0),             // dedicated/built in analog channel on bank 0
        .vn_in(0),             // can't use this analog channel b/c of nexys 4 setup
        .vauxp3(guitar_p),     // The third analog auxiliary input channel
        .vauxn3(guitar_n),     // Choose this one b/c it's on JXADC header 1
        .channel_out(),        // Not useful in sngle channel mode
        .eoc_out(eoc),         // Pulses high on end of ADC conversion
        .alarm_out(),          // Not useful
        .eos_out(),            // End of sequence pulse, not useful
        .busy_out()            // High when conversion is in progress. unused.
    );

    // INSTANTIATE SAMPLE FRAME BLOCK RAM 
    // This 16x4096 bram stores the frame of samples
    // The write port is written by osample256.
    // The read port is read by process_fft.
    wire fwe;
    reg [11:0] fhead = 0;
    wire [11:0] faddr;
    wire [15:0] fsample, fdata;
    bram_frame bram1 (
        .clka(clk_104mhz),   // input wire clka
        .wea(fwe),           // input wire [0 : 0] wea
        .addra(fhead),     // input wire [11 : 0] addra
        .dina(fsample),      // input wire [15 : 0] dina
        .clkb(clk_104mhz),   // input wire clkb
        .addrb(faddr),     // input wire [11 : 0] addrb
        .doutb(fdata)      // output wire [15 : 0] doutb
    );

    // INSTANTIATE 16x OVERSAMPLING
    // This outputs 14-bit samples at a 62.5kHz sample rate
    // with lower noise than raw ADC output
    // Useful for outputting to PWM audio
    wire [13:0] osample16;
    wire done_osample16;
    oversample16 osamp16_1 (
        .clk(clk_104mhz),
        .sample(sample_reg[15:4]),
        .eoc(eoc),
        .oversample(osample16),
        .done(done_osample16));

    // INSTANTIATE 256x OVERSAMPLING
    // This outputs 16-bit samples at a 3.9kHz sample rate
    // This is for the FFT to do around 0-2Khz
    wire [15:0] osample256;
    wire done_osample256;
    oversample256 osamp256_1 (
        .clk(clk_104mhz),
        .sample(sample_reg[15:4]),
        .eoc(eoc),
        .oversample(osample256),
        .done(done_osample256));

    always @(posedge clk_104mhz) begin
        if (done_osample256) fhead <= fhead + 1;
    end
    assign fsample = osample256;
    assign fwe = done_osample256;

    // INSTANTIATE PWM AUDIO OUT MODULE
    // This is a PWM frequency of around 51kHz.
    wire [10:0] pwm_sample;
    pwm11 guitar_pwm(
        .clk(clk_104mhz),
        .PWM_in(pwm_sample),
        .PWM_out(guitar_audio_pwm),
        .PWM_sd(guitar_audio_sd)
        );

    // INSTANTIATE FFT PROCESSING MODULE
    wire last_missing;
    wire [31:0] frame_tdata;
    wire frame_tlast, frame_tready, frame_tvalid;
    bram_to_fft bram_to_fft_0(
        .clk(clk_104mhz),
        .head(fhead),
        .addr(faddr),
        .data(fdata),
        .start(done_osample256),
        .last_missing(last_missing),
        .frame_tdata(frame_tdata),
        .frame_tlast(frame_tlast),
        .frame_tready(frame_tready),
        .frame_tvalid(frame_tvalid)
    );

    wire [23:0] magnitude_tdata;
    wire [11:0] magnitude_tuser;
    wire magnitude_tlast, magnitude_tvalid;
    wire [31:0] mag_squared_tdata;
    wire [11:0] mag_squared_tuser;
    wire mag_squared_tlast, mag_squared_tvalid;
    fft_mag fft_mag_i(
        .clk(clk_104mhz),
        .event_tlast_missing(last_missing),
        .frame_tdata(frame_tdata),
        .frame_tlast(frame_tlast),
        .frame_tready(frame_tready),
        .frame_tvalid(frame_tvalid),
        .mag_squared_tdata(mag_squared_tdata),
        .mag_squared_tlast(mag_squared_tlast),
        .mag_squared_tuser(mag_squared_tuser),
        .mag_squared_tvalid(mag_squared_tvalid),
        .magnitude_tdata(magnitude_tdata),
        .magnitude_tlast(magnitude_tlast),
        .magnitude_tuser(magnitude_tuser),
        .magnitude_tvalid(magnitude_tvalid));

    wire in_range;
    assign in_range = ~|magnitude_tuser[11:10];

    wire [20:0] norm_tdata;
    wire norm_tvalid;
    calculate_norm calc_norm(
        .clk(clk_104mhz),
        .mag_squared_tdata(mag_squared_tdata),
        .mag_squared_tlast(mag_squared_tlast),
        .mag_squared_tuser(mag_squared_tuser),
        .mag_squared_tvalid(mag_squared_tvalid),
        .norm_tdata(norm_tdata),
        .norm_tvalid(norm_tvalid)
        );

    // INSTANTIATE HISTOGRAM BLOCK RAM 
    // This 16x1024 bram stores the histogram data.
    // The write port is written by process_fft.
    // The read port is read by the video outputter or the SD care saver
    // Assign histogram bram read address to histogram module unless saving
    wire [9:0] haddr;
    wire [15:0] hdata;
    bram_fft bram2 (
        .clka(clk_104mhz), // input wire clka
        .wea(in_range & magnitude_tvalid),  // input wire [0 : 0] wea
        .addra(magnitude_tuser[9:0]),     // input wire [9 : 0] addra
        .dina(magnitude_tdata[15:0]),      // input wire [15 : 0] dina
        .clkb(clk_65mhz),  // input wire clkb
        .addrb(haddr),     // input wire [9 : 0] addrb
        .doutb(hdata)      // output wire [15 : 0] doutb
    );
    wire [41:0] dot_product;
    wire [31:0] normalizer;
    wire dot_product_valid;
    wire [76:0] debug;
    correlator correlator_00(
        .clk(clk_104mhz),
        .magnitude_tdata(magnitude_tdata[15:0]),
        .magnitude_tlast(magnitude_tlast),
        .magnitude_tvalid(magnitude_tvalid),
        .magnitude_tuser(magnitude_tuser),
        .norm_tdata(norm_tdata),
        .norm_tvalid(norm_tvalid),
        .dot_product(dot_product),
        .normalizer(normalizer),
        .dot_product_valid(dot_product_valid),
        .debug(debug)
        );

    wire div_valid;
    wire [79:0] div_raw;
    correlate_div corrediv (
      .aclk(clk_104mhz),                                      // input wire aclk
      .s_axis_divisor_tvalid(dot_product_valid),    // input wire s_axis_divisor_tvalid
      .s_axis_divisor_tdata(normalizer),      // input wire [31 : 0] s_axis_divisor_tdata
      .s_axis_dividend_tvalid(dot_product_valid),  // input wire s_axis_dividend_tvalid
      .s_axis_dividend_tdata({6'h00,dot_product}),    // input wire [47 : 0] s_axis_dividend_tdata
      .m_axis_dout_tvalid(div_valid),          // output wire m_axis_dout_tvalid
      .m_axis_dout_tdata(div_raw)            // output wire [79 : 0] m_axis_dout_tdata
    );

    // INSTANTIATE XVGA SIGNALS
    wire [10:0] hcount;
    wire [9:0] vcount;
    wire hsync, vsync, blank;
    xvga xvga1(
        .vclock(clk_65mhz),
        .hcount(hcount),
        .vcount(vcount),
        .vsync(vsync),
        .hsync(hsync),
        .blank(blank));

    wire [2:0] correlate_pixel;
    process_correlation pcorrelate(
        .clk(clk_104mhz),
        .vclk(clk_65mhz),
        .hcount(hcount),
        .vcount(vcount),
        .correlation(div_raw[41:32]),
        .correlation_valid(div_valid),
        .pixel(correlate_pixel)
    );

    // INSTANTIATE HISTOGRAM VIDEO
    wire [2:0] hist_pixel;
    histogram fft_histogram(
        .clk(clk_65mhz),
        .hcount(hcount),
        .vcount(vcount),
        .blank(blank),
        .vaddr(haddr),
        .vdata(hdata),
        .pixel(hist_pixel));

    wire sd_cs, sd_mosi, sd_miso, sd_sclk, sd_wr, sd_ready_for_next_byte, sd_ready, sd_reset;
    wire [7:0] sd_din;
    wire [31:0] sd_address;
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

        .reset(sd_reset), // Resets controller on assertion.
        .ready(sd_ready), // HIGH if the SD card is ready for a read or write operation.
        .address(sd_address),   // Memory address for read/write operation. This MUST 
                                // be a multiple of 512 bytes, due to SD sectoring.
        .clk(clk_25mhz),  // 25 MHz clock.
        .status() // For debug purposes: Current state of controller.
    );

    wire save_start;
    wire saver_reset, saving;
    wire [6:0] save_slot;
    wire [9:0] save_addr;
    wire [15:0] save_data;

    bram_fft bram3 (
        .clka(clk_104mhz), // input wire clka
        .wea(in_range & magnitude_tvalid & ~saving),// input wire [0 : 0] wea
        .addra(magnitude_tuser[9:0]),     // input wire [9 : 0] addra
        .dina(magnitude_tdata[15:0]),      // input wire [15 : 0] dina
        .clkb(clk_25mhz),  // input wire clkb
        .addrb(save_addr),     // input wire [9 : 0] addrb
        .doutb(save_data)      // output wire [15 : 0] doutb
    );

    histogram_saver hsaver(
        .clk(clk_25mhz),
        .reset(saver_reset),
        .start(save_start),
        .slot(save_slot),
        .vaddr(save_addr),
        .vdata(save_data),
        .sd_ready(sd_ready),
        .sd_address(sd_address),
        .sd_wr(sd_wr),
        .sd_din(sd_din),
        .sd_ready_for_next_byte(sd_ready_for_next_byte),
        .saving(saving)
        );

    // INSTANTIATE SEVEN SEGMENT DISPLAY
    wire [31:0] seg_data;
    wire [6:0] segments;
    wire [7:0] strobe;
    display_8hex display(
        .clk(clk_104mhz),
        .data(seg_data),
        .seg(segments),
        .strobe(strobe)); 
    
    // INSTANTIATE DEBOUNCED BUTTONS/SWITCHES
    wire reset_debounce;

    // Debounce left btn
    wire left_button_noisy, left_button;
    debounce left_button_debouncer(
        .clock(clk_104mhz),
        .reset(reset_debounce),
        .noisy(left_button_noisy),
        .clean(left_button));
        
    // Debounce right btn
    wire right_button_noisy, right_button;
    debounce #(.DELAY(250000)) right_button_debouncer(
        .clock(clk_25mhz),
        .reset(reset_debounce),
        .noisy(right_button_noisy),
        .clean(right_button));
                
    // Debounce up btn
    wire up_button_noisy, up_button;
    debounce up_button_debouncer(
        .clock(clk_104mhz),
        .reset(reset_debounce),
        .noisy(up_button_noisy),
        .clean(up_button));

    // Debounce down btn
    wire down_button_noisy, down_button;
    debounce down_button_debouncer(
        .clock(clk_104mhz),
        .reset(reset_debounce),
        .noisy(down_button_noisy),
        .clean(down_button));
                        
    // Debounce center btn
    wire center_button_noisy, center_button;
    debounce #(.DELAY(250000)) center_button_debouncer(
        .clock(clk_25mhz),
        .reset(reset_debounce),
        .noisy(center_button_noisy),
        .clean(center_button));

    wire [15:0] SWS;
    genvar i;
    generate for(i=8; i<16; i=i+1)
        begin: 
            gen_modules_1 synchronize s104(clk_104mhz, SW[i], SWS[i]);
        end
    endgenerate
    genvar j;
    generate for(j=1; j<8; j=i+1)
        begin: 
            gen_modules_0 synchronize s25(clk_25mhz, SW[j], SWS[j]);
        end
    endgenerate
    synchronize s104_0(clk_104mhz, SW[0], SWS[0]);
/*
    ila_0 lifesaver (
        .clk(clk_104mhz), // input wire clk
        .probe0(sample_reg[11:0]), // input wire [11:0]  probe0  
        .probe1(osample256), // input wire [15:0]  probe1 
        .probe2(frame_tdata[15:0]), // input wire [15:0]  probe2 
        .probe3(faddr), // input wire [11:0]  probe3 
        .probe4(magnitude_tdata[15:0]), // input wire [15:0]  probe4 
        .probe5(magnitude_tuser), // input wire [11:0]  probe5 
        .probe6(mag_squared), // input wire [31:0]  probe6 
        .probe7(eoc), // input wire [0:0]  probe7 
        .probe8(done_osample256), // input wire [0:0]  probe8 
        .probe9(frame_tvalid), // input wire [0:0]  probe9 
        .probe10(frame_tready), // input wire [0:0]  probe10 
        .probe11(magnitude_tvalid), // input wire [0:0]  probe11 
        .probe12(mag_squared_valid), // input wire [0:0]  probe12 
        .probe13(magnitude_tlast), // input wire [0:0]  probe13 
        .probe14(swe), // input wire [0:0]  probe14 
        .probe15(up_button) // input wire [0:0]  probe15
    ); */
    ila_0 lifesaver (
        .clk(clk_104mhz), // input wire clk
        .probe0(magnitude_tdata[15:0]), // input wire [11:0]  probe0  
        .probe1(magnitude_tuser), // input wire [15:0]  probe1 
        .probe2(magnitude_tvalid), // input wire [15:0]  probe2 
        .probe3(mag_squared_tdata), // input wire [11:0]  probe3 
        .probe4(mag_squared_tvalid), // input wire [15:0]  probe4 
        .probe5(norm_tdata), // input wire [11:0]  probe5 
        .probe6(norm_tvalid), // input wire [31:0]  probe6 
        .probe7(dot_product), // input wire [0:0]  probe7 
        .probe8(normalizer), // input wire [0:0]  probe8 
        .probe9(dot_product_valid), // input wire [0:0]  probe9 
        .probe10(div_raw[41:32]), // input wire [0:0]  probe10 
        .probe11(div_valid), // input wire [0:0]  probe11 
        .probe12(mag_squared_tuser), // input wire [0:0]  probe12 
        .probe13(magnitude_tlast), // input wire [0:0]  probe13 
        .probe14(mag_squared_tlast), // input wire [0:0]  probe14 
        .probe15(in_range), // input wire [0:0]  probe15
        .probe16(debug[76:61]),
        .probe17(debug[60:45]),
        .probe18(debug[44:3]),
        .probe19(debug[2]),
        .probe20(debug[1]),
        .probe21(debug[0])
    );

//////////////////////////////////////////////////////////////////////////////////
//  
    // Connect the analog header pin to the xadc input
    assign guitar_p = AD3P;
    assign guitar_n = AD3N;

    // PWM input is 16x or 256x oversampled depending on switch 0
    assign pwm_sample = SWS[0] ? osample16[13:3] : osample256[15:5];
    // Connect the guitar pwm audio to Nexys's PWM out
    assign AUD_PWM = guitar_audio_pwm;
    assign AUD_SD = guitar_audio_sd;

    // Use center button to reset xadc
    assign xadc_reset = left_button;

    // VGA OUTPUT
    // Histogram has two pipeline stages so we'll pipeline the hs and vs equally
    reg [1:0] hsync_stage;
    reg [1:0] vsync_stage;
    reg hsync_out, vsync_out;
    reg [2:0] correlate_pixel_stage;
    always @(posedge clk_65mhz) begin
        hsync_stage <= {hsync_stage[0],hsync};
        vsync_stage <= {vsync_stage[0],vsync};
        hsync_out <= hsync_stage[1];
        vsync_out <= vsync_stage[1];
        correlate_pixel_stage <= correlate_pixel;
    end
    assign VGA_R = {4{hist_pixel[0] | correlate_pixel_stage[0]}};
    assign VGA_G = {4{hist_pixel[1] | correlate_pixel_stage[1]}};
    assign VGA_B = {4{hist_pixel[2] | correlate_pixel_stage[2]}};
    assign VGA_HS = hsync_out;
    assign VGA_VS = vsync_out;

    // SD CARD CONTROLLER (SPI MODE)
    assign SD_DAT[3] = sd_cs;
    assign SD_CMD = sd_mosi;
    assign sd_miso = SD_DAT[0];
    assign SD_SCK = sd_sclk;
    assign SD_DAT[2:1] = 2'b11;
    assign SD_RESET = 0;
    assign sd_reset = right_button;
    assign saver_reset = right_button;

    reg old_center_button = 0;
    always @(posedge clk_25mhz) old_center_button <= center_button;
    assign save_start = center_button & ~old_center_button;

    // HISTOGRAM SAVER INTERFACE
    assign save_slot = SW[8:1];

    // Debounce all buttons
    assign reset_debounce = 0;
    assign left_button_noisy = BTNL;
    assign right_button_noisy = BTNR;
    assign down_button_noisy = BTND;
    assign up_button_noisy = BTNU;
    assign center_button_noisy = BTNC;

    // Assign RGB LEDs from buttons
    assign LED17_R = xadc_reset;
    assign LED17_G = saver_reset;
    assign LED17_B = sd_reset;
    assign LED16_R = saving;
    assign LED16_G = saving;
    assign LED16_B = saving;
    
    // Assign switch LEDs to switch states
    assign LED = SW;
    
    // Display 01234567 then fsm state and timer time left
    assign seg_data = 32'hdeadbeef; 

    // Link segments module output to segments
    assign AN = strobe;  
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;

//
//////////////////////////////////////////////////////////////////////////////////
 
endmodule