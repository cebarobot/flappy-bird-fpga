module debouncer # (
    parameter cnt_depth = 104857
) (
    input  clk,
    input  resetn,

    input  original_sig,    // original signal
    output debounced_sig    // debounced signal
);

localparam cnt_width = $clog2(cnt_depth);

reg  [cnt_width:0] counter;

reg  reg_sig;
always @(posedge clk) begin
    if (~resetn) begin
        reg_sig <= 1'b0;
    end else if (counter == cnt_depth - 1) begin
        reg_sig <= original_sig;
    end
end
assign debounced_sig = reg_sig;

always @(posedge clk) begin
    if (~resetn) begin
        counter <= 0;
    end else if (reg_sig != original_sig) begin
        if (counter != cnt_depth - 1) begin
            counter <= counter + 1;
        end
    end else begin
        counter <= 0;
    end
end

endmodule