module top (
    input  clk_in,              // clock in
    input  rstn,              // reset signal

    input  button,              // button input

    output vga_clk,             // VGA clk
    output reg vga_hsync,       // VGA horizontal sync
    output reg vga_vsync,       // VGA vertical sync
    output reg vga_de,          // VGA data enable
    output reg [4:0] vga_r,     // VGA 5-bit red
    output reg [5:0] vga_g,     // VGA 6-bit green
    output reg [4:0] vga_b      // VGA 5-bit blue
);

wire pix_clk;

wire [15:0] paint_x;
wire [15:0] paint_y;

wire raw_hsync;
wire raw_vsync;
wire raw_de;
wire [7:0] raw_r;
wire [7:0] raw_g;
wire [7:0] raw_b;

// TODO: generate pixel clk
// for simulation
assign pix_clk = clk_in;
// TODO: for FPGA


// TODO: button logic

// TODO: gaming logic

// scanning logic
vga_scan u_vga_scan(
    .pix_clk    (pix_clk),
    .pix_rstn   (rstn),
    .sx         (paint_x),
    .sy         (paint_y),
    .hsync      (raw_hsync),
    .vsync      (raw_vsync),
    .de         (raw_de)
);

// TODO: graphic logic
graphic u_graphic(
    .pix_clk    (pix_clk),
    .pix_rstn   (rstn),
    .sx         (paint_x),
    .sy         (paint_y),
    .button     (button),
    .paint_r    (raw_r),
    .paint_g    (raw_g),
    .paint_b    (raw_b)
);


// output ff
always @ (posedge pix_clk) begin
    vga_hsync <= raw_hsync;
    vga_vsync <= raw_vsync;
    vga_de <= raw_de;
    vga_r <= raw_de ? raw_r[7-:5] : 0;
    vga_g <= raw_de ? raw_g[7-:6] : 0;
    vga_b <= raw_de ? raw_b[7-:5] : 0;
end
assign vga_clk = pix_clk;

endmodule
