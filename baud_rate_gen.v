module baud_rate_gen(
    input clk,
    output reg tick
);

reg [9:0] count;

always @(posedge clk) begin
if (count == 1101100011) begin
    tick <= 1;
    count <= 10'b0;
end
else begin
    count <= count + 1'b1;
    tick <= 0;
end
end

endmodule
