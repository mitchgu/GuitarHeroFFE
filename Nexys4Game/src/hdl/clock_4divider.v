module clock_4divider(
    input clk,
    output reg clk_div
    );
    reg counter;
    initial counter = 0;
    initial clk_div = 0;
    
    
    always @(posedge clk) begin
        if(counter) begin
            counter <= 0;
            clk_div <= ~clk_div;
        end
        else
            counter <= 1;
    end
    
    
endmodule