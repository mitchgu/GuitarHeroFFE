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
    input SD_CD,
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
    wire eoc, reset_xadc;
    // INSTANTIATE XADC GUITAR 1 INPUT
    xadc_guitar xadc_guitar_1 (
        .dclk_in(clk_104mhz),  // Master clock for DRP and XADC. 
        .di_in(0),             // DRP input info (0 becuase we don't need to write)
        .daddr_in(6'h13),      // The DRP register address for the third analog aux
        .den_in(1),            // DRP enable line high (we want to read)
        .dwe_in(0),            // DRP write enable low (never write)
        .drdy_out(),           // DRP ready signal (unused)
        .do_out(sample_reg),   // DRP output from register (the ADC data)
        .reset_in(reset_xadc), // reset line
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
    wire [9:0] haddr;
    wire [15:0] hdata;
    wire hwe, error;
    process_fft fft1(
        .clk(clk_104mhz),
        .fhead(fhead),
        .faddr(faddr),
        .fdata(fdata),
        .ready(done_osample256),
        .haddr(haddr),
        .hdata(hdata),
        .hwe(hwe),
        .error(error)
    );

    reg [15:0] max_osample = 0;
    reg [15:0] max_hdata = 0;
    always @(posedge clk_104mhz) begin
        if (osample256 > max_osample)
            max_osample <= osample256;
        if (hdata > max_hdata);
            max_hdata <= hdata;
    end

    // INSTANTIATE HISTOGRAM BLOCK RAM 
    // This 16x1024 bram stores the histogram data.
    // The write port is written by process_fft.
    // The read port is read by the video outputter or the SD care saver
    // Assign histogram bram read address to histogram module unless saving
    wire [9:0] hist_vaddr;
    wire [15:0] hist_vdata;
    bram_fft bram2 (
        .clka(clk_104mhz), // input wire clka
        .wea(hwe),         // input wire [0 : 0] wea
        .addra(haddr),     // input wire [9 : 0] addra
        .dina(hdata),      // input wire [15 : 0] dina
        .clkb(clk_65mhz),  // input wire clkb
        .addrb(hist_vaddr),     // input wire [9 : 0] addrb
        .doutb(hist_vdata)      // output wire [15 : 0] doutb
    );

    wire hwe_safe;
    assign hwe_safe = (saving) ? 0 : hwe;
    wire [9:0] save_addr;
    wire [15:0] save_data;
    bram_fft bram3 (
        .clka(clk_104mhz), // input wire clka
        .wea(hwe_safe),         // input wire [0 : 0] wea
        .addra(haddr),     // input wire [9 : 0] addra
        .dina(hdata),      // input wire [15 : 0] dina
        .clkb(clk_25mhz),  // input wire clkb
        .addrb(save_addr),     // input wire [9 : 0] addrb
        .doutb(save_data)      // output wire [15 : 0] doutb
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

    // INSTANTIATE HISTOGRAM VIDEO
    wire [2:0] hist_pixel;
    wire [2:0] hist_gain;
    histogram fft_histogram(
        .clk(clk_65mhz),
        .hcount(hcount),
        .vcount(vcount),
        .blank(blank),
        .vaddr(hist_vaddr),
        .vdata(hist_vdata),
        .gain(hist_gain),
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

    reg old_center_button = 0;
    always @(posedge clk_25mhz) old_center_button <= center_button;
    assign save_start = center_button & ~old_center_button;
    wire saver_reset, saving;
    wire [3:0] save_slot;
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
    debounce right_button_debouncer(
        .clock(clk_104mhz),
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
    debounce #(.DELAY(250000)) down_button_debouncer(
        .clock(clk_25mhz),
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

//////////////////////////////////////////////////////////////////////////////////
//  
    // Connect the analog header pin to the xadc input
    assign guitar_p = AD3P;
    assign guitar_n = AD3N;

    // PWM input is 16x or 256x oversampled depending on switch 0
    assign pwm_sample = SW[0] ? osample16[13:3] : osample256[15:5];
    // Connect the guitar pwm audio to Nexys's PWM out
    assign AUD_PWM = guitar_audio_pwm;
    assign AUD_SD = guitar_audio_sd;

    // Use center button to reset xadc
    assign reset_xadc = up_button;

    // Gain of histogram (0-7)
    assign hist_gain = SW[3:1];

    // VGA OUTPUT
    // Histogram has two pipeline stages so we'll pipeline the hs and vs equally
    reg hsync1, hsync2, vsync1, vsync2;
    always @(posedge clk_65mhz) begin
        hsync1 <= hsync;
        hsync2 <= hsync1;
        vsync1 <= vsync;
        vsync2 <= vsync1;
    end
    assign VGA_R = {4{hist_pixel[0]}};
    assign VGA_G = {4{hist_pixel[1]}};
    assign VGA_B = {4{hist_pixel[2]}};
    assign VGA_HS = hsync2;
    assign VGA_VS = vsync2;

    // SD CARD CONTROLLER (SPI MODE)
    assign SD_DAT[3] = sd_cs;
    assign SD_CMD = sd_mosi;
    assign sd_miso = SD_DAT[0];
    assign SD_SCK = sd_sclk;
    assign SD_DAT[2:1] = 2'b11;
    assign SD_RESET = 0;
    assign sd_reset = down_button;
    assign saver_reset = down_button;

    // HISTOGRAM SAVER INTERFACE
    assign save_slot = SW[7:4];

    // Debounce all buttons
    assign reset_debounce = 0;
    assign left_button_noisy = BTNL;
    assign right_button_noisy = BTNR;
    assign down_button_noisy = BTND;
    assign up_button_noisy = BTNU;
    assign center_button_noisy = BTNC;

    // Assign RGB LEDs from buttons
    assign LED17_R = left_button;
    assign LED17_G = up_button;
    assign LED17_B = center_button;
    assign LED16_R = right_button;
    assign LED16_G = down_button;
    assign LED16_B = saving;
    
    // Assign switch LEDs to switch states
    assign LED = SW;
    
    // Display 01234567 then fsm state and timer time left
    assign seg_data = {max_osample, max_hdata}; 

    // Link segments module output to segments
    assign AN = strobe;  
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;

//
//////////////////////////////////////////////////////////////////////////////////
 
endmodule