module AV_menu_graphics(
    input clk65,
    input pause,
    input [10:0] hcount,
    input [9:0] vcount,
        
    output reg [12:0] menu_pixel
    );
    
    localparam WIDTH = 800;
    localparam HEIGHT = 600;
    localparam COLOR = 12'hD_D_D;
    localparam startX = 100;
    localparam startY = 50;
    
    
    always @(posedge clk65) begin
        if( hcount >= startX && hcount < (startX + WIDTH) &&
            vcount >= startY && vcount < (startY + HEIGHT))
            menu_pixel <= {pause, COLOR};
        else menu_pixel <= 0;
    
    end
    
endmodule