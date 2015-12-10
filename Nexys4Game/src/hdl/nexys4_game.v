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

module nexys4_game(
   input CLK100MHZ,
   input[15:0] SW, 
   input BTNC, BTNU, BTNL, BTNR, BTND,
   input[7:0] JA,
   output[3:0] VGA_R, 
   output[3:0] VGA_B, 
   output[3:0] VGA_G,
   output VGA_HS, 
   output VGA_VS, 
   output LED16_B, LED16_G, LED16_R,
   output LED17_B, LED17_G, LED17_R,
   output[15:0] LED, // LEDs above switches
   output[7:0] SEG,  // segments A-G (0-6), DP (7)
   output[7:0] AN    // Display 0-7
   );

    wire CLK25MHZ;
    clock_4divider clk_divider(.clk(CLK100MHZ),.clk_div(CLK25MHZ));

    wire CLK65MHZ, CLK130MHZ;
    clk_wiz_65 clk_gen(.clk_in(CLK100MHZ),.clk_out(CLK65MHZ),.clk_out2(CLK130MHZ));

//  INSTANTIATE SEVEN SEGMENT DISPLAY
    wire [31:0] seg_data;
    wire [6:0] segments;
    display_8hex display(.clk(CLK100MHZ),.data(seg_data), .seg(segments), .strobe(AN));    
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;
    
// INSTANTIATE DEBOUNCED BUTTONS/SWITCHES
    wire reset_debounce;

    // Debounce pause switch
    wire switch0_noisy, switch0;
    debounce switch0_debouncer(
        .clock(CLK100MHZ),
        .reset(reset_debounce),
        .noisy(switch0_noisy),
        .clean(switch0));
        
        // Debounce pause switch
    wire switch1_noisy, switch1;
    debounce switch1_debouncer(
        .clock(CLK100MHZ),
        .reset(reset_debounce),
        .noisy(switch1_noisy),
        .clean(switch1));
                       
    // Debounce reset button
    wire center_button_noisy, center_button;
    debounce center_button_debouncer(
        .clock(CLK100MHZ),
        .reset(reset_debounce),
        .noisy(center_button_noisy),
        .clean(center_button));

//////////////////////////////////////////////////////////////////////////////////
//  BLOCKS

    wire [15:0] song_time;
    wire pause, reset;

    wire [37*16-1:0] metadata_link;
    wire [36:0] metadata_request, metadata_available;
    
    
    wire [31:0] score;
    wire [29:0] fret;
    wire [15:0] fret_time;
    wire [5:0] fret_en;
    
    reg [36:0] NDATA;
    
    wire note_serial_sync, note_serial_data;
    synchronize sync_sync(
        .clk(CLK100MHZ),
        .in(JA[1]),
        .out(note_serial_sync));

    synchronize data_sync(
        .clk(CLK100MHZ),
        .in(JA[0]),
        .out(note_serial_data));
    
    wire [47:0] active;
    note_deserializer deserial(
        .clk(CLK100MHZ),
        .note_serial_sync(note_serial_sync),
        .note_serial_data(note_serial_data),
        .active(active)
    );
    
    always @(posedge CLK100MHZ) begin //AI-driven guitar player
        if(switch1) begin
            if(NDATA == 0) begin
                NDATA <= 1;
            end
            else begin
                NDATA[36:0] <= {NDATA[35:0], 1'b0};
            end
        end
        else begin
            NDATA[0] <= 0;
            NDATA[36:1] <= active[35:0];
        end
    end
    
    SC_block SC(
        .clk(CLK100MHZ),
        .pause(pause),
        .reset(reset),
        .song_time(song_time),
        .NDATA(NDATA),
        .metadata_link(metadata_link),
        .metadata_available(metadata_available),
        
        .metadata_request(metadata_request),
        .score(score),
        .fret(fret),
        .fret_time(fret_time),
        .fret_en(fret_en)
    );

    CL_block CL(
        .clk(CLK100MHZ),
        .clk25(CLK25MHZ),
        .pause_SW(switch0),
        .reset_button(center_button),
        .metadata_request(metadata_request),
        .SD_CD(),
        
        .SD_DAT(),
        
        .SD_RESET(),
        .SD_SCK(),
        .SD_CMD(),
        .metadata_link(metadata_link),
        .metadata_available(metadata_available),
        .reset(reset),
        .pause(pause),
        .song_time(song_time)
    );

    AV_block AV(
        .clk(CLK100MHZ),
        .clk65(CLK65MHZ),
        .clk130(CLK130MHZ),
        .reset(center_button),
        .pause(pause),
        .song_time(song_time),
        .score(score),
        .fret(fret),
        .fret_time(fret_time),
        .fret_en(fret_en),
        
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS)
        
    );





//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
//  
    // Debounce all buttons
    assign reset_debounce = 0;
    assign switch0_noisy = SW[0];
    assign switch1_noisy = SW[1];
    assign center_button_noisy = BTNC;

    // Assign switch LEDs to switch states
    assign LED = SW;
    
    // Display 01234567 then fsm state and timer time left
    assign seg_data[15:0] = song_time;
    assign seg_data[31:16] = score[15:0];

//
//////////////////////////////////////////////////////////////////////////////////
 
endmodule