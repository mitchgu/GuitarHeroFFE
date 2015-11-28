module SC_block(
    input clk, //100mhz clock
    input pause, //pause game status
    input [15:0] song_time, //current song time
    input [36:0] NDATA, //deserialized note data
    input [37*16-1:0] metadata_link, //input from the metadata table
    
    output [36:0] metadata_request, //request line to metadata table
    output score, //score output to the AV block DETERMINE WIDTH
    output fret,
    output note_time,
    output en
    
    
    );
    
    wire [36:0] match_trigger;
    wire [37*16-1:0] match_time;
    
    SC_note_matching_super note_matcher (
        .clk(clk),
        .song_time(song_time),
        .NDATA(NDATA),
        .metadata_link(metadata_link),
        .metadata_request(metadata_request),
        .match_trigger(match_trigger),
        .match_time(match_time)
    );
        
    SC_buffer_serializer buffer_serializer (
        .clk(clk),
        .song_time(song_time),
        .match_trigger(match_trigger),
        .match_time(match_time)
        
        
    );
    
    SC_score score (
        .clk(clk),
        .dt(dt),
        
        .score(score)
    );
    
    
    
endmodule