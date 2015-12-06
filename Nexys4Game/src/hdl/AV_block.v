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
        .score_pixel(),
        .string1_pixel(string_pixel1),
        .string2_pixel(string_pixel2),
        .string3_pixel(string_pixel3),
        .string4_pixel(string_pixel4),
        .string5_pixel(string_pixel5),
        .string6_pixel(string_pixel6),
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

    wire string_pixel6;
    AV_string string6
    #(
        y_location = 400
    )
    (
        .clk(clk65),
        .song_time(song_time),
        .match_en(fret_en[5]),
        .fret(fret[29:25]),
        .match_time(fret_time),
        .string_pixel(string_pixel6)
    )

    wire string_pixel5;
    AV_string string5
    #(
        y_location = 450
    )
    (
        .clk(clk65),
        .song_time(song_time),
        .match_en(fret_en[4]),
        .fret(fret[24:20]),
        .match_time(fret_time),
        .string_pixel(string_pixel5)
    )

    wire string_pixel4;
    AV_string string4
    #(
        y_location = 500
    )
    (
        .clk(clk65),
        .song_time(song_time),
        .match_en(fret_en[3]),
        .fret(fret[19:15]),
        .match_time(fret_time),
        .string_pixel(string_pixel4)
    )

    wire string_pixel3;
    AV_string string3
    #(
        y_location = 550
    )
    (
        .clk(clk65),
        .song_time(song_time),
        .match_en(fret_en[2]),
        .fret(fret[14:10]),
        .match_time(fret_time),
        .string_pixel(string_pixel3)
    )

    wire string_pixel2;
    AV_string string2
    #(
        y_location = 600
    )
    (
        .clk(clk65),
        .song_time(song_time),
        .match_en(fret_en[1]),
        .fret(fret[9:5]),
        .match_time(fret_time),
        .string_pixel(string_pixel2)
    )

    wire string_pixel1;
    AV_string string1
    #(
        y_location = 650
    )
    (
        .clk(clk65),
        .song_time(song_time),
        .match_en(fret_en[0]),
        .fret(fret[4:0]),
        .match_time(fret_time),
        .string_pixel(string_pixel1)
    )
    
    
endmodule