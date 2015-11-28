module CL_block(
    input clk, //100mhz clk
    input pause_SW, //Debounced switch input for pause
    input reset_button, //Debounced button for reset
    
    output reset, //status signal for reset
    output pause, //status signal for game-pause
    output song_time //current song_time
    );
    
    CL_fsm fsm (
        .clk(clk),
        .pause_SW(pause_SW),
        .reset_trigger(reset_button),
        .pause(pause),
        .reset(reset)
    );
    
    CL_song_timer timer (
        .clk(clk),
        .pause(pause),
        .reset(reset),
        .song_time(song_time)
    );
    
    
endmodule