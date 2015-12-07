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

    wire [7:0] pdata_addr[4:0];
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
    
    reg [4:0] note_matched = 0;
        
    wire [15:0] xpos[4:0]; //position math, with 16-bit value
    assign xpos[0] = (note_times[0] - song_time)*2 + playX;
    assign xpos[1] = (note_times[1] - song_time)*2 + playX;
    assign xpos[2] = (note_times[2] - song_time)*2 + playX;
    assign xpos[3] = (note_times[3] - song_time)*2 + playX;
    assign xpos[4] = (note_times[4] - song_time)*2 + playX;    

    
    always @(posedge clk65) begin

        if(reset) begin
            note_index <= 0;
            note_addr <= 0;
            loading_state <= 5;
            note_times[0] <= 0;
            note_times[1] <= 0;
            note_times[2] <= 0;
            note_times[3] <= 0;
            note_times[4] <= 0;
            note_matched <= 0;
        end
        else begin
            if( (song_time > note_times[0]) && (song_time - note_times[0] > 50) && (vcount == 1 && hcount == 0) ) begin //if the note is old, and it is older than 500ms, get rid of it
                note_index <= note_index + 1;
                note_matched[3:0] <= note_matched[4:1];
                note_matched[4] <= 0;
            end

            if(match_en) begin
                if(match_time == note_times[0]) begin
                    note_matched[0] <= 1;
                end
                else if(match_time == note_times[1]) begin
                    note_matched[1] <= 1;
                end
                else if(match_time == note_times[2]) begin
                    note_matched[2] <= 1;
                end
                else if(match_time == note_times[3]) begin
                    note_matched[3] <= 1;
                end
                else if(match_time == note_times[4]) begin
                    note_matched[4] <= 1;
                end
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
            if( xpos[0] > 1023)
                x[0] <= 1023;
            else
                x[0] <= xpos[0][9:0];

            if( xpos[1] > 1023)
                x[1] <= 1023;
            else
                x[1] <= xpos[1][9:0];

            if( xpos[2] > 1023)
                x[2] <= 1023;
            else
                x[2] <= xpos[2][9:0];

            if( xpos[3] > 1023)
                x[3] <= 1023;
            else
                x[3] <= xpos[3][9:0];

            if( xpos[4] > 1023)
                x[4] <= 1023;
            else
                x[4] <= xpos[4][9:0];

                
                
        end
    end
    //OR all the pixel bits together. Shoddy practice, could be improved
    assign string_pixel[12] = note_pixels[0][12]|note_pixels[1][12]|note_pixels[2][12]|note_pixels[3][12]|note_pixels[4][12];
    wire [11:0] note_pixels_inv[4:0];
    assign note_pixels_inv[0] = note_pixels[0][11:0]^{12{note_matched[0]&note_pixels[0][12]}};
    assign note_pixels_inv[1] = note_pixels[1][11:0]^{12{note_matched[1]&note_pixels[1][12]}};
    assign note_pixels_inv[2] = note_pixels[2][11:0]^{12{note_matched[2]&note_pixels[2][12]}};
    assign note_pixels_inv[3] = note_pixels[3][11:0]^{12{note_matched[3]&note_pixels[3][12]}};
    assign note_pixels_inv[4] = note_pixels[4][11:0]^{12{note_matched[4]&note_pixels[4][12]}};

    assign string_pixel[11:0] = note_pixels_inv[0]|note_pixels_inv[1]|note_pixels_inv[2]|note_pixels_inv[3]|note_pixels_inv[4];
    
endmodule