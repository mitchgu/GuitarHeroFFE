module CL_metadata_controller(
    input clk, //100mhz clk
    input clk25, //25mhz clk
    input write_en, //signals a new word to be written
    input [31:0] write_word, //word to be written    
    
    output reg loaded
    
    );
    
    reg [11:0] pointer = 0;
    reg [11:0] new_pointer = 0; //1 clk delay on updating pointer
    
    initial loaded = 0;
    
    reg we;
    reg [31:0] din;
    wire [31:0] dout;
    //2^12 = 4096 words 
    mybram #(.LOGSIZE(12),.WIDTH(32)) //WORD:= 3 system bits (0b000 for note, 0b111 for end of data), 6'b for pitch, 3'b for string, 4'b for fret, 16'b for time
    memory(.addr(pointer),.clk(clk25),.we(we),.din(din),.dout(dout));

    always @(posedge clk25) begin
        if(!loaded && write_en) begin //write a word
            we <= 1;
            din <= write_word;
            if(write_word[31:29] == 3'b111) begin //data all loaded.
                loaded <= 1;
                new_pointer <= 0; //reset pointer to 0
            end
            else
                new_pointer <= pointer + 32; //increment pointer by a word, after the next clk cycle
        end
        else begin
            we <= 0;
        end
        pointer <= new_pointer;
    end
    
    
endmodule