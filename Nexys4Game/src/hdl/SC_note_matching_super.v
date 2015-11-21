module SC_note_matching_super(
    input clk,
    input [15:0] song_time,
    input [36:0] NDATA,
    input [37*16-1:0] metadata_link,
    
    output [36:0] metadata_request,
    output [36:0] match_trigger,
    output [37*16-1:0] match_time
    );
    
    reg [36:0] note_prev; //array of previous note-states
    wire [36:0] note_edge; //note edge transitions detected
    
    //create 37 note sub_modules
    //genvar i;
    //generate
    //    for (i = 0; i < 37; i = i + 1) begin : gen_loop
    //        SC_note_matching_sub note_matcher(.clk(clk), .song_time(song_time),
    //                                            .note_edge(note_edge[i]), .note_time(metadata_link[18*i+17:18*i]),
    //                                            .note_request(metadata_request[i]), .match_enable(match_trigger[i]),
    //                                            .match_time(match_time[18*i+17:18*i]));
    //    end
    //endgenerate
    
    //create 37 note_matcher_submodules
    SC_note_matching_sub note_matcher [36:0] (.clk(clk), .song_time(song_time),
                                                    .note_edge(note_edge), .note_time(metadata_link),
                                                    .note_request(metadata_request), .match_enable(match_trigger),
                                                    .match_time(match_time));
            
    assign note_edge = (NDATA&~note_prev); //detects 0 -> transition on NDATA            
    
    always @(posedge clk) begin
        note_prev <= NDATA; //update previous note-state
    end
        
endmodule