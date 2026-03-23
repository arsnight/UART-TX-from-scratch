module fsm(
    input clk,
    input [7:0] data_stored,
    input tick,
    input start_tx,
    output reg serial_out
    );
    
    
    reg [3:0] state;
    reg [3:0] counter;
    
    localparam IDLE = 0;
    localparam START_BIT = 1;
    localparam DATA_BITS = 2;
    localparam STOP_BIT = 3;
    
    
    always @(posedge clk) begin                
            if (tick) begin
                if (state == IDLE) begin
                    serial_out <= 1;
                    if (start_tx == 1'b1) begin
                        state <= START_BIT;
                    end
                end
                else if (state == START_BIT) begin
                        state <= DATA_BITS;
                        counter <= 0;
                        serial_out <= 0;
                end
                else if (state == DATA_BITS) begin
                    serial_out <= data_stored[counter];
                    counter <= counter + 1'b1;
                    if (counter == 3'b111) begin
                            state <= STOP_BIT;
                    end
                end
                else if (state == STOP_BIT) begin
                        state <= IDLE;
                        counter <= 3'b000;
                        serial_out <= 1;
                end
                end
            end                        
endmodule
    
