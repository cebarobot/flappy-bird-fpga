module top (
    input  clk_in,              // clock in
    input  resetn,              // reset signal

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

// TODO: generate pixel clk

// TODO: button logic

// TODO: gaming logic

// TODO: scanning logic

// TODO: graphic logic

endmodule
