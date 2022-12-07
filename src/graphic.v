module graphic (
    input  pix_clk,
    input  pix_rstn,

    input  [15:0] sx,
    input  [15:0] sy,

    output [7:0]  paint_r,
    output [7:0]  paint_g,
    output [7:0]  paint_b
);

wire in_squre;
assign in_squre = (sx > 220 && sx < 420) && (sy > 140 && sy < 340);

assign paint_r = in_squre ? 8'hFF : 8'h10;
assign paint_g = in_squre ? 8'hFF : 8'h30;
assign paint_b = in_squre ? 8'hFF : 8'h70;

endmodule
