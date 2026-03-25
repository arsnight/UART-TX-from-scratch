# UART-TX-from-scratch
UART Transmitter (TX) implemented in Verilog from scratch, focusing on FSM design, baud rate generation and a testbench for verification.

# Day 1 - Design
Planned architecture:
- Baud rate generator
- Data storage

As a beginner to the field of verilog, a lot in this project was just me switching from the "software" thinking to the hardware thinking. After reviewing the theory and concepts regarding a complete UART module, I decided to start with a transmitter module first as that felt easier than the receiver (And indeed it was!)

The first step in this project was to assume the input data is going to be received to the tx (transmitter) module in parallel form. This usually just meant instead of bit by bit input, the inputs will be a collection of bits instead (better called bytes). Example for the alphabet A, the parallel input would be 01000001. Hence, we need to store this data somewhere because if we use it raw, data can change and then the tx module will just output a bunch of gibberish.

This is where I got my first roadblock, I started thinking in terms of software, making codes like - 
```verilog  
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
```
Looks correct right? No.
The thing is, this code forces data_stored to update every clock cycle.
For example, imagine transmitting:

A → B → C

If `data_stored` updates continuously, the transmitter may output:

- First few bits from A
- Then some bits from B
- Then remaining bits from C

Absolutely corrupted UART frame, essentially just a gibberish output. This was my first major realization in shifting from software thinking to hardware thinking — signals must often be *latched* at the right time rather than continuously updated.

To solve this I used a trigger, an edge detection logic instead. Introducing a reg start_tx along with another reg prev_state, while using this logic -
```verilog  
module Input_storage (
  input clk,
  input reset,
  input start_tx,
  input [7:0] parallel_in,
  output reg [7:0] data_stored
  );

  reg prev_state = 0;  //------> Don't forget to initialize, a good habit!
  always @(posedge clk or posedge reset) begin
    if (prev_state == 0 && start_tx == 1) begin
      data_stored <= parallel_in;
    end
      prev_state <= start_tx;
  end
endmodule
```
Now that issue was solved, the next time is to create the backbone of this project, `The Baud tick generator`. As complicated as it sounds, the code was rather simple. For this project I went with the most common baud rate of 115200:

- For the standard baud tick, Baud rate = 115200 bits/s
- Each bit will last for around 1/115200 seconds or 8.68us
- Fundamental time period of clock on FPGA = 10ns
- So, if 1 cycle takes 10ns, then 8.68us/10ns cycles take 8.68us.

By simple arthmetic, each baud tick will last for exactly 868 on board clock ticks. Hence the code logic is simple, initialize a counter that adds each time it isn't equal to 10'd867 (counter starts at 0, so total counts will be from 0 to 867) and reset it once it reaches 10'd867.
```verilog
module baud_rate_gen(
  input clk,
  output reg tick
);
  reg [9:0] count = 0;
  always @(posedge clk) begin
    if (count == 10'd867) begin
      tick <= 1'b1;
      count <= 0;
    end
    else begin
      count <= count + 1'b1;
      tick <= 0;
    end
  end
endmodule
```
