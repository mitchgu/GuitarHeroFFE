module AV_block(
    input clk,
    input clk65,
    input clk130,
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
    wire [11:0] bg_pixel;
    wire [12:0] string_pixel6, string_pixel5, string_pixel4, string_pixel3, string_pixel2, string_pixel1;
    
    wire [9:0] paddr6, paddr5, paddr4, paddr3, paddr2, paddr1;

    /////////////
    // SPRITE BRAMS

    // Inferred bram
    reg [12:0] fret_00 [0:1023];
    initial $readmemb("mif/fret_00.mif", fret_00);
    reg [12:0] fret_01 [0:1023];
    initial $readmemb("mif/fret_01.mif", fret_01);
    reg [12:0] fret_02 [0:1023];
    initial $readmemb("mif/fret_02.mif", fret_02);
    reg [12:0] fret_03 [0:1023];
    initial $readmemb("mif/fret_03.mif", fret_03);
    reg [12:0] fret_04 [0:1023];
    initial $readmemb("mif/fret_04.mif", fret_04);
    reg [12:0] fret_05 [0:1023];
    initial $readmemb("mif/fret_05.mif", fret_05);
    reg [12:0] fret_06 [0:1023];
    initial $readmemb("mif/fret_06.mif", fret_06);
    reg [12:0] fret_07 [0:1023];
    initial $readmemb("mif/fret_07.mif", fret_07);
    reg [12:0] fret_08 [0:1023];
    initial $readmemb("mif/fret_08.mif", fret_08);
    reg [12:0] fret_09 [0:1023];
    initial $readmemb("mif/fret_09.mif", fret_09);
    reg [12:0] fret_10 [0:1023];
    initial $readmemb("mif/fret_10.mif", fret_10);
    reg [12:0] fret_11 [0:1023];
    initial $readmemb("mif/fret_11.mif", fret_11);
    reg [12:0] fret_12 [0:1023];
    initial $readmemb("mif/fret_12.mif", fret_12);
    reg [12:0] fret_13 [0:1023];
    initial $readmemb("mif/fret_13.mif", fret_13);
    reg [12:0] fret_14 [0:1023];
    initial $readmemb("mif/fret_14.mif", fret_14);
    reg [12:0] fret_15 [0:1023];
    initial $readmemb("mif/fret_15.mif", fret_15);
    reg [12:0] fret_16 [0:1023];
    initial $readmemb("mif/fret_16.mif", fret_16);
    reg [12:0] fret_17 [0:1023];
    initial $readmemb("mif/fret_17.mif", fret_17);

    wire [9:0] paddr;
    assign paddr = paddr6|paddr5|paddr4|paddr3|paddr2|paddr1;
    wire [13*16-1:0] pdata;
    assign pdata = 
        {
            fret_15[paddr],
            fret_14[paddr],
            fret_13[paddr],
            fret_12[paddr],
            fret_11[paddr],
            fret_10[paddr],
            fret_09[paddr],
            fret_08[paddr],
            fret_07[paddr],
            fret_06[paddr],
            fret_05[paddr],
            fret_04[paddr],
            fret_03[paddr],
            fret_02[paddr],
            fret_01[paddr],
            fret_00[paddr]
        };

    //
    /////////////
    
    wire hsync,vsync,blank,pblank;
    AV_sync_pipeline #(
        .stages(3)
    )
    pipe (
        .clk(clk65),
        .hsync(hsync),
        .vsync(vsync),
        .blank(blank),
        
        .phsync(VGA_HS),
        .pvsync(VGA_VS),
        .pblank(pblank)
    );
    
    xvga xvga(
        .vclock(clk65),
        
        .hcount(hcount),
        .vcount(vcount),
        .vsync(vsync),
        .hsync(hsync),
        .blank(blank)
    );
    
    wire [11:0] pixel_out;
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
        .pixel( pixel_out )
    );
    
    assign {VGA_R, VGA_G, VGA_B} = pblank ? 12'b0 : pixel_out;
    
    bg_display bg(
        .clk(clk65),
        .clk2(clk130),
        .vsync(vsync),
        .blank(blank),
        .pixel_out(bg_pixel)
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
        .y_location(264)
    ) string6 // highest string
    (
        .clk65(clk65),
        .clk130(clk130),
        .reset(reset),
        .song_time(song_time),
        .match_en(fret_en[5]),
        .fret(fret[29:25]),
        .match_time(fret_time),
        .hcount(hcount),
        .vcount(vcount),
        .pdata(pdata),

        .paddr(paddr6),
        .string_pixel(string_pixel6)
    );

    AV_string
    #(
        .y_location(294)
    ) string5
    (
        .clk65(clk65),
        .clk130(clk130),
        .reset(reset),
        .song_time(song_time),
        .match_en(fret_en[4]),
        .fret(fret[24:20]),
        .match_time(fret_time),
        .hcount(hcount),
        .vcount(vcount),
        .pdata(pdata),

        .paddr(paddr5),
        .string_pixel(string_pixel5)
    );

    AV_string
    #(
        .y_location(324)
    ) string4
    (
        .clk65(clk65),
        .clk130(clk130),
        .reset(reset),
        .song_time(song_time),
        .match_en(fret_en[3]),
        .fret(fret[19:15]),
        .match_time(fret_time),
        .hcount(hcount),
        .vcount(vcount),
        .pdata(pdata),

        .paddr(paddr4),
        .string_pixel(string_pixel4)
    );

    AV_string
    #(
        .y_location(354)
    ) string3
    (
        .clk65(clk65),
        .clk130(clk130),
        .reset(reset),
        .song_time(song_time),
        .match_en(fret_en[2]),
        .fret(fret[14:10]),
        .match_time(fret_time),
        .hcount(hcount),
        .vcount(vcount),
        .pdata(pdata),

        .paddr(paddr3),
        .string_pixel(string_pixel3)
    );

    AV_string
    #(
        .y_location(384)
    ) string2
    (
        .clk65(clk65),
        .clk130(clk130),
        .reset(reset),
        .song_time(song_time),
        .match_en(fret_en[1]),
        .fret(fret[9:5]),
        .match_time(fret_time),
        .hcount(hcount),
        .vcount(vcount),
        .pdata(pdata),

        .paddr(paddr2),
        .string_pixel(string_pixel2)
    );

    AV_string
    #(
        .y_location(414)
    ) string1
    (
        .clk65(clk65),
        .clk130(clk130),
        .reset(reset),
        .song_time(song_time),
        .match_en(fret_en[0]),
        .fret(fret[4:0]),
        .match_time(fret_time),
        .hcount(hcount),
        .vcount(vcount),
        .pdata(pdata),

        .paddr(paddr1),
        .string_pixel(string_pixel1)
    );
    
    
endmodule