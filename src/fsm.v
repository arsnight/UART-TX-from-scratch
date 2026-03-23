module FSM(
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
        
        
        if (start_tx == 1'b1) begin
            
        if (tick) begin
            if (state == IDLE) begin
                serial_out <= 1;
            end
            else if (state == START_BIT) begin
                    state <= DATA_BITS; //data_bit
                    if (tick) begin 
                        serial_out <= 0;
                    end
            end
            else if (state == DATA_BITS) begin
                counter <= counter + 1'b1;
                serial_out <= data_stored[counter];
                if (counter == 3'b111) begin
                        state <= STOP_BIT; //stop_bit
                        counter <= 3'b0;
                end
             end
             else if (state == STOP_BIT) begin
                    state <= IDLE;
                    serial_out <= 1;
             end
         end
     end                           
endmodule
