module AV_block(
    input clk,
    input clk65,
    input pause,
    input [15:0] song_time,
    input [31:0] score,
    input [29:0] fret,
    input [15:0] fret_time,
    input [5:0] fret_en,
    
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
    
    
    );
    
    wire [10:0] hcount;
    wire [9:0] vcount;
    
    wire [12:0] menu_pixel;
    wire blank;
    wire [11:0] bg_pixel;
    wire [12:0] string_pixel6, string_pixel5, string_pixel4, string_pixel3, string_pixel2, string_pixel1;
    
    xvga xvga(
        .vclock(clk65),
        .hcount(hcount),
        .vcount(vcount),
        .vsync(VGA_VS),
        .hsync(VGA_HS),
        .blank(blank)
    );
    
    AV_integrator integrator(
        .clk65(clk65),
        .menu_pixel(menu_pixel),
        .score_pixel(13'b0),
        .string1_pixel(13'b0),
        .string2_pixel(13'b0),
        .string3_pixel(13'b0),
        .string4_pixel(13'b0),
        .string5_pixel(13'b0),
        .string6_pixel(string_pixel6),
        .bg_pixel(bg_pixel),
        .pixel( {4'b0, VGA_G, VGA_B} )
    );
    
    assign VGA_R = 4'b1111;
    
    AV_bg bg(
        .clk65(clk65),
        .hcount(hcount),
        .vcount(vcount),
        .bg_pixel(bg_pixel)
    );
    
    
    AV_menu_graphics menu(
        .clk65(clk65),
        .pause(pause),
        .hcount(hcount),
        .vcount(vcount),
        .menu_pixel(menu_pixel)
    );

    AV_string
    #(
        .y_location(400)
    ) string6
    (
        .clk(clk65),
        .song_time(song_time),
        .match_en(fret_en[5]),
        .fret(fret[29:25]),
        .match_time(fret_time),
        .hcount(hcount),
        .vcount(vcount),
        .string_pixel(string_pixel6)
    );

    AV_string
    #(
        .y_location(450)
    ) string5
    (
        .clk(clk65),
        .song_time(song_time),
        .match_en(fret_en[4]),
        .fret(fret[24:20]),
        .match_time(fret_time),
        .hcount(hcount),
        .vcount(vcount),
        .string_pixel(string_pixel5)
    );

    AV_string
    #(
        .y_location(500)
    ) string4
    (
        .clk(clk65),
        .song_time(song_time),
        .match_en(fret_en[3]),
        .fret(fret[19:15]),
        .match_time(fret_time),
        .hcount(hcount),
        .vcount(vcount),
        .string_pixel(string_pixel4)
    );

    AV_string
    #(
        .y_location(550)
    ) string3
    (
        .clk(clk65),
        .song_time(song_time),
        .match_en(fret_en[2]),
        .fret(fret[14:10]),
        .match_time(fret_time),
        .hcount(hcount),
        .vcount(vcount),
        .string_pixel(string_pixel3)
    );

    AV_string
    #(
        .y_location(600)
    ) string2
    (
        .clk(clk65),
        .song_time(song_time),
        .match_en(fret_en[1]),
        .fret(fret[9:5]),
        .match_time(fret_time),
        .hcount(hcount),
        .vcount(vcount),
        .string_pixel(string_pixel2)
    );

    AV_string
    #(
        .y_location(650)
    ) string1
    (
        .clk(clk65),
        .song_time(song_time),
        .match_en(fret_en[0]),
        .fret(fret[4:0]),
        .match_time(fret_time),
        .hcount(hcount),
        .vcount(vcount),
        .string_pixel(string_pixel1)
    );
    
    
endmodule