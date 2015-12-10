module CL_song_timer(
    input clk, //100mhz clock
    input pause, //high if game is paused
    input reset, //high to clear song_time
    output reg [15:0] song_time //10ms clock with pause
    );
    
    reg [19:0] counter; //counts to 1_000_000
    
    initial counter = 0;
    initial song_time = 0;
    
    always @(posedge clk) begin
    
        if(reset) begin
            song_time <= 0;
        end
        else if(~pause) begin //running
            if(counter == 999999) begin
                counter <= 0;
                song_time <= song_time + 1;
            end
            else counter <= counter + 1;
        end
        //if paused do nothing
    end
    
endmodule