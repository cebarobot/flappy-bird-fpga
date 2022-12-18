module dis_stage(
    input  clk,
    input  rstn,

    input signed [ 7:0] shift,

    input new_frame,
    input signed [15:0] paint_x, 
    input signed [15:0] paint_y,
    output paint_enable,
    output [15:0] paint_color
);

localparam offset = 4;
parameter pos_x = 128;
parameter sprite_height = 8;
parameter sprite_width = 120;

wire signed [15:0] s4_x;
reg  signed [15:0] s4_sprite_x;
wire signed [15:0] s4_y;
reg  signed [15:0] s4_counter;
wire s4_do_count;
reg  s4_active;

assign s4_x = paint_x + offset - pos_x;
assign s4_y = paint_y;
always @(posedge clk) begin
    if (~rstn) begin
        s4_sprite_x <= 0;
        s4_active <= 0;
    end else begin
        s4_sprite_x <= s4_x;
        s4_active <= 
            s4_x >= 0 && s4_x < sprite_height * 4 &&
            s4_y >= 0 && s4_y < sprite_width * 4;
    end
end
assign s4_do_count = 
    s4_active && s4_sprite_x == sprite_height * 4 - 1;
always @(posedge clk) begin
    if (~rstn) begin
        s4_counter <= 0;
    end else if (new_frame) begin
        s4_counter <= 0;
    end else if (s4_do_count) begin
        if (s4_counter == 4 * 7 - 1) begin
            s4_counter <= 0;
        end else begin
            s4_counter <= s4_counter + 1;
        end
    end
end

wire signed [15:0] s3_bitmap_x;
wire signed [15:0] s3_bitmap_y;
reg  signed [15:0] s3_addr;
reg  s3_active;

assign s3_bitmap_x = s4_sprite_x >> 2;
assign s3_bitmap_y = (s4_counter + 16'(shift)) >> 2;
always @(posedge clk) begin
    if (~rstn) begin
        s3_addr <= 0;
        s3_active <= 0;
    end else begin
        s3_addr <= s3_bitmap_x + s3_bitmap_y * sprite_height;
        s3_active <= s4_active;
    end
end

wire [3:0] s2_index;
reg  s2_active;
rom #(
    .WIDTH      (4),
    .DEPTH      (112),
    .INIT_FILE  ("images/stage.mem")
) rom_background_img (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s3_addr[6:0]),
    .data       (s2_index)
);
always @(posedge clk) begin
    if (~rstn) begin
        s2_active <= 0;
    end else begin
        s2_active <= s3_active;
    end
end

wire [15:0] s1_color;
reg  s1_active;
rom #(
    .WIDTH      (16),
    .DEPTH      (8),
    .INIT_FILE  ("images/stage_palette.mem")
) rom_background_palette (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s2_index[2:0]),
    .data       (s1_color)
);
always @(posedge clk) begin
    if (~rstn) begin
        s1_active <= 0;
    end else begin
        s1_active <= s2_active;
    end
end

assign paint_enable = s1_active;
assign paint_color = s1_color;

endmodule
