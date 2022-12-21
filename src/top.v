module top (
    input  clk_in,              // clock in
    input  rstn,                // reset signal

    input  button,              // button input

    output vga_clk,             // VGA clk
    output reg vga_hsync,       // VGA horizontal sync
    output reg vga_vsync,       // VGA vertical sync
    output reg vga_de,          // VGA data enable
    output reg [15:0] vga_rgb   // VGA RGB565
);

wire pix_clk;

wire button_pulse;

wire [15:0] paint_x;
wire [15:0] paint_y;

wire raw_hsync;
wire raw_vsync;
wire raw_de;
wire [15:0] raw_color;
wire title_pe;
wire [15:0] title_color;

wire new_line;
wire new_frame;

wire [15:0] background_color;
wire stage_pe;
wire [15:0] stage_color;
wire pipe_pe;
wire [15:0] pipe_color;
wire bird_pe;
wire [15:0] bird_color;
wire logo_pe;
wire [15:0] logo_color;
wire ready_pe;
wire [15:0] ready_color;
wire over_pe;
wire [15:0] over_color;
wire hint_pe;
wire [15:0] hint_color;

wire [15:0] stage_shift;

wire signed [15:0] pipe1_pos_x;
wire signed [15:0] pipe1_pos_y;
wire signed [15:0] pipe2_pos_x;
wire signed [15:0] pipe2_pos_y;
wire signed [15:0] pipe3_pos_x;
wire signed [15:0] pipe3_pos_y;

wire signed [15:0] bird_pos_x;
wire signed [15:0] bird_pos_y;
wire signed [ 7:0] bird_angle;
wire [1:0] bird_status;

wire logo_enable;
wire ready_enable;
wire over_enable;

// TODO: generate pixel clk
// for simulation
assign pix_clk = clk_in;
// TODO: for FPGA


// button logic
button_pulse u_button_pulse(
    .clk    (pix_clk),
    .resetn (rstn),
    .btn    (button),
    .pulse  (button_pulse)
);

// TODO: gaming logic
game u_game(
    .clk            (pix_clk),
    .rstn           (rstn),
    .button_pulse   (button_pulse),
    .new_frame      (new_frame),
    .stage_shift    (stage_shift),
    .bird_status    (bird_status),
    .pipe1_pos_x    (pipe1_pos_x),
    .pipe1_pos_y    (pipe1_pos_y),
    .pipe2_pos_x    (pipe2_pos_x),
    .pipe2_pos_y    (pipe2_pos_y),
    .pipe3_pos_x    (pipe3_pos_x),
    .pipe3_pos_y    (pipe3_pos_y),
    .bird_pos_x     (bird_pos_x),
    .bird_pos_y     (bird_pos_y),
    .bird_angle     (bird_angle),
    .logo_enable    (logo_enable),
    .ready_enable   (ready_enable),
    .over_enable    (over_enable)
);

// scanning logic
vga_scan u_vga_scan(
    .pix_clk    (pix_clk),
    .pix_rstn   (rstn),
    .sx         (paint_x),
    .sy         (paint_y),
    .hsync      (raw_hsync),
    .vsync      (raw_vsync),
    .de         (raw_de),
    .new_line   (new_line),
    .new_frame  (new_frame)
);

// TODO: graphic logic
dis_background u_dis_background(
    .clk            (pix_clk),
    .rstn           (rstn),
    .paint_x        (paint_x),
    .paint_y        (paint_y),
    .paint_color    (background_color)
);

dis_stage u_dis_stage(
    .clk            (pix_clk),
    .rstn           (rstn),
    .shift          (stage_shift),
    .new_frame      (new_frame),
    .paint_x        (paint_x),
    .paint_y        (paint_y),
    .paint_enable   (stage_pe),
    .paint_color    (stage_color)
);

dis_pipe u_dis_pipe(
    .clk            (pix_clk),
    .rstn           (rstn),
    .pos_x1         (pipe1_pos_x),
    .pos_y1         (pipe1_pos_y),
    .pos_x2         (pipe2_pos_x),
    .pos_y2         (pipe2_pos_y),
    .pos_x3         (pipe3_pos_x),
    .pos_y3         (pipe3_pos_y),
    .paint_x        (paint_x),
    .paint_y        (paint_y),
    .paint_enable   (pipe_pe),
    .paint_color    (pipe_color)
);

dis_bird u_dis_bird(
    .clk            (pix_clk),
    .rstn           (rstn),
    .pos_x          (bird_pos_x),
    .pos_y          (bird_pos_y),
    .angle          (bird_angle),
    .bird_status    (bird_status),
    .paint_x        (paint_x),
    .paint_y        (paint_y),
    .paint_enable   (bird_pe),
    .paint_color    (bird_color)
);

dis_sprite #(
    .sprite_height  (22),
    .sprite_width   (96),
    .bitmap_depth   (2112),
    .palette_depth  (5),
    .bitmap_file    ("images/logo.mem"),
    .palette_file   ("images/logo_palette.mem")
) u_dis_logo (
    .clk            (pix_clk),
    .rstn           (rstn),
    .enable         (logo_enable),
    .pos_x          (570),
    .pos_y          (48),
    .bitmap_offset  (0),
    .paint_x        (paint_x),
    .paint_y        (paint_y),
    .paint_enable   (logo_pe),
    .paint_color    (logo_color)
);

dis_sprite #(
    .sprite_height  (22),
    .sprite_width   (87),
    .bitmap_depth   (1914),
    .palette_depth  (4),
    .bitmap_file    ("images/ready.mem"),
    .palette_file   ("images/ready_palette.mem")
) u_dis_ready (
    .clk            (pix_clk),
    .rstn           (rstn),
    .enable         (ready_enable),
    .pos_x          (540),
    .pos_y          (66),
    .bitmap_offset  (0),
    .paint_x        (paint_x),
    .paint_y        (paint_y),
    .paint_enable   (ready_pe),
    .paint_color    (ready_color)
);
dis_sprite #(
    .sprite_height  (49),
    .sprite_width   (39),
    .bitmap_depth   (1911),
    .palette_depth  (7),
    .bitmap_file    ("images/hint.mem"),
    .palette_file   ("images/hint_palette.mem")
) u_dis_hint (
    .clk            (pix_clk),
    .rstn           (rstn),
    .enable         (ready_enable),
    .pos_x          (260),
    .pos_y          (198),
    .bitmap_offset  (0),
    .paint_x        (paint_x),
    .paint_y        (paint_y),
    .paint_enable   (hint_pe),
    .paint_color    (hint_color)
);

dis_sprite #(
    .sprite_height  (19),
    .sprite_width   (94),
    .bitmap_depth   (1786),
    .palette_depth  (4),
    .bitmap_file    ("images/over.mem"),
    .palette_file   ("images/over_palette.mem")
) u_dis_over (
    .clk            (pix_clk),
    .rstn           (rstn),
    .enable         (over_enable),
    .pos_x          (540),
    .pos_y          (52),
    .bitmap_offset  (0),
    .paint_x        (paint_x),
    .paint_y        (paint_y),
    .paint_enable   (over_pe),
    .paint_color    (over_color)
);

assign title_pe = logo_pe || ready_pe || hint_pe || over_pe;
assign title_color = 
    ({16{logo_pe}} & logo_color) |
    ({16{ready_pe}} & ready_color) |
    ({16{hint_pe}} & hint_color) |
    ({16{over_pe}} & over_color);

assign raw_color =
    (title_pe)? title_color:
    (bird_pe)?  bird_color:
    (pipe_pe)?  pipe_color:
    (stage_pe)? stage_color:
    background_color;

// output ff
always @ (posedge pix_clk) begin
    vga_hsync <= raw_hsync;
    vga_vsync <= raw_vsync;
    vga_de <= raw_de;
    vga_rgb <= raw_de ? raw_color : 0;
end
assign vga_clk = pix_clk;

endmodule
