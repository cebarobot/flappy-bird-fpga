`include "config.vh"
module vga_scan (
    input  pix_clk,         // clock
    input  pix_rstn,        // reset
    output reg [15:0] sx,   // horizontal pixel
    output reg [15:0] sy,   // vertical pixel
    output hsync,           // horizontal sync
    output vsync,           // vertical sync
    output de               // data enable
);

// timing parameters for different screen
`ifdef LCD_5INCH
    parameter H_W   = 800;
    parameter H_FP  = 210;
    parameter H_PW  = 1;
    parameter H_BP  = 182;

    parameter V_H   = 480;
    parameter V_FP  = 62;
    parameter V_PW  = 5;
    parameter V_BP  = 6;
`elsif VGA_640_480
    parameter H_W   = 640;
    parameter H_FP  = 16;
    parameter H_PW  = 96;
    parameter H_BP  = 48;

    parameter V_H   = 480;
    parameter V_FP  = 10;
    parameter V_PW  = 2;
    parameter V_BP  = 33;
`endif

parameter HA_END    = H_W;
parameter HS_STA    = HA_END + H_FP;
parameter HS_END    = HS_STA + H_PW;
parameter LINE_END  = HS_END + H_BP;

parameter VA_END    = V_H;
parameter VS_STA    = VA_END + V_FP;
parameter VS_END    = VS_STA + V_PW;
parameter FRAME_END = VS_END + V_BP;

assign hsync = !(sx >= HS_STA && sx < HS_END);
assign vsync = !(sy >= VS_STA && sy < VS_END);
assign de = (sx < HA_END && sy < VA_END);

always @(posedge pix_clk) begin
    if (~pix_rstn) begin
        sx <= 0;
        sy <= 0;
    end else if (sx == LINE_END - 1) begin
        sx <= 0;
        sy <= (sy == FRAME_END - 1)? 0 : sy + 1;
    end else begin
        sx <= sx + 1;
    end
end

endmodule
