module AV_integrator(
    input clk65,
    input pause,
    input [12:0] menu_pixel,
    input [12:0] score_pixel,
    input [12:0] string1_pixel, //MSB is whether or not to use the pixel
    input [12:0] string2_pixel,
    input [12:0] string3_pixel,
    input [12:0] string4_pixel,
    input [12:0] string5_pixel,
    input [12:0] string6_pixel,
    
    input [11:0] bg_pixel,
    
    output [11:0] pixel_out
    
    );
    wire [11:0] pixel;
    assign pixel = menu_pixel[12] ? menu_pixel[11:0] :
                    score_pixel[12] ? score_pixel[11:0] :
                    string1_pixel[12] ? string1_pixel[11:0] :
                    string2_pixel[12] ? string2_pixel[11:0] :
                    string3_pixel[12] ? string3_pixel[11:0] :
                    string4_pixel[12] ? string4_pixel[11:0] :
                    string5_pixel[12] ? string5_pixel[11:0] :
                    string6_pixel[12] ? string6_pixel[11:0] :
                    bg_pixel[11:0];
    assign pixel_out = pause ? ~pixel : pixel;
    
    /*
    
    always @(posedge clk65) begin //maybe make this assign and wires instead?
    
        if( menu_pixel[12] == 1'b1 ) begin
                pixel <= menu_pixel[11:0];
        end
        else if( score_pixel[12] == 1'b1 ) begin
            pixel <= score_pixel[11:0];
        end
        else if( string1_pixel[12] == 1'b1 ) begin
            pixel <= string1_pixel[11:0];
        end
        else if( string2_pixel[12] == 1'b1 ) begin
            pixel <= string2_pixel[11:0];
        end
        else if( string3_pixel[12] == 1'b1 ) begin
            pixel <= string3_pixel[11:0];
        end
        else if( string4_pixel[12] == 1'b1 ) begin
            pixel <= string4_pixel[11:0];
        end
        else if( string5_pixel[12] == 1'b1 ) begin
            pixel <= string5_pixel[11:0];
        end
        else if( string6_pixel[12] == 1'b1 ) begin
            pixel <= string6_pixel[11:0];
        end
        else pixel <= bg_pixel[11:0];
    
    end
    */


endmodule