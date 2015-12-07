`timescale 1ns / 1ps
// Switch Debounce Module
// use your system clock for the clock input
// to produce a synchronous, debounced output

module debounce #(parameter DELAY=1000000)   // .01 sec with a 100Mhz clock
            (input reset, clock, noisy,
             output reg clean);

    reg [19:0] count;
    reg new;

    always @(posedge clock)
        if (reset) begin
            count <= 0;
            new <= noisy;
            clean <= noisy;
        end
        else if (noisy != new) begin
            new <= noisy;
            count <= 0;
        end
        else if (count == DELAY)
            clean <= new;
        else
            count <= count+1;
      
endmodule

module level_to_pulse (input clk, input level, output pulse);

    reg last_level;
    always @(posedge clk) begin
        last_level <= level;
    end
    assign pulse = level & ~last_level;

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company:   g.p.hom
// Engineer: 
// 
// Create Date:    18:18:59 04/21/2013 
// Module Name:    display_8hex 

// Description:  Display 8 hex numbers on 7 segment display
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module display_8hex(
    input clk,                 // system clock
    input [31:0] data,         // 8 hex numbers, msb first
    output reg [6:0] seg,      // seven segment display output
    output reg [7:0] strobe    // digit strobe
    );

    localparam bits = 13;
     
    reg [bits:0] counter = 0;  // clear on power up
     
    wire [6:0] segments[15:0]; // 16 7 bit memorys
    assign segments[0]  = 7'b100_0000;
    assign segments[1]  = 7'b111_1001;
    assign segments[2]  = 7'b010_0100;
    assign segments[3]  = 7'b011_0000;
    assign segments[4]  = 7'b001_1001;
    assign segments[5]  = 7'b001_0010;
    assign segments[6]  = 7'b000_0010;
    assign segments[7]  = 7'b111_1000;
    assign segments[8]  = 7'b000_0000;
    assign segments[9]  = 7'b001_1000;
    assign segments[10] = 7'b000_1000;
    assign segments[11] = 7'b000_0011;
    assign segments[12] = 7'b010_0111;
    assign segments[13] = 7'b010_0001;
    assign segments[14] = 7'b000_0110;
    assign segments[15] = 7'b000_1110;
     
    always @(posedge clk) begin
      counter <= counter + 1;
      case (counter[bits:bits-2])
          3'b000: begin
                  seg <= segments[data[31:28]];
                  strobe <= 8'b0111_1111 ;
                 end

          3'b001: begin
                  seg <= segments[data[27:24]];
                  strobe <= 8'b1011_1111 ;
                 end

          3'b010: begin
                   seg <= segments[data[23:20]];
                   strobe <= 8'b1101_1111 ;
                  end
          3'b011: begin
                  seg <= segments[data[19:16]];
                  strobe <= 8'b1110_1111;        
                 end
          3'b100: begin
                  seg <= segments[data[15:12]];
                  strobe <= 8'b1111_0111;
                 end

          3'b101: begin
                  seg <= segments[data[11:8]];
                  strobe <= 8'b1111_1011;
                 end

          3'b110: begin
                   seg <= segments[data[7:4]];
                   strobe <= 8'b1111_1101;
                  end
          3'b111: begin
                  seg <= segments[data[3:0]];
                  strobe <= 8'b1111_1110;
                 end
       endcase
      end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// PWM 11 bits
//
//////////////////////////////////////////////////////////////////////////////////

module pwm11 ( 
    input clk,
    input [10:0] PWM_in, 
    output reg PWM_out,
    output PWM_sd
    );

    reg [10:0] new_pwm=0;
    reg [10:0] PWM_ramp=0; 
    always @(posedge clk) begin
        if (PWM_ramp==0) new_pwm <= PWM_in;
        PWM_ramp <= PWM_ramp + 1'b1;
        PWM_out <= (new_pwm>PWM_ramp);
    end

    assign PWM_sd = 1;

endmodule

// pulse synchronizer
module synchronize #(parameter NSYNC = 2)  // number of sync flops.  must be >= 2
                   (input clk,in,
                    output reg out);

  reg [NSYNC-2:0] sync;

  always @ (posedge clk)
  begin
    {out,sync} <= {sync[NSYNC-2:0],in};
  end
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// xvga: Generate XVGA display signals (1024 x 768 @ 60Hz)
//
////////////////////////////////////////////////////////////////////////////////

module xvga(input vclock,
            output reg [10:0] hcount,    // pixel number on current line
            output reg [9:0] vcount,     // line number
            output reg vsync,hsync,blank);

   // horizontal: 1344 pixels total
   // display 1024 pixels per line
   reg hblank,vblank;
   wire hsyncon,hsyncoff,hreset,hblankon;
   assign hblankon = (hcount == 1023);    
   assign hsyncon = (hcount == 1047);
   assign hsyncoff = (hcount == 1183);
   assign hreset = (hcount == 1343);

   // vertical: 806 lines total
   // display 768 lines
   wire vsyncon,vsyncoff,vreset,vblankon;
   assign vblankon = hreset & (vcount == 767);    
   assign vsyncon = hreset & (vcount == 776);
   assign vsyncoff = hreset & (vcount == 782);
   assign vreset = hreset & (vcount == 805);

   // sync and blanking
   wire next_hblank,next_vblank;
   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
   always @(posedge vclock) begin
      hcount <= hreset ? 0 : hcount + 1;
      hblank <= next_hblank;
      hsync <= hsyncon ? 0 : hsyncoff ? 1 : hsync;  // active low

      vcount <= hreset ? (vreset ? 0 : vcount + 1) : vcount;
      vblank <= next_vblank;
      vsync <= vsyncon ? 0 : vsyncoff ? 1 : vsync;  // active low

      blank <= next_vblank | (next_hblank & ~hreset);
   end
endmodule
