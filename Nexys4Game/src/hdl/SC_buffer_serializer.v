module SC_buffer_serializer(
    input clk,
    input [15:0] song_time,
    input [36:0] match_trigger,
    input [37*16-1:0] match_time,
    
    output reg match_en,
    output reg [15:0] match_dt,
    output reg [5:0] fret_en,
    output reg [29:0] fret,
    output reg [15:0] fret_time
    );
    
    
    initial match_dt = 0;
                
    always @(posedge clk) begin
    
        //stupid script-generated matcher
        if(match_trigger[36] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 12; //highest string
            fret[24:20] <= 17;
            fret[19:15] <= 15;
            fret[14:10] <= 15;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b110_000; //which fret values are valid
            fret_time <= match_time[591:576];
            if(song_time >= match_time[591:576])
                match_dt <= song_time - match_time[591:576];
            else
                match_dt <= match_time[591:576] - song_time;
        end
        else if(match_trigger[35] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 11; //highest string
            fret[24:20] <= 16;
            fret[19:15] <= 15;
            fret[14:10] <= 15;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b110_000; //which fret values are valid
            fret_time <= match_time[575:560];
            if(song_time >= match_time[575:560])
                match_dt <= song_time - match_time[575:560];
            else
                match_dt <= match_time[575:560] - song_time;
        end
        else if(match_trigger[34] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 10; //highest string
            fret[24:20] <= 15;
            fret[19:15] <= 15;
            fret[14:10] <= 15;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b110_000; //which fret values are valid
            fret_time <= match_time[559:544];
            if(song_time >= match_time[559:544])
                match_dt <= song_time - match_time[559:544];
            else
                match_dt <= match_time[559:544] - song_time;
        end
        else if(match_trigger[33] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 9; //highest string
            fret[24:20] <= 14;
            fret[19:15] <= 15;
            fret[14:10] <= 15;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b110_000; //which fret values are valid
            fret_time <= match_time[543:528];
            if(song_time >= match_time[543:528])
                match_dt <= song_time - match_time[543:528];
            else
                match_dt <= match_time[543:528] - song_time;
        end
        else if(match_trigger[32] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 8; //highest string
            fret[24:20] <= 13;
            fret[19:15] <= 15;
            fret[14:10] <= 15;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b110_000; //which fret values are valid
            fret_time <= match_time[527:512];
            if(song_time >= match_time[527:512])
                match_dt <= song_time - match_time[527:512];
            else
                match_dt <= match_time[527:512] - song_time;
        end
        else if(match_trigger[31] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 7; //highest string
            fret[24:20] <= 12;
            fret[19:15] <= 16;
            fret[14:10] <= 15;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b111_000; //which fret values are valid
            fret_time <= match_time[511:496];
            if(song_time >= match_time[511:496])
                match_dt <= song_time - match_time[511:496];
            else
                match_dt <= match_time[511:496] - song_time;
        end
        else if(match_trigger[30] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 6; //highest string
            fret[24:20] <= 11;
            fret[19:15] <= 15;
            fret[14:10] <= 15;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b111_000; //which fret values are valid
            fret_time <= match_time[495:480];
            if(song_time >= match_time[495:480])
                match_dt <= song_time - match_time[495:480];
            else
                match_dt <= match_time[495:480] - song_time;
        end
        else if(match_trigger[29] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 5; //highest string
            fret[24:20] <= 10;
            fret[19:15] <= 14;
            fret[14:10] <= 15;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b111_000; //which fret values are valid
            fret_time <= match_time[479:464];
            if(song_time >= match_time[479:464])
                match_dt <= song_time - match_time[479:464];
            else
                match_dt <= match_time[479:464] - song_time;
        end
        else if(match_trigger[28] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 4; //highest string
            fret[24:20] <= 9;
            fret[19:15] <= 13;
            fret[14:10] <= 15;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b111_000; //which fret values are valid
            fret_time <= match_time[463:448];
            if(song_time >= match_time[463:448])
                match_dt <= song_time - match_time[463:448];
            else
                match_dt <= match_time[463:448] - song_time;
        end
        else if(match_trigger[27] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 3; //highest string
            fret[24:20] <= 8;
            fret[19:15] <= 12;
            fret[14:10] <= 17;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b111_100; //which fret values are valid
            fret_time <= match_time[447:432];
            if(song_time >= match_time[447:432])
                match_dt <= song_time - match_time[447:432];
            else
                match_dt <= match_time[447:432] - song_time;
        end
        else if(match_trigger[26] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 2; //highest string
            fret[24:20] <= 7;
            fret[19:15] <= 11;
            fret[14:10] <= 16;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b111_100; //which fret values are valid
            fret_time <= match_time[431:416];
            if(song_time >= match_time[431:416])
                match_dt <= song_time - match_time[431:416];
            else
                match_dt <= match_time[431:416] - song_time;
        end
        else if(match_trigger[25] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 1; //highest string
            fret[24:20] <= 6;
            fret[19:15] <= 10;
            fret[14:10] <= 15;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b111_100; //which fret values are valid
            fret_time <= match_time[415:400];
            if(song_time >= match_time[415:400])
                match_dt <= song_time - match_time[415:400];
            else
                match_dt <= match_time[415:400] - song_time;
        end
        else if(match_trigger[24] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 5;
            fret[19:15] <= 9;
            fret[14:10] <= 14;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b111_100; //which fret values are valid
            fret_time <= match_time[399:384];
            if(song_time >= match_time[399:384])
                match_dt <= song_time - match_time[399:384];
            else
                match_dt <= match_time[399:384] - song_time;
        end
        else if(match_trigger[23] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 4;
            fret[19:15] <= 8;
            fret[14:10] <= 13;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b011_100; //which fret values are valid
            fret_time <= match_time[383:368];
            if(song_time >= match_time[383:368])
                match_dt <= song_time - match_time[383:368];
            else
                match_dt <= match_time[383:368] - song_time;
        end
        else if(match_trigger[22] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 3;
            fret[19:15] <= 7;
            fret[14:10] <= 12;
            fret[9:5] <= 17;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b011_110; //which fret values are valid
            fret_time <= match_time[367:352];
            if(song_time >= match_time[367:352])
                match_dt <= song_time - match_time[367:352];
            else
                match_dt <= match_time[367:352] - song_time;
        end
        else if(match_trigger[21] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 2;
            fret[19:15] <= 6;
            fret[14:10] <= 11;
            fret[9:5] <= 16;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b011_110; //which fret values are valid
            fret_time <= match_time[351:336];
            if(song_time >= match_time[351:336])
                match_dt <= song_time - match_time[351:336];
            else
                match_dt <= match_time[351:336] - song_time;
        end
        else if(match_trigger[20] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 1;
            fret[19:15] <= 5;
            fret[14:10] <= 10;
            fret[9:5] <= 15;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b011_110; //which fret values are valid
            fret_time <= match_time[335:320];
            if(song_time >= match_time[335:320])
                match_dt <= song_time - match_time[335:320];
            else
                match_dt <= match_time[335:320] - song_time;
        end
        else if(match_trigger[19] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 4;
            fret[14:10] <= 9;
            fret[9:5] <= 14;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b011_110; //which fret values are valid
            fret_time <= match_time[319:304];
            if(song_time >= match_time[319:304])
                match_dt <= song_time - match_time[319:304];
            else
                match_dt <= match_time[319:304] - song_time;
        end
        else if(match_trigger[18] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 3;
            fret[14:10] <= 8;
            fret[9:5] <= 13;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b001_110; //which fret values are valid
            fret_time <= match_time[303:288];
            if(song_time >= match_time[303:288])
                match_dt <= song_time - match_time[303:288];
            else
                match_dt <= match_time[303:288] - song_time;
        end
        else if(match_trigger[17] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 2;
            fret[14:10] <= 7;
            fret[9:5] <= 12;
            fret[4:0] <= 17; //lowest string
            fret_en = 6'b001_111; //which fret values are valid
            fret_time <= match_time[287:272];
            if(song_time >= match_time[287:272])
                match_dt <= song_time - match_time[287:272];
            else
                match_dt <= match_time[287:272] - song_time;
        end
        else if(match_trigger[16] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 1;
            fret[14:10] <= 6;
            fret[9:5] <= 11;
            fret[4:0] <= 16; //lowest string
            fret_en = 6'b001_111; //which fret values are valid
            fret_time <= match_time[271:256];
            if(song_time >= match_time[271:256])
                match_dt <= song_time - match_time[271:256];
            else
                match_dt <= match_time[271:256] - song_time;
        end
        else if(match_trigger[15] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 5;
            fret[9:5] <= 10;
            fret[4:0] <= 15; //lowest string
            fret_en = 6'b001_111; //which fret values are valid
            fret_time <= match_time[255:240];
            if(song_time >= match_time[255:240])
                match_dt <= song_time - match_time[255:240];
            else
                match_dt <= match_time[255:240] - song_time;
        end
        else if(match_trigger[14] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 4;
            fret[9:5] <= 9;
            fret[4:0] <= 14; //lowest string
            fret_en = 6'b000_111; //which fret values are valid
            fret_time <= match_time[239:224];
            if(song_time >= match_time[239:224])
                match_dt <= song_time - match_time[239:224];
            else
                match_dt <= match_time[239:224] - song_time;
        end
        else if(match_trigger[13] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 3;
            fret[9:5] <= 8;
            fret[4:0] <= 13; //lowest string
            fret_en = 6'b000_111; //which fret values are valid
            fret_time <= match_time[223:208];
            if(song_time >= match_time[223:208])
                match_dt <= song_time - match_time[223:208];
            else
                match_dt <= match_time[223:208] - song_time;
        end
        else if(match_trigger[12] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 2;
            fret[9:5] <= 7;
            fret[4:0] <= 12; //lowest string
            fret_en = 6'b000_111; //which fret values are valid
            fret_time <= match_time[207:192];
            if(song_time >= match_time[207:192])
                match_dt <= song_time - match_time[207:192];
            else
                match_dt <= match_time[207:192] - song_time;
        end
        else if(match_trigger[11] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 1;
            fret[9:5] <= 6;
            fret[4:0] <= 11; //lowest string
            fret_en = 6'b000_111; //which fret values are valid
            fret_time <= match_time[191:176];
            if(song_time >= match_time[191:176])
                match_dt <= song_time - match_time[191:176];
            else
                match_dt <= match_time[191:176] - song_time;
        end
        else if(match_trigger[10] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 0;
            fret[9:5] <= 5;
            fret[4:0] <= 10; //lowest string
            fret_en = 6'b000_111; //which fret values are valid
            fret_time <= match_time[175:160];
            if(song_time >= match_time[175:160])
                match_dt <= song_time - match_time[175:160];
            else
                match_dt <= match_time[175:160] - song_time;
        end
        else if(match_trigger[9] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 0;
            fret[9:5] <= 4;
            fret[4:0] <= 9; //lowest string
            fret_en = 6'b000_011; //which fret values are valid
            fret_time <= match_time[159:144];
            if(song_time >= match_time[159:144])
                match_dt <= song_time - match_time[159:144];
            else
                match_dt <= match_time[159:144] - song_time;
        end
        else if(match_trigger[8] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 0;
            fret[9:5] <= 3;
            fret[4:0] <= 8; //lowest string
            fret_en = 6'b000_011; //which fret values are valid
            fret_time <= match_time[143:128];
            if(song_time >= match_time[143:128])
                match_dt <= song_time - match_time[143:128];
            else
                match_dt <= match_time[143:128] - song_time;
        end
        else if(match_trigger[7] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 0;
            fret[9:5] <= 2;
            fret[4:0] <= 7; //lowest string
            fret_en = 6'b000_011; //which fret values are valid
            fret_time <= match_time[127:112];
            if(song_time >= match_time[127:112])
                match_dt <= song_time - match_time[127:112];
            else
                match_dt <= match_time[127:112] - song_time;
        end
        else if(match_trigger[6] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 0;
            fret[9:5] <= 1;
            fret[4:0] <= 6; //lowest string
            fret_en = 6'b000_011; //which fret values are valid
            fret_time <= match_time[111:96];
            if(song_time >= match_time[111:96])
                match_dt <= song_time - match_time[111:96];
            else
                match_dt <= match_time[111:96] - song_time;
        end
        else if(match_trigger[5] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 0;
            fret[9:5] <= 0;
            fret[4:0] <= 5; //lowest string
            fret_en = 6'b000_011; //which fret values are valid
            fret_time <= match_time[95:80];
            if(song_time >= match_time[95:80])
                match_dt <= song_time - match_time[95:80];
            else
                match_dt <= match_time[95:80] - song_time;
        end
        else if(match_trigger[4] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 0;
            fret[9:5] <= 0;
            fret[4:0] <= 4; //lowest string
            fret_en = 6'b000_001; //which fret values are valid
            fret_time <= match_time[79:64];
            if(song_time >= match_time[79:64])
                match_dt <= song_time - match_time[79:64];
            else
                match_dt <= match_time[79:64] - song_time;
        end
        else if(match_trigger[3] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 0;
            fret[9:5] <= 0;
            fret[4:0] <= 3; //lowest string
            fret_en = 6'b000_001; //which fret values are valid
            fret_time <= match_time[63:48];
            if(song_time >= match_time[63:48])
                match_dt <= song_time - match_time[63:48];
            else
                match_dt <= match_time[63:48] - song_time;
        end
        else if(match_trigger[2] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 0;
            fret[9:5] <= 0;
            fret[4:0] <= 2; //lowest string
            fret_en = 6'b000_001; //which fret values are valid
            fret_time <= match_time[47:32];
            if(song_time >= match_time[47:32])
                match_dt <= song_time - match_time[47:32];
            else
                match_dt <= match_time[47:32] - song_time;
        end
        else if(match_trigger[1] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 0;
            fret[9:5] <= 0;
            fret[4:0] <= 1; //lowest string
            fret_en = 6'b000_001; //which fret values are valid
            fret_time <= match_time[31:16];
            if(song_time >= match_time[31:16])
                match_dt <= song_time - match_time[31:16];
            else
                match_dt <= match_time[31:16] - song_time;
        end
        else if(match_trigger[0] == 1'b1) begin
            match_en <= 1'b1;
            fret[29:25] <= 0; //highest string
            fret[24:20] <= 0;
            fret[19:15] <= 0;
            fret[14:10] <= 0;
            fret[9:5] <= 0;
            fret[4:0] <= 0; //lowest string
            fret_en = 6'b000_001; //which fret values are valid
            fret_time <= match_time[15:0];
            if(song_time >= match_time[15:0])
                match_dt <= song_time - match_time[15:0];
            else
                match_dt <= match_time[15:0] - song_time;
        end
        else begin //No Match
            match_en <= 0;
            fret_en <= 0;
        end
        
    end
endmodule