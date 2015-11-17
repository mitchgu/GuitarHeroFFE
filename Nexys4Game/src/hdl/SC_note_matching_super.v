module SC_note_matching_super(
    input clk,
    input [36:0] NDATA,
    
    
    output reg [36:0] match_time[17:0]
    );
    
    reg [36:0] note_prev; //array of previous note-states
    wire [36:0] note_edge; //note edge transitions detected
    
    
    
endmodule