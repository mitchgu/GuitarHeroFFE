`timescale 1ns / 1ps

module SC_buffer_serializer_tb;

    // Inputs
    reg clk;
    reg [15:0] song_time;
    reg [36:0] match_trigger;
    reg [37*16-1:0] match_time;
    
    // Outputs
    wire match_en;
    wire [15:0] match_dt;
    wire [29:0] fret;
    wire [5:0] fret_en;
    wire [15:0] fret_time;
    
    // Instantiate the Unit Under Test (UUT)
    SC_buffer_serializer uut (
        .clk(clk),
        .song_time(song_time),
        .match_trigger(match_trigger),
        .match_time(match_time),
        .match_en(match_en),
        .match_dt(match_dt),
        .fret_en(fret_en),
        .fret(fret),
        .fret_time(fret_time)
    );
    
    always #5 clk = !clk;
    always #100 song_time = song_time + 1;
    initial begin
        // Initialize Inputs
        clk = 0;
        song_time = 0;
        match_trigger = 0;
        match_time = 0;
        // Wait 100 ns for global reset to finish
        #100;
        
        //Stimulus
        #995
        match_trigger = 1; //match e2
        match_time[15:0] = 7;
        #10
        match_trigger = 0;
        
        
        #995
        match_trigger[12] = 1; //match e2
        match_time[207:192] = 30;
        #10
        match_trigger = 0;
        
        
        
    end
endmodule