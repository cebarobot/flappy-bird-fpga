`include "config.vh"
module vga_scan (
    input  pix_clk,                 // clock
    input  pix_rstn,                // reset
    output reg signed [15:0] sx,    // horizontal pixel
    output reg signed [15:0] sy,    // vertical pixel
    output reg hsync,               // horizontal sync
    output reg vsync,               // vertical sync
    output reg de                   // data enable
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

parameter H_STA     = 0 - H_FP - H_PW - H_BP;
parameter HS_STA    = H_STA + H_FP;
parameter HS_END    = HS_STA + H_PW;
parameter HA_STA    = 0;
parameter HA_END    = H_W;

parameter V_STA     = 0 - V_FP - V_PW - V_BP;
parameter VS_STA    = V_STA + V_FP;
parameter VS_END    = VS_STA + V_PW;
parameter VA_STA    = 0;
parameter VA_END    = V_H;

reg signed [15:0] pos_x;
reg signed [15:0] pos_y;

always @(posedge pix_clk) begin
    if (~pix_rstn) begin
        pos_x <= 0;
        pos_y <= 0;
    end else if (pos_x == HA_END - 1) begin
        pos_x <= H_STA;
        pos_y <= (pos_y == VA_END - 1)? V_STA : pos_y + 1;
    end else begin
        pos_x <= pos_x + 1;
    end
end

always @(posedge pix_clk) begin
    if (~pix_rstn) begin
        sx <= 0;
        sy <= 0;
        hsync <= 0;
        vsync <= 0;
        de <= 0;
    end else begin
        sx <= pos_x;
        sy <= pos_y;
        hsync <= !(pos_x >= HS_STA && pos_x < HS_END);
        vsync <= !(pos_y >= VS_STA && pos_y < VS_END);
        de <= (pos_x >= HA_STA && pos_x < HA_END && pos_y >= VA_STA && pos_y < VA_END);
    end
end

endmodule
