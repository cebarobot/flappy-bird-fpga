module dis_pipe(
    input  clk,
    input  rstn,

    input signed [15:0] pos_x1,
    input signed [15:0] pos_y1,
    input signed [15:0] pos_x2,
    input signed [15:0] pos_y2,
    input signed [15:0] pos_x3,
    input signed [15:0] pos_y3,

    input signed [15:0] paint_x, 
    input signed [15:0] paint_y,
    output paint_enable,
    output [15:0] paint_color

);

localparam offset = 4;
parameter pos_x0 = 128;

parameter head_height1 = 12;
parameter head_width1 = 26;
parameter head_height2 = head_height1 * 4;
parameter head_width2 = head_width1 * 4;
parameter open_height = 208;

wire signed [15:0] s1_x;
wire signed [15:0] s1_x0;
wire signed [15:0] s1_x11;
wire signed [15:0] s1_x12;
wire signed [15:0] s1_x21;
wire signed [15:0] s1_x22;
wire signed [15:0] s1_x31;
wire signed [15:0] s1_x32;

wire signed [15:0] s1_y1;
wire signed [15:0] s1_y2;
wire signed [15:0] s1_y3;

reg  signed [15:0] s1_sprite_x;
reg  signed [15:0] s1_sprite_y;
reg  [1:0] s1_type;
reg  s1_active;

assign s1_x = paint_x + offset;
assign s1_x0 = s1_x - pos_x0;
assign s1_x11 = s1_x - pos_x1;
assign s1_x12 = s1_x - pos_x1 + open_height + head_height2;
assign s1_x21 = s1_x - pos_x2;
assign s1_x22 = s1_x - pos_x2 + open_height + head_height2;
assign s1_x31 = s1_x - pos_x3;
assign s1_x32 = s1_x - pos_x3 + open_height + head_height2;
assign s1_y1 = paint_y - pos_y1;
assign s1_y2 = paint_y - pos_y2;
assign s1_y3 = paint_y - pos_y3;

always @(posedge clk) begin
    if (~rstn) begin
        s1_sprite_x <= 0;
        s1_sprite_y <= 0;
        s1_active <= 0;
    end else begin
        s1_active <= 0;
        s1_sprite_x <= s1_x;
        s1_sprite_y <= paint_y;
        if (s1_y1 >= 0 && s1_y1 < head_width2) begin
            s1_sprite_y <= s1_y1;
            if (s1_x11 >= 0 && s1_x11 < head_height2) begin
                s1_sprite_x <= s1_x11;
                s1_type <= 1;
                s1_active <= 1;
            end else if (s1_x12 >= 0 && s1_x12 < head_height2) begin
                s1_sprite_x <= s1_x12;
                s1_type <= 2;
                s1_active <= 1;
            end else if (s1_x11 >= head_height2 || (s1_x0 >= 0 && s1_x12 < 0)) begin
                s1_sprite_x <= s1_x0;
                s1_type <= 0;
                s1_active <= 1;
            end
        end else if (s1_y2 >= 0 && s1_y2 < head_width2) begin
            s1_sprite_y <= s1_y2;
            if (s1_x21 >= 0 && s1_x21 < head_height2) begin
                s1_sprite_x <= s1_x21;
                s1_type <= 1;
                s1_active <= 1;
            end else if (s1_x22 >= 0 && s1_x22 < head_height2) begin
                s1_sprite_x <= s1_x22;
                s1_type <= 2;
                s1_active <= 1;
            end else if (s1_x21 >= head_height2 || (s1_x0 >= 0 && s1_x22 < 0)) begin
                s1_sprite_x <= s1_x0;
                s1_type <= 0;
                s1_active <= 1;
            end
        end else if (s1_y3 >= 0 && s1_y3 < head_width2) begin
            s1_sprite_y <= s1_y3;
            if (s1_x31 >= 0 && s1_x31 < head_height2) begin
                s1_sprite_x <= s1_x31;
                s1_type <= 1;
                s1_active <= 1;
            end else if (s1_x32 >= 0 && s1_x32 < head_height2) begin
                s1_sprite_x <= s1_x32;
                s1_type <= 2;
                s1_active <= 1;
            end else if (s1_x31 >= head_height2 || (s1_x0 >= 0 && s1_x32 < 0)) begin
                s1_sprite_x <= s1_x0;
                s1_type <= 0;
                s1_active <= 1;
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
        s2_type <= 0;
        s2_active <= 0;
    end else begin
        if (s1_type == 1 || s1_type == 2) begin
            s2_addr <= s2_bitmap_x + s2_bitmap_y * head_height1;
        end else begin
            s2_addr <= s2_bitmap_y;
        end
        s2_type <= s1_type;
        s2_active <= s1_active;
    end
end

wire [3:0] s3_index;
wire [3:0] s3_index0;
wire [3:0] s3_index1;
wire [3:0] s3_index2;
reg  [1:0] s3_type;
reg  s3_active;
rom #(
    .WIDTH      (4),
    .DEPTH      (26),
    .INIT_FILE  ("images/pipe0.mem")
) rom_pipe0 (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s2_addr[4:0]),
    .data       (s3_index0)
);
rom #(
    .WIDTH      (4),
    .DEPTH      (312),
    .INIT_FILE  ("images/pipe1.mem")
) rom_pipe1 (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s2_addr[8:0]),
    .data       (s3_index1)
);
rom #(
    .WIDTH      (4),
    .DEPTH      (312),
    .INIT_FILE  ("images/pipe2.mem")
) rom_pipe2 (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s2_addr[8:0]),
    .data       (s3_index2)
);

assign s3_index = 
    ({4{s3_type == 0}} & s3_index0) |
    ({4{s3_type == 1}} & s3_index1) |
    ({4{s3_type == 2}} & s3_index2);

always @(posedge clk) begin
    if (~rstn) begin
        s3_type <= 0;
        s3_active <= 0;
    end else begin
        s3_type <= s2_type;
        s3_active <= s2_active;
    end
end

wire [15:0] s4_color;
reg  s4_active;

rom #(
    .WIDTH      (16),
    .DEPTH      (6),
    .INIT_FILE  ("images/pipe_palette.mem")
) rom_background_palette (
    .clk        (clk),
    .rstn       (rstn),
    .addr       (s3_index[2:0]),
    .data       (s4_color)
);
always @(posedge clk) begin
    if (~rstn) begin
        s4_active <= 0;
    end else begin
        s4_active <= s3_active && s3_index != 0;
    end
end


assign paint_enable = s4_active;
assign paint_color = s4_color;

endmodule
