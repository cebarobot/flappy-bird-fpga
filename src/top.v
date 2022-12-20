module top (
    input  clk_in,              // clock in
    input  rstn,              // reset signal

    input  button,              // button input

    output vga_clk,             // VGA clk
    output reg vga_hsync,       // VGA horizontal sync
    output reg vga_vsync,       // VGA vertical sync
    output reg vga_de,          // VGA data enable
    output reg [15:0] vga_rgb   // VGA RGB565
);

wire pix_clk;

wire [15:0] paint_x;
wire [15:0] paint_y;

wire raw_hsync;
wire raw_vsync;
wire raw_de;
wire [15:0] raw_color;

wire new_line;
wire new_frame;

wire [15:0] background_color;
wire stage_pe;
wire [15:0] stage_color;
wire pipe_pe;
wire [15:0] pipe_color;
wire bird_pe;
wire [15:0] bird_color;

wire [7:0] stage_shift = 0;

wire signed [15:0] pipe1_pos_x = 680;
wire signed [15:0] pipe1_pos_y = -50;
wire signed [15:0] pipe2_pos_x = 500;
wire signed [15:0] pipe2_pos_y = 150;
wire signed [15:0] pipe3_pos_x = 450;
wire signed [15:0] pipe3_pos_y = 350;

wire signed [15:0] bird_pos_x = 400;
wire signed [15:0] bird_pos_y = 240;
wire signed [ 7:0] bird_angle = 8'd10;
wire [1:0] bird_status = 2'b00;

// TODO: generate pixel clk
// for simulation
assign pix_clk = clk_in;
// TODO: for FPGA


// TODO: button logic

// TODO: gaming logic

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

assign raw_color =
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
