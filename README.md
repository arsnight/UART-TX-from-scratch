# UART-TX-from-scratch
UART Transmitter (TX) implemented in Verilog from scratch, focusing on FSM design, baud rate generation and a testbench for verification.

# Day 1 - Design
Planned architecture:
- Baud rate generator
- Data storage

As a beginner to the field of verilog, a lot in this project was just me switching from the "software" thinking to the hardware thinking. After reviewing the theory and concepts regarding a complete UART module, I decided to start with a transmitter module first as that felt easier than the receiver (And indeed it was!)

The first step in this project was to assume the input data is going to be received to the tx (transmitter) module in parallel form. This usually just meant instead of bit by bit input, the inputs will be a collection of bits instead (better called bytes). Example for the alphabet A, the parallel input would be 01000001. Hence, we need to store this data somewhere because if we use it raw, data can change and then the tx module will just output a bunch of gibberish.

This is where I got my first roadblock, I started thinking in terms of software, making codes like - 

module Input_storage (
  input clk,
  input reset,
  input [7:0] parallel_in,
  output reg [7:0] data_stored
  );
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      data_stored <= 0;
    end
    else begin
      data_stored <= parallel_in;
    end
  end
endmodule

Looks correct right? No.
The thing is, this code forces data_stored to update every clock cycle. Imagine a data coming like A....B....C and so on. By this code, the data_stored will update continuously every clock cycle forcing maybe half of A, quarter of B, a bit from C and so on. This is just gibberish. What 
