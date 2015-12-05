module AV_block(
    input clk,
    input clk65,
    input pause,
    
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
    
    
    );
    
    wire [10:0] hcount;
    wire [9:0] vcount;
    
    wire [12:0] menu_pixel;
    
    xvga xvga(
        .vclock(clk65),
        .hcount(hcount),
        .vcount(vcount),
        .vsync(VGA_VS),
        .hsync(VGA_HS),
        .blank(),
    );
    
    AV_integrator integrator(
        .clk65(clk65),
        .menu_pixel(menu_pixel),
        .score_pixel(),
        .string1_pixel(),
        .string2_pixel(),
        .string3_pixel(),
        .string4_pixel(),
        .string5_pixel(),
        .string6_pixel(),
        .bg_pixel(),
        .pixel( {VGA_R, VGA_G, VGA_B} )
    );
    
    AV_menu_graphics menu(
        .clk65(clk65),
        .pause(pause),
        .hcount(hcount),
        .vcount(vcount),
        .menu_pixel(menu_pixel)
    );
    
endmodule