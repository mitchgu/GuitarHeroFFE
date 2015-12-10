`timescale 1ns / 1ps

module SC_note_matching_super_tb;

    // Inputs
    reg clk;
    reg [15:0] song_time;
    reg [36:0] NDATA;
    reg [37*16-1:0] metadata_link;
    
    // Outputs
    wire [36:0] metadata_request;
    wire [36:0] match_trigger;
    wire [37*16-1:0] match_time;
    
    // Instantiate the Unit Under Test (UUT)
    SC_note_matching_super uut (
        .clk(clk),
        .song_time(song_time),
        .NDATA(NDATA),
        .metadata_link(metadata_link),
        .metadata_request(metadata_request),
        .match_trigger(match_trigger),
        .match_time(match_time)
    );
    
    always #5 clk = !clk;
    always #20 song_time = song_time + 1;
    initial begin
        // Initialize Inputs
        clk = 0;
        song_time = 0;
        NDATA = 0;
        metadata_link = 0;
        // Wait 100 ns for global reset to finish
        #100;
        
        //Stimulus
        metadata_link[15:0] = 15; //set e2 to be played at st:15
        metadata_link[31:16] = 10; //set f2 to be played at st:10
        metadata_link[63:48] = 20; //set g2 to be played at st:20
        metadata_link[79:64] = 20; //set g#2 to be played at st:20
        
        
        #80
        NDATA = 1; //play e2 at st:9
        #40
        NDATA = 0; //stop playing e2 at st:11
        #600
        NDATA = 8; //play g2 at st:41
        #40
        NDATA = 0; //stop playing g2 at st:43
        #3000
        NDATA = 16; //play g#2 at st:
        #40
        NDATA = 0; //stop playing g#2 at st:
        
        
    end
endmodule