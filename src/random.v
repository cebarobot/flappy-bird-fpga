module random(
    input clk,
    input rstn,
    output reg [7:0] random
);

wire feedback;
reg [3:0] count, count_next;

assign feedback = random[7] ^ random[5] ^ random[4] ^ random[3]; 

always @ (posedge clk) begin
    if (~rstn) begin
        random <= 7'hF;
    end else begin
        random <= {random[6:0], feedback};
    end
end

endmodule
