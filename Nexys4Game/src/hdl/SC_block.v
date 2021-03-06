module SC_block(
    input clk, //100mhz clock
    input pause, //pause game status
    input reset,
    input [15:0] song_time, //current song time
    input [36:0] NDATA, //deserialized note data
    input [37*16-1:0] metadata_link, //input from the metadata table
    input [36:0] metadata_available,
    
    output [36:0] metadata_request, //request line to metadata table
    output [31:0] score, //score output to the AV block ARBITRARY WIDTH
    output [29:0] fret, //fret numbers for matched notes for string gr.
    output [15:0] fret_time,
    output [5:0] fret_en //enable signal for a string gr. module to check for a matched note    
    
    );
    
    wire [36:0] match_trigger;
    wire [37*16-1:0] match_time;
    wire match_en;
    wire [15:0] match_dt;
    
    SC_note_matching_super note_matcher (
        .clk(clk),
        .pause(pause),
        .reset(reset),
        .song_time(song_time),
        .NDATA(NDATA),
        .metadata_link(metadata_link),
        .metadata_request(metadata_request),
        .metadata_available(metadata_available),
        .match_trigger(match_trigger),
        .match_time(match_time)
    );
        
    SC_buffer_serializer buffer_serializer (
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
    
    SC_score score_mod (
        .clk(clk),
        .reset(reset),
        .en(match_en),
        .dt(match_dt),
        
        .score(score)
    );
    
endmodule