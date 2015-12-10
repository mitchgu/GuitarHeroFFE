module AV_sync_pipeline
    #(
    parameter stages = 3
    )
    (
    input clk,
    input hsync,
    input vsync,
    input blank,
    
    output phsync,
    output pvsync,
    output pblank
    );
    reg [stages-1:0] h_pipe;
    reg [stages-1:0] v_pipe;
    reg [stages-1:0] b_pipe;
    
    assign phsync = h_pipe[stages-1];
    assign pvsync = v_pipe[stages-1];
    assign pblank = b_pipe[stages-1];
    
    always @(posedge clk) begin
        h_pipe[stages-1:0] <= {h_pipe[stages-2:0],hsync};
        v_pipe[stages-1:0] <= {v_pipe[stages-2:0],vsync};
        b_pipe[stages-1:0] <= {b_pipe[stages-2:0],blank};
    end
    
endmodule