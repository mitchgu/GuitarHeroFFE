module SC_block(
    input clk, //100mhz clock
    input pause, //pause game status
    input [15:0] song_time, //current song time
    input [36:0] NDATA, //deserialized note data
    input [37*16-1:0] metadata_link, //input from the metadata table
    
    output [36:0] metadata_request, //request line to metadata table
    output [31:0] score, //score output to the AV block ARBITRARY WIDTH
    output fret,
    output note_time,
    output en //FIXME
    
    
    );
    
    wire [36:0] match_trigger;
    wire [37*16-1:0] match_time;
    wire match_en;
    wire [15:0] match_dt;
    
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
        .match_time(match_time),
        
        .match_en(match_en),
        .match_dt(match_dt)
    );
    
    SC_score score (
        .clk(clk),
        .en(match_en),
        .dt(match_dt),
        
        .score(score)
    );
    
    
    
endmodule