module CL_metadata_controller(
    input clk, //100mhz clk
    input clk25, //25mhz clk
    input reset,
    input [15:0] song_time,
    input write_en, //signals a new word to be written
    input [31:0] write_word, //word to be written    
    input [36:0] metadata_request,
    
    output reg [36:0] metadata_available,
    output reg [37*16-1:0] metadata_link,
    output reg loaded
    
    );
    /*
    reg [11:0] pointer = 0;
    reg [11:0] new_pointer = 0; //1 clk delay on updating pointer
    */
    
    reg running;
    
    initial running = 0;
    initial loaded = 1;
    initial metadata_link = 0;
    
    /*
    reg [255:0] note24;
    reg [255:0] note26;
    reg [255:0] note28;
    reg [255:0] note31;

    
    initial begin
        note24[255:240] = 400;
        note24[239:224] = 2000;
        note24[223:208] = 3000;
        note24[207:192] = 0;
        note24[191:176] = 0;
        note24[175:160] = 0;
        note24[159:144] = 0;
        note24[143:128] = 0;
        note24[127:112] = 0;
        note24[111:96] = 0;
        note24[95:80] = 0;
        note24[79:64] = 0;
        note24[63:48] = 0;
        note24[47:32] = 0;
        note24[31:16] = 0;
        note24[15:0] = 0;

        note26[255:240] = 300;
        note26[239:224] = 500;
        note26[223:208] = 1000;
        note26[207:192] = 1100;
        note26[191:176] = 1200;
        note26[175:160] = 1900;
        note26[159:144] = 2100;
        note26[143:128] = 2600;
        note26[127:112] = 2700;
        note26[111:96] = 2900;
        note26[95:0] = 0;

        note28[255:240] = 200;
        note28[239:224] = 600;
        note28[223:208] = 700;
        note28[207:192] = 800;
        note28[191:176] = 1400;
        note28[175:160] = 1800;
        note28[159:144] = 2200;
        note28[143:128] = 2300;
        note28[127:112] = 2400;
        note28[111:96] = 2500;
        note28[95:80] = 2800;
        note28[79:0] = 0;

        note31[255:240] = 1500;
        note31[239:224] = 1600;
        note31[223:0] = 0;
    end
    */
    
    reg [3:0] addra24 = 0;
    wire [15:0] douta24;
    note24 note24(
        .clka(clk),
        .ena(1'b1),
        .addra(addra24),
        .douta(douta24)
    );

    reg [3:0] addra26 = 0;
    wire [15:0] douta26;
    note26 note26(
        .clka(clk),
        .ena(1'b1),
        .addra(addra26),
        .douta(douta26)
    );

    reg [3:0] addra28 = 0;
    wire [15:0] douta28;
    note28 note28(
        .clka(clk),
        .ena(1'b1),
        .addra(addra28),
        .douta(douta28)
    );
    
    reg [3:0] addra31 = 0;
    wire [15:0] douta31;
    note31 note31(
        .clka(clk),
        .ena(1'b1),
        .addra(addra31),
        .douta(douta31)
    );
    
    always @(posedge clk) begin
        if(reset) begin
            addra24 <= 0;
            addra26 <= 0;
            addra28 <= 0;
            addra31 <= 0;
            running <= 0;
            metadata_available <= 0;
            metadata_link <= 0;
        end
        else begin
            if(song_time > 5)
                running <= 1;
        
            if(metadata_request[24] == 1 && running && metadata_available[24] == 0) begin
                metadata_link[25*16-1:24*16] <= douta24;
                if(addra24 < 15)
                    addra24 <= addra24 + 1;
                metadata_available[24] <= 1;
            end
            else
                metadata_available[24] <= 0;
            
            if(metadata_request[26] == 1 && running && metadata_available[26] == 0) begin
                metadata_link[27*16-1:26*16] <= douta26;
                if(addra26 < 15)
                    addra26 <= addra26 + 1;
                metadata_available[26] <= 1;
            end
            else
                metadata_available[26] <= 0;
    
            if(metadata_request[28] == 1 && running && metadata_available[28] == 0) begin
                metadata_link[29*16-1:28*16] <= douta28;
                if(addra28 < 15)
                    addra28 <= addra28 + 1;
                metadata_available[28] <= 1;
            end
            else
                metadata_available[28] <= 0;
    
            if(metadata_request[31] == 1 && running && metadata_available[31] == 0) begin
                metadata_link[32*16-1:31*16] <= douta31;
                if(addra31 < 15)
                    addra31 <= addra31 + 1;
                metadata_available[31] <= 1;
            end
            else
                metadata_available[31] <= 0;
        end

    end


        /*
    ila_metadata_controller dear_lord_save_me (
        .clk(clk),
        .probe0(addra24),
        .probe1(douta24),
        .probe2(addra26),
        .probe3(douta26),
        .probe4(addra28),
        .probe5(douta28),
        .probe6(addra31),
        .probe7(douta31),

        .probe8(metadata_link),
        .probe9(metadata_available),
        .probe10(metadata_request),
        .probe11(running),
        .probe12(song_time)
    );
    */


    /*
    reg we;
    reg [31:0] din;
    wire [31:0] dout;
    //2^12 = 4096 words 
    mybram #(.LOGSIZE(12),.WIDTH(32)) //WORD:= 3 system bits (0b000 for note, 0b111 for end of data), 6'b for pitch, 3'b for string, 4'b for fret, 16'b for time
    memory(.addr(pointer),.clk(clk25),.we(we),.din(din),.dout(dout));

    always @(posedge clk25) begin
        if(!loaded && write_en) begin //write a word
            we <= 1;
            din <= write_word;
            if(write_word[31:29] == 3'b111) begin //data all loaded.
                loaded <= 1;
                new_pointer <= 0; //reset pointer to 0
            end
            else
                new_pointer <= pointer + 32; //increment pointer by a word, after the next clk cycle
        end
        else begin
            we <= 0;
        end
        pointer <= new_pointer;
        
        if(metadata_request != 0) begin
        end
        
    end
    */

endmodule