module SC_note_matching_sub(
    input clk,
    input pause,
    input reset,
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
        if(reset) begin
            past_note <= 0;
            future_note <= 0;
            note_request <= 0;
            match_enable <= 0;
            match_time <= 0;
        end
        else begin
            if(future_note < song_time && ~note_request) begin //if future note not in the future
                past_note <= future_note; //shift in the new past_note
                future_note <= 0; //invalid
            end
            
            if(future_note == 0 && note_request == 0) begin //get a new note
                note_request <= 1;
            end
    
            if(note_request && note_available) begin
                note_request <= 0; //stop requesting
                future_note <= note_time; //shift in new future note
            end
            
            if(song_time > NOTE_TIMEOUT + past_note) begin //if nearest note is timed-out
                past_note <= 0; //write invalid
            end
            
            if(note_edge && ~pause) begin
                if( (song_time - past_note < future_note - song_time) && past_note != 0) 
                begin //match to past note
                    match_enable <= 1'b1;
                    match_time <= past_note;
                    past_note <= 0;
                end
                else if(future_note != 0 && (future_note - song_time < NOTE_TIMEOUT) ) begin //match to future note
                    match_enable <= 1'b1;
                    match_time <= future_note;
                    future_note <= 0;
                end
            end
            else if(match_enable) begin //reset match_enable
                match_enable <= 0;
            end
        end
    end 
    
    
endmodule