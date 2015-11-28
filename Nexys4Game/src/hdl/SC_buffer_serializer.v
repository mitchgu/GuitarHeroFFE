module SC_buffer_serializer(
    input clk,
    input song_time,
    input [36:0] match_trigger,
    input [37*16-1:0] match_time,
    
    output reg match_en,
    output reg [15:0] match_dt
    
    );
    
    reg [17*6-1:0] match_queue; //represents a shift register with 6 shifts of 17 bits each, where the MSB means a valid match needs to be scored, and the next 16 bits are the dt
    
    initial match_queue = 0;
                
    always @(posedge clk) begin
        if(match_trigger != 0) begin //there's at least 1 match
            //FIXME
            integer i = 0;
            for(i = 0; i < 37; i = i + 1) begin
                if(match_trigger[i] == 1'b1) begin //match on ith note
                    match_queue[17*6-1:17*5] <= {1'b1,match_time[i*16+15:i*16]}; //WILL FAIL IF TWO MATCHES IN SAME CLOCK CYCLE (will only take the highest match)
                end
            end
        end
        else
            match_queue[17*6-1:17*5] = 0; //insert 0's into queue
        
        match_queue[17*5-1:0] <= match_queue[17*6-1:17]; //Shift the queue
        
        match_en <= match_queue[16]; //shift out a match
        match_dt <= song_time - match_queue[15:0]; //SIGNED ISSUES : NEED FIXING
        
    end
    
    
    
    
    
endmodule