module SC_note_matching_sub(
    input clk,
    input [15:0] song_time, //current song time
    input note_edge, //if note has become active (must be a single-cycle pulse)
    input [15:0] note_time, //time of next note, or all 1's if no note in buffer
    input note_available, //high when note requested is available
    output reg note_request, //a pulse if a new note is needed to be shifted in    
    output reg match_enable, //a pulse signaling a new note-match
    output reg [15:0] match_time //time which the note has been matched to.
    );
    
    reg [15:0] past_note, future_note; //time of closest nearby note
    localparam NOTE_TIMEOUT = 100; //time it takes for a note to no longer be considered, in 10ms (100 = 1s) 
    
    initial past_note <= 0;
    initial future_note <= 0;
    initial match_enable <= 0;
    initial match_time <= 0;
    
    always @(posedge clk) begin
        
        if(future_note < song_time && ~note_request) begin //if future note not in the future
            past_note <= future_note; //shift in the new past_note
            future_note <= 0; //invalid, will fail to match with extremely high probability due to overflow
            note_request <= 1; //request new note
        end
        
        if(note_request && note_available) begin
            note_request <= 0; //stop requesting
            future_note <= note_time; //shift in new future note
        end
        
        if(song_time > NOTE_TIMEOUT + past_note) begin //if nearest note is timed-out
            past_note <= 0; //write invalid
        end
        
        if(note_edge) begin
            if( song_time - past_note < future_note - song_time) begin //match to past note. Note that if past_note is written invalid, this test will fail with extremely high probability
                match_enable <= 1'b1;
                match_time <= past_note;
                past_note <= 0;
            end
            else begin //match to future note
                match_enable <= 1'b1;
                match_time <= future_note;
            end
        end
        else if(match_enable) begin //reset match_enable
            match_enable <= 0;
        end
        
    end 
    
    
endmodule