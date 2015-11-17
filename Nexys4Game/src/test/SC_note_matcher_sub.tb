`timescale 1ns / 1ps

module SC_note_matching_sub_tb;

    // Inputs
    reg clk;
    reg [17:0] song_time;
    reg note_edge;
    reg [17:0] note_time;
    
    // Outputs
    wire note_request;
    wire match_enable;
    wire [17:0] match_time;
    
    // Instantiate the Unit Under Test (UUT)
    SC_note_matching_sub uut (
        .clk(clk),
        .song_time(song_time),
        .note_edge(note_edge),
        .note_time(note_time),
        .note_request(note_request),
        .match_enable(match_enable),
        .match_time(match_time)
    );
    
    always #5 clk = !clk;
    always #10 song_time = song_time + 1;
    initial begin
        // Initialize Inputs
        clk = 0;
        song_time = 0;
        note_edge = 0;
        note_time = 0;
        // Wait 100 ns for global reset to finish
        #100;
        
        //Stimulus
        if(note_request) begin
            note_time <= 50;
        end
        
        #600
        note_edge = 1;
        #9
        note_edge = 0;
        
        
    end
endmodule