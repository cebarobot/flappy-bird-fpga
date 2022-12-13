module rom #(
    parameter WIDTH = 8,
    parameter DEPTH = 256,
    parameter INIT_FILE = "",
    localparam ADDR_WIDTH = $clog2(DEPTH)
) (
    input  clk,
    input  rstn,
    input  [ADDR_WIDTH-1:0] addr,
    output reg [WIDTH-1:0]  data
);

reg  [WIDTH-1:0] mem [0:DEPTH-1];

initial begin
    if (INIT_FILE != 0) begin
        $readmemh(INIT_FILE, mem);
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        data <= 0;
    end else begin
        data <= mem[addr];
    end
end

endmodule
