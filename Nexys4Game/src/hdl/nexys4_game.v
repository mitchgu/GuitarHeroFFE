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
    debounce down_button_debouncer(
        .clock(CLK100MHZ),
        .reset(reset_debounce),
        .noisy(switch0_noisy),
        .clean(switch0));
                        
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

    SC_block SC(
        .clk(CLK100MHZ),
        .pause(pause),
        .song_time(song_time),
        .NDATA(),
        .metadata_link(),
        
        .metadata_request(),
        .score(),
        .fret(),
        .note_time(),
        .en()
    );

    CL_block CL(
        .clk(CLK100MHZ),
        .clk25(CLK25MHZ),
        .pause_SW(switch0),
        .reset_button(center_button),
        .SD_DAT(),
        
        .reset(reset),
        .pause(pause),
        .song_time(song_time)
    );

    AV_block AV(
        
        
        
        
    );





//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
//  
    // Debounce all buttons
    assign reset_debounce = 0;
    assign switch0_noisy = SW[0];
    assign center_button_noisy = BTNC;

    // Assign RGB LEDs from buttons
    assign LED17_R = left_button;
    assign LED17_G = up_button;
    assign LED17_B = left_button & up_button;
    assign LED16_R = right_button;
    assign LED16_G = down_button;
    assign LED16_B = right_button & down_button;
    
    // Assign switch LEDs to switch states
    assign LED = SW;
    
    // Display 01234567 then fsm state and timer time left
    assign seg_data = 32'h01234567;

//
//////////////////////////////////////////////////////////////////////////////////
 
endmodule