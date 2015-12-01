module SC_buffer_serializer(
    input clk,
    input [15:0] song_time,
    input [36:0] match_trigger,
    input [37*16-1:0] match_time,
    
    output reg match_en,
    output reg [15:0] match_dt
    );
    
    
    initial match_dt = 0;
                
    always @(posedge clk) begin
    
        //stupid script-generated matcher
        if(match_trigger[36] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[591:576])
                match_dt <= song_time - match_time[591:576];
            else
                match_dt <= match_time[591:576] - song_time;
        end
        else if(match_trigger[35] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[575:560])
                match_dt <= song_time - match_time[575:560];
            else
                match_dt <= match_time[575:560] - song_time;
        end
        else if(match_trigger[34] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[559:544])
                match_dt <= song_time - match_time[559:544];
            else
                match_dt <= match_time[559:544] - song_time;
        end
        else if(match_trigger[33] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[543:528])
                match_dt <= song_time - match_time[543:528];
            else
                match_dt <= match_time[543:528] - song_time;
        end
        else if(match_trigger[32] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[527:512])
                match_dt <= song_time - match_time[527:512];
            else
                match_dt <= match_time[527:512] - song_time;
        end
        else if(match_trigger[31] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[511:496])
                match_dt <= song_time - match_time[511:496];
            else
                match_dt <= match_time[511:496] - song_time;
        end
        else if(match_trigger[30] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[495:480])
                match_dt <= song_time - match_time[495:480];
            else
                match_dt <= match_time[495:480] - song_time;
        end
        else if(match_trigger[29] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[479:464])
                match_dt <= song_time - match_time[479:464];
            else
                match_dt <= match_time[479:464] - song_time;
        end
        else if(match_trigger[28] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[463:448])
                match_dt <= song_time - match_time[463:448];
            else
                match_dt <= match_time[463:448] - song_time;
        end
        else if(match_trigger[27] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[447:432])
                match_dt <= song_time - match_time[447:432];
            else
                match_dt <= match_time[447:432] - song_time;
        end
        else if(match_trigger[26] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[431:416])
                match_dt <= song_time - match_time[431:416];
            else
                match_dt <= match_time[431:416] - song_time;
        end
        else if(match_trigger[25] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[415:400])
                match_dt <= song_time - match_time[415:400];
            else
                match_dt <= match_time[415:400] - song_time;
        end
        else if(match_trigger[24] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[399:384])
                match_dt <= song_time - match_time[399:384];
            else
                match_dt <= match_time[399:384] - song_time;
        end
        else if(match_trigger[23] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[383:368])
                match_dt <= song_time - match_time[383:368];
            else
                match_dt <= match_time[383:368] - song_time;
        end
        else if(match_trigger[22] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[367:352])
                match_dt <= song_time - match_time[367:352];
            else
                match_dt <= match_time[367:352] - song_time;
        end
        else if(match_trigger[21] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[351:336])
                match_dt <= song_time - match_time[351:336];
            else
                match_dt <= match_time[351:336] - song_time;
        end
        else if(match_trigger[20] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[335:320])
                match_dt <= song_time - match_time[335:320];
            else
                match_dt <= match_time[335:320] - song_time;
        end
        else if(match_trigger[19] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[319:304])
                match_dt <= song_time - match_time[319:304];
            else
                match_dt <= match_time[319:304] - song_time;
        end
        else if(match_trigger[18] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[303:288])
                match_dt <= song_time - match_time[303:288];
            else
                match_dt <= match_time[303:288] - song_time;
        end
        else if(match_trigger[17] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[287:272])
                match_dt <= song_time - match_time[287:272];
            else
                match_dt <= match_time[287:272] - song_time;
        end
        else if(match_trigger[16] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[271:256])
                match_dt <= song_time - match_time[271:256];
            else
                match_dt <= match_time[271:256] - song_time;
        end
        else if(match_trigger[15] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[255:240])
                match_dt <= song_time - match_time[255:240];
            else
                match_dt <= match_time[255:240] - song_time;
        end
        else if(match_trigger[14] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[239:224])
                match_dt <= song_time - match_time[239:224];
            else
                match_dt <= match_time[239:224] - song_time;
        end
        else if(match_trigger[13] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[223:208])
                match_dt <= song_time - match_time[223:208];
            else
                match_dt <= match_time[223:208] - song_time;
        end
        else if(match_trigger[12] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[207:192])
                match_dt <= song_time - match_time[207:192];
            else
                match_dt <= match_time[207:192] - song_time;
        end
        else if(match_trigger[11] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[191:176])
                match_dt <= song_time - match_time[191:176];
            else
                match_dt <= match_time[191:176] - song_time;
        end
        else if(match_trigger[10] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[175:160])
                match_dt <= song_time - match_time[175:160];
            else
                match_dt <= match_time[175:160] - song_time;
        end
        else if(match_trigger[9] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[159:144])
                match_dt <= song_time - match_time[159:144];
            else
                match_dt <= match_time[159:144] - song_time;
        end
        else if(match_trigger[8] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[143:128])
                match_dt <= song_time - match_time[143:128];
            else
                match_dt <= match_time[143:128] - song_time;
        end
        else if(match_trigger[7] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[127:112])
                match_dt <= song_time - match_time[127:112];
            else
                match_dt <= match_time[127:112] - song_time;
        end
        else if(match_trigger[6] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[111:96])
                match_dt <= song_time - match_time[111:96];
            else
                match_dt <= match_time[111:96] - song_time;
        end
        else if(match_trigger[5] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[95:80])
                match_dt <= song_time - match_time[95:80];
            else
                match_dt <= match_time[95:80] - song_time;
        end
        else if(match_trigger[4] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[79:64])
                match_dt <= song_time - match_time[79:64];
            else
                match_dt <= match_time[79:64] - song_time;
        end
        else if(match_trigger[3] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[63:48])
                match_dt <= song_time - match_time[63:48];
            else
                match_dt <= match_time[63:48] - song_time;
        end
        else if(match_trigger[2] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[47:32])
                match_dt <= song_time - match_time[47:32];
            else
                match_dt <= match_time[47:32] - song_time;
        end
        else if(match_trigger[1] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[31:16])
                match_dt <= song_time - match_time[31:16];
            else
                match_dt <= match_time[31:16] - song_time;
        end
        else if(match_trigger[0] == 1'b1) begin
            match_en <= 1'b1;
            if(song_time >= match_time[15:0])
                match_dt <= song_time - match_time[15:0];
            else
                match_dt <= match_time[15:0] - song_time;
        end
        else begin //No Match
            match_en <= 0;
        end
        
    end
endmodule