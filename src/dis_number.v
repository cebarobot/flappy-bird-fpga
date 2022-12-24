module dis_number(
    input       clk,
    input       rstn,
    
    input  enable,
    input  signed [15:0] pos_x,
    input  signed [15:0] pos_y,
    input  [3:0] num0,
    input  [3:0] num1,

    input  signed [15:0] paint_x, 
    input  signed [15:0] paint_y,
    output paint_enable,
    output [15:0] paint_color
);

localparam offset = 4;

parameter number_height = 10;
parameter number_width = 7;
parameter sprite_height = 40;
parameter sprite_width = 28;

wire signed [15:0] s1_x;
wire signed [15:0] s1_y0;
wire signed [15:0] s1_y1;
reg  signed [15:0] s1_sprite_x;
reg  signed [15:0] s1_sprite_y;
reg  signed [15:0] s1_offset;
reg  s1_active;

assign s1_x = paint_x + offset - pos_x;
assign s1_y0 = paint_y - pos_y - sprite_width - 4;
assign s1_y1 = paint_y - pos_y;

always @(posedge clk) begin
    if (~rstn) begin
        s1_sprite_x <= 0;
        s1_sprite_y <= 0;
        s1_offset <= 0;
        s1_active <= 0;
    end else begin
        s1_sprite_x <= s1_x;
        s1_sprite_y <= s1_y0;
        s1_offset <= 0;
        s1_active <= 0;
        if (s1_x >= 0 && s1_x < sprite_height) begin
            if (s1_y0 >= 0 && s1_y0 < sprite_width) begin
                s1_sprite_y <= s1_y0;
                s1_offset <= num0 * 70;
                s1_active <= enable;
            end else if (s1_y1 >= 0 && s1_y1 < sprite_width) begin
                s1_sprite_y <= s1_y1;
                s1_offset <= 0;
                s1_offset <= num1 * 70;
                s1_active <= enable && num1 != 0;
            end
        end
    end 
end

wire signed [15:0] s2_bitmap_x;
wire signed [15:0] s2_bitmap_y;
reg  signed [15:0] s2_addr;
reg  [1:0] s2_type;
reg  s2_active;

assign s2_bitmap_x = s1_sprite_x >> 2;
assign s2_bitmap_y = s1_sprite_y >> 2;
always @(posedge clk) begin
    if (~rstn) begin
        s2_addr <= 0;
        s2_active <= 0;
    end else begin
        s2_addr <= s1_offset + s2_bitmap_x + s2_bitmap_y * number_height;
        s2_active <= s1_active;
    end
end

wire [3:0] s3_index;
reg  s3_active;
rom #(
    .WIDTH      (4),
    .DEPTH      (700),
    .INIT_FILE  ("images/numbers.mem")
) rom_pipe0 (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s2_addr[9:0]),
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
    .DEPTH      (3),
    .INIT_FILE  ("images/numbers_palette.mem")
) rom_background_palette (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s3_index[1:0]),
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
