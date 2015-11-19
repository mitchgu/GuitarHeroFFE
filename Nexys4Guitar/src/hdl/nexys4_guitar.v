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
   output LED16_B, LED16_G, LED16_R,
   output LED17_B, LED17_G, LED17_R,
   output[15:0] LED, // LEDs above switches
   output[7:0] SEG,  // segments A-G (0-6), DP (7)
   output[7:0] AN    // Display 0-7
   );

    wire clk_104mhz;
    wire clk_65mhz;

    // SETUP CLOCK
    // 104Mhz clock for XADC
    // It divides by 4 and runs the ADC clock at 26Mhz
    // And the ADC can do one conversion in 26 clock cycles
    // So the sample rate is 1Msps (not posssible w/ 100Mhz)
    clk_wiz_0 clockgen(
        .clk_in1(CLK100MHZ),
        .clk_out1(clk_104mhz),
        .clk_out2(clk_65mhz));


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
    wire [11:0] haddr;
    wire [15:0] hdata;
    wire hwe;
    process_fft fft1(
        .clk(clk_104mhz),
        .sample(osample256),
        .ready(done_osample256),
        .haddr(haddr),
        .hdata(hdata),
        .hwe(hwe)
    );

    // INSTANTIATE BLOCK RAM 
    // This 16x2048 bram stores the histogram data.
    // The write port is written by process_fft.
    // The read port is read by the video outputter.
    wire [10:0] vaddr;
    wire [15:0] vdata;
    bram_fft bram1 (
        .clka(clk_104mhz), // input wire clka
        .wea(hwe),         // input wire [0 : 0] wea
        .addra(haddr[10:0]),     // input wire [10 : 0] addra
        .dina(hdata),      // input wire [15 : 0] dina
        .clkb(clk_65mhz),  // input wire clkb
        .addrb(vaddr),     // input wire [10 : 0] addrb
        .doutb(vdata)      // output wire [15 : 0] doutb
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
        .vaddr(vaddr),
        .vdata(vdata),
        .gain(hist_gain),
        .pixel(hist_pixel));

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
    wire up_button_noisy, up_button_door;
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
    debounce center_button_debouncer(
        .clock(clk_104mhz),
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
    assign reset_xadc = center_button;

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
    assign LED16_B = center_button;
    
    // Assign switch LEDs to switch states
    assign LED = SW;
    
    // Display 01234567 then fsm state and timer time left
    assign seg_data = {29'h0, hist_gain}; 

    // Link segments module output to segments
    assign AN = strobe;  
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;

//
//////////////////////////////////////////////////////////////////////////////////
 
endmodule