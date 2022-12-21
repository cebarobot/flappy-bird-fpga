module dis_sprite #(
    parameter   sprite_height = 40,
    parameter   sprite_width = 120,
    parameter   bitmap_depth = 64,
    parameter   palette_depth = 8,
    parameter   bitmap_file = "",
    parameter   palette_file = ""
) (
    input  clk,
    input  rstn,

    input  enable,
    input  signed [15:0] pos_x,
    input  signed [15:0] pos_y,
    input  signed [15:0] bitmap_offset,

    input  signed [15:0] paint_x, 
    input  signed [15:0] paint_y,
    output paint_enable,
    output [15:0] paint_color
);

localparam  addr_width = $clog2(bitmap_depth);
localparam  index_width = $clog2(palette_depth);
localparam  offset = 4;

wire signed [15:0] s1_x;
wire signed [15:0] s1_y;
reg  signed [15:0] s1_sprite_x;
reg  signed [15:0] s1_sprite_y;
reg  s1_active;

assign s1_x = paint_x + offset - pos_x;
assign s1_y = paint_y - pos_y;
always @(posedge clk) begin
    if (~rstn) begin
        s1_sprite_x <= 0;
        s1_sprite_y <= 0;
        s1_active <= 0;
    end else begin
        s1_sprite_x <= s1_x;
        s1_sprite_y <= s1_y;
        s1_active <= enable && (
            s1_x >= 0 && s1_x < sprite_height * 4 &&
            s1_y >= 0 && s1_y < sprite_width * 4
        );
    end
end

wire signed [15:0] s2_bitmap_x;
wire signed [15:0] s2_bitmap_y;
reg  signed [15:0] s2_addr;
reg  s2_active;

assign s2_bitmap_x = s1_sprite_x >> 2;
assign s2_bitmap_y = s1_sprite_y >> 2;
always @(posedge clk) begin
    if (~rstn) begin
        s2_addr <= 0;
        s2_active <= 0;
    end else begin
        s2_addr <= bitmap_offset + s2_bitmap_x + s2_bitmap_y * sprite_height;
        s2_active <= s1_active;
    end
end

wire [3:0] s3_index;
reg  s3_active;
rom #(
    .WIDTH      (4),
    .DEPTH      (bitmap_depth),
    .INIT_FILE  (bitmap_file)
) rom_background_img (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s2_addr[addr_width-1:0]),
    .data       (s3_index)
);
always @(posedge clk) begin
    if (~rstn) begin
        s3_active <= 0;
    end else begin
        s3_active <= s2_active;
    end
end

wire [15:0] s4_color;
reg  s4_active;
rom #(
    .WIDTH      (16),
    .DEPTH      (palette_depth),
    .INIT_FILE  (palette_file)
) rom_background_palette (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s3_index[index_width-1:0]),
    .data       (s4_color)
);
always @(posedge clk) begin
    if (~rstn) begin
        s4_active <= 0;
    end else begin
        s4_active <= s3_active && s3_index != 0;
    end
end

assign paint_color = s4_color;
assign paint_enable = s4_active;

endmodule
