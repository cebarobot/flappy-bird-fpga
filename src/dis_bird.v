module dis_bird(
    input  clk,
    input  rstn,

    input signed [15:0] pos_x,
    input signed [15:0] pos_y,
    input signed [ 7:0] angle,
    input [1:0] bird_status,

    input signed [15:0] paint_x, 
    input signed [15:0] paint_y,
    output paint_enable,
    output [15:0] paint_color
);

localparam offset = 7;
parameter sprite_height1 = 12;
parameter sprite_width1 = 17;
parameter sprite_height2 = 68;
parameter sprite_width2 = 68;

reg  signed [15:0] sprite_offset;
always @(posedge clk) begin
    if (~rstn) begin
        sprite_offset <= 0;
    end else begin
        sprite_offset <= 
            ({16{bird_status[0]}} & 16'd204) |
            ({16{bird_status[1]}} & 16'd408);
    end
end

reg  signed [7:0] angle_abs;
wire [ 7:0] sin_raw;
wire [ 7:0] cos_raw;
reg  signed [15:0] sin_res;
reg  signed [15:0] cos_res;

always @(posedge clk) begin
    if (~rstn) begin
        angle_abs <= 0;
        sin_res <= 0;
        cos_res <= 0;
    end else begin
        angle_abs <= angle < 0 ? -angle : - (- angle);  // I don't know why, but only this works
        sin_res <= angle < 0 ? -{8'b0, sin_raw} : {8'b0, sin_raw};
        cos_res <= {8'b0, cos_raw};
    end
end
rom #(
    .WIDTH      (8),
    .DEPTH      (64),
    .INIT_FILE  ("images/sin.mem")
) rom_sim (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (angle_abs[5:0]),
    .data       (sin_raw)
);
rom #(
    .WIDTH      (8),
    .DEPTH      (64),
    .INIT_FILE  ("images/cos.mem")
) rom_cos (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (angle_abs[5:0]),
    .data       (cos_raw)
);

wire signed [15:0] s1_x;
wire signed [15:0] s1_y;
reg  signed [15:0] s1_sprite_x;
reg  signed [15:0] s1_sprite_y;
reg  s1_active;

assign s1_x = paint_x - offset - pos_x;
assign s1_y = paint_y - pos_y;
always @(posedge clk) begin
    if (~rstn) begin
        s1_sprite_x <= 0;
        s1_sprite_y <= 0;
        s1_active <= 0;
    end else begin
        s1_sprite_x <= s1_x;
        s1_sprite_y <= s1_y;
        s1_active <= 
            s1_x >= 0 && s1_x < sprite_height2 &&
            s1_y >= 0 && s1_y < sprite_width2;
    end
end

wire signed [15:0] s2_x;
wire signed [15:0] s2_y;
reg  signed [15:0] s2_sprite_x;
reg  signed [15:0] s2_sprite_y;
reg  s2_active;

assign s2_x = s1_sprite_x - sprite_height2 / 2;
assign s2_y = s1_sprite_y - sprite_width2 / 2;

always @(posedge clk) begin
    if (~rstn) begin
        s2_sprite_x <= 0;
        s2_sprite_y <= 0;
        s2_active <= 0;
    end else begin
        s2_sprite_x <= s2_x;
        s2_sprite_y <= s2_y;
        s2_active <= s1_active;
    end
end

wire signed [23:0] s3_x;
wire signed [23:0] s3_x1;
wire signed [23:0] s3_x2;
wire signed [23:0] s3_y;
wire signed [23:0] s3_y1;
wire signed [23:0] s3_y2;
reg  signed [15:0] s3_sprite_x;
reg  signed [15:0] s3_sprite_y;
reg  s3_active;

assign s3_x = s3_x1 - s3_x2;
assign s3_x1 = s2_sprite_x * cos_res;
assign s3_x2 = s2_sprite_y * sin_res;
assign s3_y = s3_y1 + s3_y2;
assign s3_y1 = s2_sprite_x * sin_res;
assign s3_y2 = s2_sprite_y * cos_res;

always @(posedge clk) begin
    if (~rstn) begin
        s3_sprite_x <= 0;
        s3_sprite_y <= 0;
        s3_active <= 0;
    end else begin
        s3_sprite_x <= s3_x[22:7];
        s3_sprite_y <= s3_y[22:7];
        s3_active <= s2_active;
    end
end

wire signed [15:0] s4_x;
wire signed [15:0] s4_y;
reg  signed [15:0] s4_bitmap_x;
reg  signed [15:0] s4_bitmap_y;
reg  s4_active;

assign s4_x = (s3_sprite_x + sprite_height2 / 2 - 10) >> 2;
assign s4_y = (s3_sprite_y + sprite_height2 / 2) >> 2;

always @(posedge clk) begin
    if (~rstn) begin
        s4_bitmap_x <= 0;
        s4_bitmap_y <= 0;
        s4_active <= 0;
    end else begin
        s4_bitmap_x <= s4_x;
        s4_bitmap_y <= s4_y;
        s4_active <= s3_active;
    end
end

reg  signed [15:0] s5_addr;
reg  s5_active;
always @(posedge clk) begin
    if (~rstn) begin
        s5_addr <= 0;
        s5_active <= 0;
    end else begin
        s5_addr <= s4_bitmap_x + s4_bitmap_y * sprite_height1 + sprite_offset;
        s5_active <= 
            s4_active && 
            s4_bitmap_x >= 0 && s4_bitmap_x < sprite_height1 &&
            s4_bitmap_y >= 0 && s4_bitmap_y < sprite_width1;
    end
end


wire [3:0] s6_index;
reg  s6_active;
rom #(
    .WIDTH      (4),
    .DEPTH      (612),
    .INIT_FILE  ("images/bird.mem")
) rom_background_img (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s5_addr[9:0]),
    .data       (s6_index)
);
always @(posedge clk) begin
    if (~rstn) begin
        s6_active <= 0;
    end else begin
        s6_active <= s5_active;
    end
end

wire [15:0] s7_color;
reg  s7_active;
rom #(
    .WIDTH      (16),
    .DEPTH      (8),
    .INIT_FILE  ("images/bird_palette.mem")
) rom_background_palette (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s6_index[2:0]),
    .data       (s7_color)
);
always @(posedge clk) begin
    if (~rstn) begin
        s7_active <= 0;
    end else begin
        s7_active <= s6_active && s6_index != 0;
    end
end

assign paint_enable = s7_active;
assign paint_color = s7_color;

endmodule
