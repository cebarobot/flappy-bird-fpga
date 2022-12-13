module dis_background(
    input  clk,
    input  rstn,

    input signed [15:0] paint_x, 
    input signed [15:0] paint_y,
    // output paint_enable,
    output [15:0] paint_color
);

localparam offset = 5;
parameter pos_x = 192;
parameter pos_y = 0;
parameter sprite_height = 40;
parameter sprite_width = 120;

wire signed [15:0] s1_sprite_x;
wire signed [15:0] s1_sprite_y;
reg  signed [15:0] s1_sprite_xx;
reg  signed [15:0] s1_sprite_yy;
reg  s1_active;

assign s1_sprite_x = paint_x + offset - pos_x;
assign s1_sprite_y = paint_y - pos_y;
always @(posedge clk) begin
    if (~rstn) begin
        s1_sprite_xx <= 0;
        s1_sprite_yy <= 0;
        s1_active <= 0;
    end else begin
        s1_sprite_xx <= s1_sprite_x;
        s1_sprite_yy <= s1_sprite_y;
        s1_active <= 
            s1_sprite_x >= 0 && s1_sprite_x < sprite_height * 4 &&
            s1_sprite_y >= 0 && s1_sprite_y < sprite_width * 4;
    end
end

wire signed [15:0] s2_bitmap_x;
wire signed [15:0] s2_bitmap_y;
reg  signed [15:0] s2_addr;
reg  s2_active;

assign s2_bitmap_x = s1_sprite_xx >> 2;
assign s2_bitmap_y = s1_sprite_yy >> 2;
always @(posedge clk) begin
    if (~rstn) begin
        s2_addr <= 0;
        s2_active <= 0;
    end else begin
        s2_addr <= s2_bitmap_x + s2_bitmap_y * sprite_height;
        s2_active <= s1_active;
    end
end

wire [3:0] s3_index;
reg  s3_active;
rom #(
    .WIDTH      (4),
    .DEPTH      (4800),
    .INIT_FILE  ("scripts/background.mem")
) rom_background_img (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s2_addr[12:0]),
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
    .DEPTH      (9),
    .INIT_FILE  ("scripts/background_palette.mem")
) rom_background_palette (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s3_index),
    .data       (s4_color)
);
always @(posedge clk) begin
    if (~rstn) begin
        s4_active <= 0;
    end else begin
        s4_active <= s3_active;
    end
end

reg  [15:0] s5_color;
wire is_sky     = paint_x + 1 >= 352;
wire is_tree    = paint_x + 1 >= 160 && paint_x + 1 < 192;
wire is_ground  = paint_x + 1 >= 0 && paint_x +1 < 160;
always @(posedge clk) begin
    if (~rstn) begin
        s5_color <= 0;
    end else if (s4_active) begin
        s5_color <= s4_color;
    end else begin
        s5_color <= 
            ({16{is_sky}} & 16'h7E39) |
            ({16{is_tree}} & 16'h8F31) |
            ({16{is_ground}} & 16'hDED2);
    end
end

assign paint_color = s5_color;
// assign paint_enable = 1;

endmodule
