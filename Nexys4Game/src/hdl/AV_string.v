module AV_string
    #(
    parameter y_location = 10'b0
    )
    (
    input clk65,
    input clk130,
    input reset,
    input [15:0] song_time,
    input match_en,
    input [4:0] fret,
    input [15:0] match_time,
    input [10:0] hcount,
    input [9:0] vcount,
    input [13*16-1:0] pdata,
    
    output [9:0] paddr,
    output [12:0] string_pixel
    );
    
    reg [9:0] x[4:0];

    localparam playX = 180;

    reg [24:0] values;
    wire [12:0] note_pixels[4:0];

    reg [4:0] note_frets[4:0];

    wire [7:0] pdata_addr[4:0]; //CHANGE TO FRET VALUE ASSIGNMENT
    assign pdata_addr[0] = note_frets[0]*13;
    assign pdata_addr[1] = note_frets[1]*13;
    assign pdata_addr[2] = note_frets[2]*13;
    assign pdata_addr[3] = note_frets[3]*13;
    assign pdata_addr[4] = note_frets[4]*13;

    wire [12:0] pdata_pass[4:0];
    assign pdata_pass[0] = pdata[pdata_addr[0]+:13];
    assign pdata_pass[1] = pdata[pdata_addr[1]+:13];
    assign pdata_pass[2] = pdata[pdata_addr[2]+:13];
    assign pdata_pass[3] = pdata[pdata_addr[3]+:13];
    assign pdata_pass[4] = pdata[pdata_addr[4]+:13];

    wire [9:0] paddrs[4:0];

    fret_sprite #(
        .Y(y_location)
    ) sprite0 (
        .clk(clk65),
        .hcount(hcount),
        .vcount(vcount),
        .x(x[0]),
        .paddr(paddrs[0]),
        .pdata(pdata_pass[0]),
        .pixel(note_pixels[0])
    );

    fret_sprite #(
        .Y(y_location)
    ) sprite1 (
        .clk(clk65),
        .hcount(hcount),
        .vcount(vcount),
        .x(x[1]),
        .paddr(paddrs[1]),
        .pdata(pdata_pass[1]),
        .pixel(note_pixels[1])
    );

    fret_sprite #(
        .Y(y_location)
    ) sprite2 (
        .clk(clk65),
        .hcount(hcount),
        .vcount(vcount),
        .x(x[2]),
        .paddr(paddrs[2]),
        .pdata(pdata_pass[2]),
        .pixel(note_pixels[2])
    );

    fret_sprite #(
        .Y(y_location)
    ) sprite3 (
        .clk(clk65),
        .hcount(hcount),
        .vcount(vcount),
        .x(x[3]),
        .paddr(paddrs[3]),
        .pdata(pdata_pass[3]),
        .pixel(note_pixels[3])
    );

    fret_sprite #(
        .Y(y_location)
    ) sprite4 (
        .clk(clk65),
        .hcount(hcount),
        .vcount(vcount),
        .x(x[4]),
        .paddr(paddrs[4]),
        .pdata(pdata_pass[4]),
        .pixel(note_pixels[4])
    );

    assign paddr = paddrs[0]|paddrs[1]|paddrs[2]|paddrs[3]|paddrs[4];

    //reg [9:0] y_loc = y_location;

    /*
    AV_note_sprite notes [4:0] (
        .clk65(clk),
        .x(x),
        .y(y_loc),
        .hcount(hcount),
        .vcount(vcount),
        .value(values),
        
        .note_pixel(note_pixels)
    );
    */

    /* REGISTER METADATA IS BAD

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
    
    */
    
    reg [4:0] note_index = 0;
    reg [4:0] note_addr = 0;
    
    wire [15:0] dout_time;
    note_times note_times_mem(
        .clka(clk130),
        .ena(1'b1),
        .addra(note_addr), //5-bit address
        .douta(dout_time) //16-bit note time out
    );
    
    wire [4:0] dout_fret;
    note_frets note_frets_mem(
        .clka(clk130),
        .ena(1'b1),
        .addra(note_addr), //5-bit address
        .douta(dout_fret) //5-bit note fret out
    );
    
    reg[2:0] loading_state = 5;
    reg [15:0] note_times[4:0];
    
    always @(posedge clk65) begin

        if(reset) begin
            note_index <= 0;
            note_addr <= 0;
            loading_state <= 5;
        end
            else begin
            if( (song_time > note_times[0]) && (song_time - note_times[0] > 50) ) begin
            //if the note is old, and it is older than 500ms, get rid of it
                note_index <= note_index + 1;
            end

            if(vcount == 0) begin //update all of the notes. Only need to do this once a frame
                case(loading_state)
                    0: begin //load for the 1st sprite
                        note_times[0] <= dout_time;
                        note_frets[0] <= dout_fret;
                        note_addr <= note_addr + 1;
                        loading_state <= loading_state + 1;
                    end
                    1: begin //load for the 2nd
                        note_times[1] <= dout_time;
                        note_frets[1] <= dout_fret;
                        note_addr <= note_addr + 1;
                        loading_state <= loading_state + 1;
                    end
                    2: begin
                        note_times[2] <= dout_time;
                        note_frets[2] <= dout_fret;
                        note_addr <= note_addr + 1;
                        loading_state <= loading_state + 1;
                    end
                    3: begin
                        note_times[3] <= dout_time;
                        note_frets[3] <= dout_fret;
                        note_addr <= note_addr + 1;
                        loading_state <= loading_state + 1;
                    end
                    4: begin
                        note_times[4] <= dout_time;
                        note_frets[4] <= dout_fret;
                        note_addr <= note_index;
                        loading_state <= 6;
                    end
                    5: begin //We've just entered the load sequence
                        loading_state <= 0;
                        note_addr <= note_index;
                    end
                endcase
            end
            if(vcount == 1 && loading_state == 6)
                loading_state <= 5; //reprime state for leading in next frame
        
            //calculate/refresh note-sprite x-values and fret numbers
            x[0] <= (note_times[0] - song_time)*2 + playX;
            x[1] <= (note_times[1] - song_time)*2 + playX;
            x[2] <= (note_times[2] - song_time)*2 + playX;
            x[3] <= (note_times[3] - song_time)*2 + playX;
            x[4] <= (note_times[4] - song_time)*2 + playX;
        end
    end
    //OR all the pixel bits together. Shoddy practice, could be improved
    assign string_pixel = note_pixels[0]|note_pixels[1]|note_pixels[2]|note_pixels[3]|note_pixels[4];
    
endmodule