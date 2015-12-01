module CL_fsm(
    input clk,
    input pause_SW, //debounced pause switch
    input data_loaded,
    input song_loaded,
    input reset_trigger, //debounced reset button
    output reg pause, //pause game state
    output reg reset //reset game signal
    );
    
    always @(posedge clk) begin
        pause <= pause_SW || !(data_loaded && song_loaded);
        reset <= reset_trigger && pause_SW; //resets only in paused
    end
    
endmodule