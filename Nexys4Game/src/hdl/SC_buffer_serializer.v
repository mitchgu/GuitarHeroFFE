module SC_buffer_serializer(
    input clk,
    input [15:0] song_time,
    input [36:0] match_trigger,
    input [37*16-1:0] match_time,
    
    output reg match_en,
    output reg [15:0] match_dt
    );
    
    reg [17*6-1:0] match_queue; //represents a shift register with 6 shifts of 17 bits each, where the MSB means a valid match needs to be scored, and the next 16 bits are the dt
    
    initial match_queue = 0;
    
    assign queue = match_queue[15:0];
                
    always @(posedge clk) begin
    
        begin //stupid script-generated matcher
           if(match_trigger[36] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[36*16+15:36*16]};
           else if(match_trigger[35] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[35*16+15:35*16]};
           else if(match_trigger[34] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[34*16+15:34*16]};
           else if(match_trigger[33] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[33*16+15:33*16]};
           else if(match_trigger[32] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[32*16+15:32*16]};
           else if(match_trigger[31] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[31*16+15:31*16]};
           else if(match_trigger[30] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[30*16+15:30*16]};
           else if(match_trigger[29] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[29*16+15:29*16]};
           else if(match_trigger[28] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[28*16+15:28*16]};
           else if(match_trigger[27] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[27*16+15:27*16]};
           else if(match_trigger[26] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[26*16+15:26*16]};
           else if(match_trigger[25] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[25*16+15:25*16]};
           else if(match_trigger[24] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[24*16+15:24*16]};
           else if(match_trigger[23] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[23*16+15:23*16]};
           else if(match_trigger[22] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[22*16+15:22*16]};
           else if(match_trigger[21] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[21*16+15:21*16]};
           else if(match_trigger[20] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[20*16+15:20*16]};
           else if(match_trigger[19] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[19*16+15:19*16]};
           else if(match_trigger[18] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[18*16+15:18*16]};
           else if(match_trigger[17] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[17*16+15:17*16]};
           else if(match_trigger[16] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[16*16+15:16*16]};
           else if(match_trigger[15] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[15*16+15:15*16]};
           else if(match_trigger[14] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[14*16+15:14*16]};
           else if(match_trigger[13] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[13*16+15:13*16]};
           else if(match_trigger[12] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[12*16+15:12*16]};
           else if(match_trigger[11] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[11*16+15:11*16]};
           else if(match_trigger[10] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[10*16+15:10*16]};
           else if(match_trigger[9] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[9*16+15:9*16]};
           else if(match_trigger[8] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[8*16+15:8*16]};
           else if(match_trigger[7] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[7*16+15:7*16]};
           else if(match_trigger[6] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[6*16+15:6*16]};
           else if(match_trigger[5] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[5*16+15:5*16]};
           else if(match_trigger[4] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[4*16+15:4*16]};
           else if(match_trigger[3] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[3*16+15:3*16]};
           else if(match_trigger[2] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[2*16+15:2*16]};
           else if(match_trigger[1] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[1*16+15:1*16]};
           else if(match_trigger[0] == 1'b1)
               match_queue[17*6-1:17*5] <= {1'b1,match_time[0*16+15:0*16]};
           else //No Match
               match_queue[17*6-1:17*5] <= 0; //insert 0's into queue
        end
        
        match_queue[17*5-1:0] <= match_queue[17*6-1:17]; //Shift the queue
        
        match_en <= match_queue[16]; //shift out a match
        if(song_time >= match_queue[15:0])
            match_dt <= song_time - match_queue[15:0];
        else
            match_dt <= match_queue[15:0] - song_time;
            
    end
endmodule