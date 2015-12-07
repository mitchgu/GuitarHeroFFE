module AV_string
    #(
    parameter y_location = 10'b0
    )
    (
    input clk,
    input [15:0] song_time,
    input match_en,
    input [4:0] fret,
    input [15:0] match_time,
    input [10:0] hcount,
    input [9:0] vcount,
    
    output [12:0] string_pixel
    );
    
    reg[54:0] x;
    reg [49:0] y;
    reg [24:0] values;
    wire [64:0] note_pixels;


    reg [9:0] y_loc = y_location;

    AV_note_sprite notes [4:0] (
        .clk65(clk),
        .x(x),
        .y(y_loc),
        .hcount(hcount),
        .vcount(vcount),
        .value(values),
        
        .note_pixel(note_pixels)
    );

    reg [511:0] note_times;
    reg [159:0] note_frets;
    
    initial begin //Mary had a Little Lamb
    note_times[511:496] = 200;
    note_frets[159:155] = 4;

    note_times[495:480] = 300;
    note_frets[154:150] = 2;

    note_times[479:464] = 400;
    note_frets[149:145] = 0;

    note_times[463:448] = 500;
    note_frets[144:140] = 2;

    note_times[447:432] = 600;
    note_frets[139:135] = 4;

    note_times[431:416] = 700;
    note_frets[134:130] = 4;

    note_times[415:400] = 800;
    note_frets[129:125] = 4;

    note_times[399:384] = 1000;
    note_frets[124:120] = 2;

    note_times[383:368] = 1100;
    note_frets[119:115] = 2;

    note_times[367:352] = 1200;
    note_frets[114:110] = 2;

    note_times[351:336] = 1400;
    note_frets[109:105] = 4;

    note_times[335:320] = 1500;
    note_frets[104:100] = 7;

    note_times[319:304] = 1600;
    note_frets[99:95] = 7;

    note_times[303:288] = 1800;
    note_frets[94:90] = 4;

    note_times[287:272] = 1900;
    note_frets[89:85] = 2;

    note_times[271:256] = 2000;
    note_frets[84:80] = 0;

    note_times[255:240] = 2100;
    note_frets[79:75] = 2;

    note_times[239:224] = 2200;
    note_frets[74:70] = 4;

    note_times[223:208] = 2300;
    note_frets[69:65] = 4;

    note_times[207:192] = 2400;
    note_frets[64:60] = 4;

    note_times[191:176] = 2500;
    note_frets[59:55] = 4;

    note_times[175:160] = 2600;
    note_frets[54:50] = 2;

    note_times[159:144] = 2700;
    note_frets[49:45] = 2;

    note_times[143:128] = 2800;
    note_frets[44:40] = 4;

    note_times[127:112] = 2900;
    note_frets[39:35] = 2;

    note_times[111:96] = 3000;
    note_frets[34:30] = 0;

    note_times[95:80] = 0;
    note_frets[29:25] = 0;

    note_times[79:64] = 0;
    note_frets[24:20] = 0;

    note_times[51:48] = 0;
    note_frets[19:15] = 0;

    note_times[47:32] = 0;
    note_frets[14:10] = 0;

    note_times[31:16] = 0;
    note_frets[9:5] = 0;

    note_times[15:0] = 0;
    note_frets[4:0] = 0;
    end
    
    always @(posedge clk) begin
        if( (song_time > note_times[511:496]) && (song_time - note_times[511:496] > 50) ) begin
        //if the leftmost note is old, and it is older than 500ms, get rid of it
            note_times[511:0] <= {note_times[495:0] , 16'b0};
            note_frets[159:0] <= {note_frets[154:0] , 5'b0};
        end
    
        //calculate/refresh note-sprite x-values and fret numbers
        x[54:44] <= (note_times[511:496] + 50 - song_time) / 10;
        values[24:20] <= note_frets[159:155];
        x[43:33] <= (note_times[495:480] + 50 - song_time) / 10;
        values[19:15] <= note_frets[154:150];
        x[32:22] <= (note_times[479:464] + 50 - song_time) / 10;
        values[14:10] <= note_frets[149:145];
        x[21:11] <= (note_times[463:448] + 50 - song_time) / 10;
        values[9:5] <= note_frets[144:140];
        x[10:0] <= (note_times[447:432] + 50 - song_time) / 10;
        values[4:0] <= note_frets[139:135];
    
    end
    //OR all the pixel bits together. Shoddy practice, could be improved
    assign string_pixel = note_pixels[64:52]|note_pixels[51:39]|note_pixels[38:26]|note_pixels[25:13]|note_pixels[12:0];
    
endmodule