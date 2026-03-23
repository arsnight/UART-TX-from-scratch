module UART_TX(
    input clk,
    input [7:0] parallel_in,
    input start_tx,
    output reg [7:0] data_stored,
    output reg prev_state,
    output reg serial_out
    );
    
    wire tick;
    
    baud_rate_gen baud_rate(
        .clk(clk),
        .tick(tick)
        );
    
    always @(posedge clk) begin
        if (prev_state == 1'b0 && start_tx == 1'b1) begin
            data_stored <= parallel_in;
        end
        
        prev_state <= start_tx;
    end
    
endmodule
