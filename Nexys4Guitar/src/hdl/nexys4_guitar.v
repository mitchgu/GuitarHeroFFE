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
    wire [41:0] dot_product [0:47];
    wire [31:0] normalizer [0:47];
    wire [47:0] dot_product_valid;
    wire [76:0] debug [0:47];
/*
    correlator correlator_00(
        .clk(clk_104mhz),
        .magnitude_tdata(magnitude_tdata[15:0]),
        .magnitude_tlast(magnitude_tlast),
        .magnitude_tvalid(magnitude_tvalid),
        .magnitude_tuser(magnitude_tuser),
        .norm_tdata(norm_tdata),
        .norm_tvalid(norm_tvalid),
        .dot_product(dot_product[0]),
        .normalizer(normalizer[0]),
        .dot_product_valid(dot_product_valid[0]),
        .debug(debug[0])
        );*/

/*
    reg [8*6:0] mif_file [0:47];
    reg [8*11:0] norm_file [0:47];
    integer z;
    integer normf;
    integer status;
    reg [20:0] ref_norm = 0;
    initial begin
        for (z=0; z<48; z=z+1) begin
            mif_file[z] = $sformatf("%0d.mif", z);
            norm_file[z] = $sformatf("%0d_norm.mif", z);
            normf = $fopen(norm_file, "r");
            status = $fscanf(fin,"%b",ref_norm);
            $fclose(normf);
        end
    end */

    defparam correlator_gen[0].c.REF_MIF = "../mif/00.mif";
    defparam correlator_gen[0].c.NORM_REF = 21'b0000011111111101000011;
    defparam correlator_gen[1].c.REF_MIF = "../mif/01.mif";
    defparam correlator_gen[1].c.NORM_REF = 21'b0000100000010010111100;
    defparam correlator_gen[2].c.REF_MIF = "../mif/02.mif";
    defparam correlator_gen[2].c.NORM_REF = 21'b0000011001010010011100;
    defparam correlator_gen[3].c.REF_MIF = "../mif/03.mif";
    defparam correlator_gen[3].c.NORM_REF = 21'b0000100010001110010110;
    defparam correlator_gen[4].c.REF_MIF = "../mif/04.mif";
    defparam correlator_gen[4].c.NORM_REF = 21'b0000011101001110101011;
    defparam correlator_gen[5].c.REF_MIF = "../mif/05.mif";
    defparam correlator_gen[5].c.NORM_REF = 21'b0000011010101110101100;
    defparam correlator_gen[6].c.REF_MIF = "../mif/06.mif";
    defparam correlator_gen[6].c.NORM_REF = 21'b0000010110001000010000;
    defparam correlator_gen[7].c.REF_MIF = "../mif/07.mif";
    defparam correlator_gen[7].c.NORM_REF = 21'b0000011010110010001010;
    defparam correlator_gen[8].c.REF_MIF = "../mif/08.mif";
    defparam correlator_gen[8].c.NORM_REF = 21'b0000010111011101000000;
    defparam correlator_gen[9].c.REF_MIF = "../mif/09.mif";
    defparam correlator_gen[9].c.NORM_REF = 21'b0000011110010110000001;
    defparam correlator_gen[10].c.REF_MIF = "../mif/10.mif";
    defparam correlator_gen[10].c.NORM_REF = 21'b0000010011001011100110;
    defparam correlator_gen[11].c.REF_MIF = "../mif/11.mif";
    defparam correlator_gen[11].c.NORM_REF = 21'b0000010110011000011000;
    defparam correlator_gen[12].c.REF_MIF = "../mif/12.mif";
    defparam correlator_gen[12].c.NORM_REF = 21'b0000010110000000100110;
    defparam correlator_gen[13].c.REF_MIF = "../mif/13.mif";
    defparam correlator_gen[13].c.NORM_REF = 21'b0000010110010000111101;
    defparam correlator_gen[14].c.REF_MIF = "../mif/14.mif";
    defparam correlator_gen[14].c.NORM_REF = 21'b0000010100110101101100;
    defparam correlator_gen[15].c.REF_MIF = "../mif/15.mif";
    defparam correlator_gen[15].c.NORM_REF = 21'b0000010110111011101100;
    defparam correlator_gen[16].c.REF_MIF = "../mif/16.mif";
    defparam correlator_gen[16].c.NORM_REF = 21'b0000011011000110011010;
    defparam correlator_gen[17].c.REF_MIF = "../mif/17.mif";
    defparam correlator_gen[17].c.NORM_REF = 21'b0000011010011110010000;
    defparam correlator_gen[18].c.REF_MIF = "../mif/18.mif";
    defparam correlator_gen[18].c.NORM_REF = 21'b0000010111000111100010;
    defparam correlator_gen[19].c.REF_MIF = "../mif/19.mif";
    defparam correlator_gen[19].c.NORM_REF = 21'b0000011001000011101011;
    defparam correlator_gen[20].c.REF_MIF = "../mif/20.mif";
    defparam correlator_gen[20].c.NORM_REF = 21'b0000011000101001101010;
    defparam correlator_gen[21].c.REF_MIF = "../mif/21.mif";
    defparam correlator_gen[21].c.NORM_REF = 21'b0000010011111111101110;
    defparam correlator_gen[22].c.REF_MIF = "../mif/22.mif";
    defparam correlator_gen[22].c.NORM_REF = 21'b0000010010010011100100;
    defparam correlator_gen[23].c.REF_MIF = "../mif/23.mif";
    defparam correlator_gen[23].c.NORM_REF = 21'b0000010100011100110110;
    defparam correlator_gen[24].c.REF_MIF = "../mif/24.mif";
    defparam correlator_gen[24].c.NORM_REF = 21'b0000001110101011101001;
    defparam correlator_gen[25].c.REF_MIF = "../mif/25.mif";
    defparam correlator_gen[25].c.NORM_REF = 21'b0000010010011111110100;
    defparam correlator_gen[26].c.REF_MIF = "../mif/26.mif";
    defparam correlator_gen[26].c.NORM_REF = 21'b0000001111011000011010;
    defparam correlator_gen[27].c.REF_MIF = "../mif/27.mif";
    defparam correlator_gen[27].c.NORM_REF = 21'b0000010001000000100011;
    defparam correlator_gen[28].c.REF_MIF = "../mif/28.mif";
    defparam correlator_gen[28].c.NORM_REF = 21'b0000010001110011111000;
    defparam correlator_gen[29].c.REF_MIF = "../mif/29.mif";
    defparam correlator_gen[29].c.NORM_REF = 21'b0000001110111111101010;
    defparam correlator_gen[30].c.REF_MIF = "../mif/30.mif";
    defparam correlator_gen[30].c.NORM_REF = 21'b0000010000010011101110;
    defparam correlator_gen[31].c.REF_MIF = "../mif/31.mif";
    defparam correlator_gen[31].c.NORM_REF = 21'b0000010000000100100100;
    defparam correlator_gen[32].c.REF_MIF = "../mif/32.mif";
    defparam correlator_gen[32].c.NORM_REF = 21'b0000010000011101001100;
    defparam correlator_gen[33].c.REF_MIF = "../mif/33.mif";
    defparam correlator_gen[33].c.NORM_REF = 21'b0000001111000010101110;
    defparam correlator_gen[34].c.REF_MIF = "../mif/34.mif";
    defparam correlator_gen[34].c.NORM_REF = 21'b0000001100001011011010;
    defparam correlator_gen[35].c.REF_MIF = "../mif/35.mif";
    defparam correlator_gen[35].c.NORM_REF = 21'b0000001101110001101110;
    defparam correlator_gen[36].c.REF_MIF = "../mif/36.mif";
    defparam correlator_gen[36].c.NORM_REF = 21'b0000010000010001100101;
    defparam correlator_gen[37].c.REF_MIF = "../mif/37.mif";
    defparam correlator_gen[37].c.NORM_REF = 21'b0000001111001010001111;
    defparam correlator_gen[38].c.REF_MIF = "../mif/38.mif";
    defparam correlator_gen[38].c.NORM_REF = 21'b0000001100000100100110;
    defparam correlator_gen[39].c.REF_MIF = "../mif/39.mif";
    defparam correlator_gen[39].c.NORM_REF = 21'b0000001110001111000110;
    defparam correlator_gen[40].c.REF_MIF = "../mif/40.mif";
    defparam correlator_gen[40].c.NORM_REF = 21'b0000101011101100010101;
    defparam correlator_gen[41].c.REF_MIF = "../mif/41.mif";
    defparam correlator_gen[41].c.NORM_REF = 21'b0000100100000110000011;
    defparam correlator_gen[42].c.REF_MIF = "../mif/42.mif";
    defparam correlator_gen[42].c.NORM_REF = 21'b0000100111001110100001;
    defparam correlator_gen[43].c.REF_MIF = "../mif/43.mif";
    defparam correlator_gen[43].c.NORM_REF = 21'b0000100110110001000111;
    defparam correlator_gen[44].c.REF_MIF = "../mif/44.mif";
    defparam correlator_gen[44].c.NORM_REF = 21'b0000101101001110000001;
    defparam correlator_gen[45].c.REF_MIF = "../mif/45.mif";
    defparam correlator_gen[45].c.NORM_REF = 21'b0000110011010000001000;
    defparam correlator_gen[46].c.REF_MIF = "../mif/46.mif";
    defparam correlator_gen[46].c.NORM_REF = 21'b0000100101010000100101;
    defparam correlator_gen[47].c.REF_MIF = "../mif/47.mif";
    defparam correlator_gen[47].c.NORM_REF = 21'b0000100011101110110010;

    genvar a;
    generate for(a=0; a<48; a=a+1)
        begin : correlator_gen
            correlator c (
                .clk(clk_104mhz),
                .magnitude_tdata(magnitude_tdata[15:0]),
                .magnitude_tlast(magnitude_tlast),
                .magnitude_tvalid(magnitude_tvalid),
                .magnitude_tuser(magnitude_tuser),
                .norm_tdata(norm_tdata),
                .norm_tvalid(norm_tvalid),
                .dot_product(dot_product[a]),
                .normalizer(normalizer[a]),
                .dot_product_valid(dot_product_valid[a]),
                .debug(debug[a])
                );
        end
    endgenerate

    wire [9:0] correlation [0:47];
    wire correlations_valid;

    wire [42*48-1:0] dot_product_f;
    wire [32*48-1:0] normalizer_f;
    wire [10*48-1:0] correlation_f;
    assign dot_product_f[0*42 +: 42] = dot_product[0];
    assign dot_product_f[1*42 +: 42] = dot_product[1];
    assign dot_product_f[2*42 +: 42] = dot_product[2];
    assign dot_product_f[3*42 +: 42] = dot_product[3];
    assign dot_product_f[4*42 +: 42] = dot_product[4];
    assign dot_product_f[5*42 +: 42] = dot_product[5];
    assign dot_product_f[6*42 +: 42] = dot_product[6];
    assign dot_product_f[7*42 +: 42] = dot_product[7];
    assign dot_product_f[8*42 +: 42] = dot_product[8];
    assign dot_product_f[9*42 +: 42] = dot_product[9];
    assign dot_product_f[10*42 +: 42] = dot_product[10];
    assign dot_product_f[11*42 +: 42] = dot_product[11];
    assign dot_product_f[12*42 +: 42] = dot_product[12];
    assign dot_product_f[13*42 +: 42] = dot_product[13];
    assign dot_product_f[14*42 +: 42] = dot_product[14];
    assign dot_product_f[15*42 +: 42] = dot_product[15];
    assign dot_product_f[16*42 +: 42] = dot_product[16];
    assign dot_product_f[17*42 +: 42] = dot_product[17];
    assign dot_product_f[18*42 +: 42] = dot_product[18];
    assign dot_product_f[19*42 +: 42] = dot_product[19];
    assign dot_product_f[20*42 +: 42] = dot_product[20];
    assign dot_product_f[21*42 +: 42] = dot_product[21];
    assign dot_product_f[22*42 +: 42] = dot_product[22];
    assign dot_product_f[23*42 +: 42] = dot_product[23];
    assign dot_product_f[24*42 +: 42] = dot_product[24];
    assign dot_product_f[25*42 +: 42] = dot_product[25];
    assign dot_product_f[26*42 +: 42] = dot_product[26];
    assign dot_product_f[27*42 +: 42] = dot_product[27];
    assign dot_product_f[28*42 +: 42] = dot_product[28];
    assign dot_product_f[29*42 +: 42] = dot_product[29];
    assign dot_product_f[30*42 +: 42] = dot_product[30];
    assign dot_product_f[31*42 +: 42] = dot_product[31];
    assign dot_product_f[32*42 +: 42] = dot_product[32];
    assign dot_product_f[33*42 +: 42] = dot_product[33];
    assign dot_product_f[34*42 +: 42] = dot_product[34];
    assign dot_product_f[35*42 +: 42] = dot_product[35];
    assign dot_product_f[36*42 +: 42] = dot_product[36];
    assign dot_product_f[37*42 +: 42] = dot_product[37];
    assign dot_product_f[38*42 +: 42] = dot_product[38];
    assign dot_product_f[39*42 +: 42] = dot_product[39];
    assign dot_product_f[40*42 +: 42] = dot_product[40];
    assign dot_product_f[41*42 +: 42] = dot_product[41];
    assign dot_product_f[42*42 +: 42] = dot_product[42];
    assign dot_product_f[43*42 +: 42] = dot_product[43];
    assign dot_product_f[44*42 +: 42] = dot_product[44];
    assign dot_product_f[45*42 +: 42] = dot_product[45];
    assign dot_product_f[46*42 +: 42] = dot_product[46];
    assign dot_product_f[47*42 +: 42] = dot_product[47];
    assign normalizer_f[0*32 +: 32] = normalizer[0];
    assign normalizer_f[1*32 +: 32] = normalizer[1];
    assign normalizer_f[2*32 +: 32] = normalizer[2];
    assign normalizer_f[3*32 +: 32] = normalizer[3];
    assign normalizer_f[4*32 +: 32] = normalizer[4];
    assign normalizer_f[5*32 +: 32] = normalizer[5];
    assign normalizer_f[6*32 +: 32] = normalizer[6];
    assign normalizer_f[7*32 +: 32] = normalizer[7];
    assign normalizer_f[8*32 +: 32] = normalizer[8];
    assign normalizer_f[9*32 +: 32] = normalizer[9];
    assign normalizer_f[10*32 +: 32] = normalizer[10];
    assign normalizer_f[11*32 +: 32] = normalizer[11];
    assign normalizer_f[12*32 +: 32] = normalizer[12];
    assign normalizer_f[13*32 +: 32] = normalizer[13];
    assign normalizer_f[14*32 +: 32] = normalizer[14];
    assign normalizer_f[15*32 +: 32] = normalizer[15];
    assign normalizer_f[16*32 +: 32] = normalizer[16];
    assign normalizer_f[17*32 +: 32] = normalizer[17];
    assign normalizer_f[18*32 +: 32] = normalizer[18];
    assign normalizer_f[19*32 +: 32] = normalizer[19];
    assign normalizer_f[20*32 +: 32] = normalizer[20];
    assign normalizer_f[21*32 +: 32] = normalizer[21];
    assign normalizer_f[22*32 +: 32] = normalizer[22];
    assign normalizer_f[23*32 +: 32] = normalizer[23];
    assign normalizer_f[24*32 +: 32] = normalizer[24];
    assign normalizer_f[25*32 +: 32] = normalizer[25];
    assign normalizer_f[26*32 +: 32] = normalizer[26];
    assign normalizer_f[27*32 +: 32] = normalizer[27];
    assign normalizer_f[28*32 +: 32] = normalizer[28];
    assign normalizer_f[29*32 +: 32] = normalizer[29];
    assign normalizer_f[30*32 +: 32] = normalizer[30];
    assign normalizer_f[31*32 +: 32] = normalizer[31];
    assign normalizer_f[32*32 +: 32] = normalizer[32];
    assign normalizer_f[33*32 +: 32] = normalizer[33];
    assign normalizer_f[34*32 +: 32] = normalizer[34];
    assign normalizer_f[35*32 +: 32] = normalizer[35];
    assign normalizer_f[36*32 +: 32] = normalizer[36];
    assign normalizer_f[37*32 +: 32] = normalizer[37];
    assign normalizer_f[38*32 +: 32] = normalizer[38];
    assign normalizer_f[39*32 +: 32] = normalizer[39];
    assign normalizer_f[40*32 +: 32] = normalizer[40];
    assign normalizer_f[41*32 +: 32] = normalizer[41];
    assign normalizer_f[42*32 +: 32] = normalizer[42];
    assign normalizer_f[43*32 +: 32] = normalizer[43];
    assign normalizer_f[44*32 +: 32] = normalizer[44];
    assign normalizer_f[45*32 +: 32] = normalizer[45];
    assign normalizer_f[46*32 +: 32] = normalizer[46];
    assign normalizer_f[47*32 +: 32] = normalizer[47];
    assign correlation[0] = correlation_f[0*10 +: 10];
    assign correlation[1] = correlation_f[1*10 +: 10];
    assign correlation[2] = correlation_f[2*10 +: 10];
    assign correlation[3] = correlation_f[3*10 +: 10];
    assign correlation[4] = correlation_f[4*10 +: 10];
    assign correlation[5] = correlation_f[5*10 +: 10];
    assign correlation[6] = correlation_f[6*10 +: 10];
    assign correlation[7] = correlation_f[7*10 +: 10];
    assign correlation[8] = correlation_f[8*10 +: 10];
    assign correlation[9] = correlation_f[9*10 +: 10];
    assign correlation[10] = correlation_f[10*10 +: 10];
    assign correlation[11] = correlation_f[11*10 +: 10];
    assign correlation[12] = correlation_f[12*10 +: 10];
    assign correlation[13] = correlation_f[13*10 +: 10];
    assign correlation[14] = correlation_f[14*10 +: 10];
    assign correlation[15] = correlation_f[15*10 +: 10];
    assign correlation[16] = correlation_f[16*10 +: 10];
    assign correlation[17] = correlation_f[17*10 +: 10];
    assign correlation[18] = correlation_f[18*10 +: 10];
    assign correlation[19] = correlation_f[19*10 +: 10];
    assign correlation[20] = correlation_f[20*10 +: 10];
    assign correlation[21] = correlation_f[21*10 +: 10];
    assign correlation[22] = correlation_f[22*10 +: 10];
    assign correlation[23] = correlation_f[23*10 +: 10];
    assign correlation[24] = correlation_f[24*10 +: 10];
    assign correlation[25] = correlation_f[25*10 +: 10];
    assign correlation[26] = correlation_f[26*10 +: 10];
    assign correlation[27] = correlation_f[27*10 +: 10];
    assign correlation[28] = correlation_f[28*10 +: 10];
    assign correlation[29] = correlation_f[29*10 +: 10];
    assign correlation[30] = correlation_f[30*10 +: 10];
    assign correlation[31] = correlation_f[31*10 +: 10];
    assign correlation[32] = correlation_f[32*10 +: 10];
    assign correlation[33] = correlation_f[33*10 +: 10];
    assign correlation[34] = correlation_f[34*10 +: 10];
    assign correlation[35] = correlation_f[35*10 +: 10];
    assign correlation[36] = correlation_f[36*10 +: 10];
    assign correlation[37] = correlation_f[37*10 +: 10];
    assign correlation[38] = correlation_f[38*10 +: 10];
    assign correlation[39] = correlation_f[39*10 +: 10];
    assign correlation[40] = correlation_f[40*10 +: 10];
    assign correlation[41] = correlation_f[41*10 +: 10];
    assign correlation[42] = correlation_f[42*10 +: 10];
    assign correlation[43] = correlation_f[43*10 +: 10];
    assign correlation[44] = correlation_f[44*10 +: 10];
    assign correlation[45] = correlation_f[45*10 +: 10];
    assign correlation[46] = correlation_f[46*10 +: 10];
    assign correlation[47] = correlation_f[47*10 +: 10];

    process_div process_div_0(
        .clk(clk_104mhz),
        .dot_product_f(dot_product_f),
        .normalizer_f(normalizer_f),
        .dot_product_valid(dot_product_valid),
        .correlation_f(correlation_f),
        .correlations_valid(correlations_valid)
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

    wire [2:0] correlate_pixel[0:47];
    genvar b;
    generate for(b=0; b<48; b=b+1)
        begin : pcorrelate_gen
            process_correlation pc(
                .clk(clk_104mhz),
                .vclk(clk_65mhz),
                .hcount(hcount),
                .vcount(vcount),
                .blank(blank),
                .correlation(correlation[b]),
                .correlation_valid(correlations_valid),
                .pixel(correlate_pixel[b])
            );
        end
    endgenerate

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
            sync_gen_1 synchronize s104(clk_104mhz, SW[i], SWS[i]);
        end
    endgenerate
    genvar j;
    generate for(j=1; j<8; j=i+1)
        begin:
            sync_gen_0 synchronize s25(clk_25mhz, SW[j], SWS[j]);
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
        .probe7(dot_product[47]), // input wire [0:0]  probe7 
        .probe8(normalizer[47]), // input wire [0:0]  probe8 
        .probe9(dot_product_valid[47]), // input wire [0:0]  probe9 
        .probe10(correlation[47]), // input wire [0:0]  probe10 
        .probe11(correlations_valid), // input wire [0:0]  probe11 
        .probe12(mag_squared_tuser), // input wire [0:0]  probe12 
        .probe13(magnitude_tlast), // input wire [0:0]  probe13 
        .probe14(mag_squared_tlast), // input wire [0:0]  probe14 
        .probe15(in_range), // input wire [0:0]  probe15
        .probe16(debug[47][76:61]),
        .probe17(debug[47][60:45]),
        .probe18(debug[47][44:3]),
        .probe19(debug[47][2]),
        .probe20(debug[47][1]),
        .probe21(debug[47][0])
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
    reg [9:0] vcount_stage;
    reg [2:0] correlate_pixel_out;
    always @(posedge clk_65mhz) begin
        hsync_stage <= {hsync_stage[0],hsync};
        vsync_stage <= {vsync_stage[0],vsync};
        hsync_out <= hsync_stage[1];
        vsync_out <= vsync_stage[1];
        vcount_stage <= vcount;
        correlate_pixel_out <= (vcount_stage < 48) ? correlate_pixel[vcount_stage[5:0]]: 3'b000;
    end
    assign VGA_R = {4{hist_pixel[0] | correlate_pixel_out[0]}};
    assign VGA_G = {4{hist_pixel[1] | correlate_pixel_out[1]}};
    assign VGA_B = {4{hist_pixel[2] | correlate_pixel_out[2]}};
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