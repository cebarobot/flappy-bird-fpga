module top (
    input  clk_in,              // clock in
    input  rstn,              // reset signal

    input  button,              // button input

    output vga_clk,             // VGA clk
    output reg vga_hsync,       // VGA horizontal sync
    output reg vga_vsync,       // VGA vertical sync
    output reg vga_de,          // VGA data enable
    output reg [15:0] vga_rgb   // VGA RGB565
);

wire pix_clk;

wire [15:0] paint_x;
wire [15:0] paint_y;

wire raw_hsync;
wire raw_vsync;
wire raw_de;
wire [15:0] raw_color;

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
dis_background u_dis_background(
    .clk        (pix_clk),
    .rstn       (rstn),
    .paint_x    (paint_x),
    .paint_y    (paint_y),
    .paint_color(raw_color)
);

// output ff
always @ (posedge pix_clk) begin
    vga_hsync <= raw_hsync;
    vga_vsync <= raw_vsync;
    vga_de <= raw_de;
    vga_rgb <= raw_de ? raw_color : 0;
end
assign vga_clk = pix_clk;

endmodule
