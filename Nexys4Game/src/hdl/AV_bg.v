module AV_bg(
    input clk65,
    input [10:0] hcount,
    input [9:0] vcount,
    
    output reg [11:0] bg_pixel
    
    );
    
    
    
    initial bg_pixel <= 12'h8_0_0;
    
    
    
    
    
    
endmodule