`timescale 1ns / 1ps

module clock_4divider_tb;

    // Inputs
    reg clk;
    
    // Outputs
    wire clk_div;
    
    // Instantiate the Unit Under Test (UUT)
    clock_4divider uut (
        .clk(clk),
        .clk_div(clk_div)
    );
    
    always #5 clk = !clk;
    initial begin
        // Initialize Inputs
        clk = 0;
        // Wait 100 ns for global reset to finish
        #100;
        
    end
endmodule