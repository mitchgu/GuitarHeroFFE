module CL_block(
    input clk, //100mhz clk
    input clk25, //25mhz clk
    input pause_SW, //Debounced switch input for pause
    input reset_button, //Debounced button for reset
    input [36:0] metadata_request,
    input SD_CD,
    
    inout [3:0] SD_DAT,
    
    output SD_RESET,
    output SD_SCK,
    output SD_CMD,
    output [37*16-1:0] metadata_link,
    output [36:0] metadata_available,
    output reset, //status signal for reset
    output pause, //status signal for game-pause
    output [15:0] song_time //current song_time
    );
    
    wire data_loaded;
    //wire song_loaded;
    reg song_loaded = 1; //assuming no song for now
    
    /*
    //////////////////////////////////////////////////////////////////////////////////
    //  SD stuff
    
    localparam SONG_ADR = 32'h00_01_00_00;
    localparam DATA_ADR = 32'h00_00_00_00;
        
    wire rst = reset;
    wire spiClk;
    wire spiMiso;
    wire spiMosi;
    wire spiCS;

    // MicroSD SPI/SD Mode/Nexys 4
    // 1: Unused / DAT2 / SD_DAT[2]
    // 2: CS / DAT3 / SD_DAT[3]
    // 3: MOSI / CMD / SD_CMD
    // 4: VDD / VDD / ~SD_RESET
    // 5: SCLK / SCLK / SD_SCK
    // 6: GND / GND / - 
    // 7: MISO / DAT0 / SD_DAT[0]
    // 8: UNUSED / DAT1 / SD_DAT[1]
    assign SD_DAT[2] = 1;
    assign SD_DAT[3] = spiCS;
    assign SD_CMD = spiMosi;
    assign SD_RESET = 0;
    assign SD_SCK = spiClk;
    assign spiMiso = SD_DAT[0];
    assign SD_DAT[1] = 1;
    
    reg rd = 0;
    reg wr = 0;
    reg [7:0] din = 0;
    wire [7:0] dout;
    wire byte_available;
    wire ready;
    wire ready_for_next_byte;
    reg [31:0] adr = DATA_ADR;
    reg [31:0] next_adr = DATA_ADR;
    
    reg [15:0] bytes = 0;
    reg [1:0] bytes_read = 0;
    
    wire [4:0] state;
    
    parameter STATE_INIT = 0;
    parameter STATE_START = 1;
    parameter STATE_WRITE = 2;
    parameter STATE_READ = 3;
    reg [1:0] test_state = STATE_INIT; 
    //assign LED = {state, ready, test_state, bytes[15:8]};  
    
    sd_controller sd( //these connections are not in io order
        .cs(spiCS), // Connect to SD_DAT[3].
        .mosi(spiMosi), // Connect to SD_CMD.
        .miso(spiMiso), // Connect to SD_DAT[0].
        .sclk(spiClk), // Connect to SD_SCK.
                            // For SPI mode, SD_DAT[2] and SD_DAT[1] should be held HIGH. 
                            // SD_RESET should be held LOW.
        .rd(rd), // Read-enable. When [ready] is HIGH, asseting [rd] will 
                            // begin a 512-byte READ operation at [address]. 
                            // [byte_available] will transition HIGH as a new byte has been
                            // read from the SD card. The byte is presented on [dout].
        .dout(dout), // Data output for READ operation.
        .byte_available(byte_available), // A new byte has been presented on [dout].
        .wr(wr), // Write-enable. When [ready] is HIGH, asserting [wr] will
                            // begin a 512-byte WRITE operation at [address].
                            // [ready_for_next_byte] will transition HIGH to request that
                            // the next byte to be written should be presentaed on [din].
        .din(din), // Data input for WRITE operation.
        .ready_for_next_byte(ready_for_next_byte), // A new byte should be presented on [din].
        .reset(rst), // Resets controller on assertion.
        .ready(ready), // HIGH if the SD card is ready for a read or write operation.
        .address(adr), // Memory address for read/write operation. This MUST 
                            // be a multiple of 512 bytes, due to SD sectoring.
        .clk(clk25), // 25 MHz clock.
        .status(state) // For debug purposes: Current state of controller.
    );
    
    reg [31:0] data_word;
    
    reg [1:0] bytes_read = 0;
    
    always @(posedge clk25) begin
    
    //SD card metadata loading
        if(!data_loaded) begin //need to load metadata
            if(ready) begin //begin a read
                rd <= 1;
                next_adr <= adr + 512;
            end
            else begin //read bytes, make words (4 bytes each)
                if(byte_available) begin
                    case (bytes_read)
                        0: begin
                            data_word[31:24] <= dout;
                            bytes_read <= 1;
                            write_data <= 0;
                        end
                        1: begin
                            data_word[23:16] <= dout;
                            bytes_read <= 2;
                            write_data <= 0;
                        end
                        2: begin
                            data_word[15:8] <= dout;
                            bytes_read <= 3;
                            write_data <= 0;
                        end
                        3: begin
                            data_word[7:0] <= dout;
                            bytes_read <= 0;
                            write_data <= 1;
                        end
                    endcase
                end
                else
                    write_data <= 0;
            end
        end
        else if(!song_loaded) begin
            //
        end
        adr <= next_adr;
        
    
    
    end
    
    //
    //////////////////////////////////////////////////////////////////////////////////
    */
    
    CL_metadata_controller metadata_controller(
        .clk(clk),
        .clk25(clk25),
        .reset(reset),
        .song_time(song_time),
        .write_en(write_data),
        .write_word(data_word),
        .metadata_request(metadata_request),
        
        //TODO
        
        .metadata_available(metadata_available),
        .metadata_link(metadata_link),
        .loaded(data_loaded)
    );
    
    CL_fsm fsm (
        .clk(clk),
        .pause_SW(pause_SW),
        .data_loaded(data_loaded),
        .song_loaded(song_loaded),
        .reset_trigger(reset_button),
        
        .pause(pause),
        .reset(reset)
    );
    
    CL_song_timer timer (
        .clk(clk),
        .pause(pause),
        .reset(reset),
        
        .song_time(song_time)
    );
    
    
endmodule