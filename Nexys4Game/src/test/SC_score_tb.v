`timescale 1ns / 1ps

module SC_score_tb;

    // Inputs
    reg clk;
    reg [15:0] dt;
    reg en;
    
    // Outputs
    wire [31:0] score;
    
    // Instantiate the Unit Under Test (UUT)
    SC_score uut (
        .clk(clk),
        .dt(dt),
        .en(en),
        .score(score)
    );
    
    always #5 clk = !clk;
    initial begin
        // Initialize Inputs
        clk = 0;
        dt = 0;
        en = 0;
        // Wait 100 ns for global reset to finish
        #100;
        
        //Stimulus
        
        dt <= 5;
        en <= 1;
        #10
        en <= 0;
        
        #100
        dt <= 20;
        
        #100
        dt <= 75;
        en <= 1;
        #10
        en <= 0;
        
        #100
        dt <= 110;
        en <= 1;
        #10
        en <= 0;
        
    end
endmodule