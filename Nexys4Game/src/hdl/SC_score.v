module SC_score(
    input clk, //100mhz clk
    input reset,
    input en, //match enable
    input [15:0] dt, //margin of correctness for a matched note
    
    output reg [31:0] score //total score ARBITRARY 32 bit width
    );
    
    initial score = 0;
    
    always @(posedge clk) begin
        if(reset)
            score <= 0;
        else if(en) begin //matched note
            if(dt < 10) //within 100ms
                score <= score + 100;
            else if(dt < 25) //within 250ms
                score <= score + 50;
            else if(dt < 50) //within 500ms
                score <= score + 25;
            else if(dt < 100) //within 1s
                score <= score + 10;
        end    
    end
    
endmodule