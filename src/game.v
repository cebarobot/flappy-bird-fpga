module game(
    input   clk,
    input   rstn,

    input   button_pulse,
    input   new_frame,

    output reg signed [15:0] stage_shift,

    output reg [1:0] bird_status,

    output reg signed [15:0] pipe1_pos_x,
    output reg signed [15:0] pipe1_pos_y,
    output reg signed [15:0] pipe2_pos_x,
    output reg signed [15:0] pipe2_pos_y,
    output reg signed [15:0] pipe3_pos_x,
    output reg signed [15:0] pipe3_pos_y,

    output reg signed [15:0] bird_pos_x,
    output reg signed [15:0] bird_pos_y,
    output reg signed [ 7:0] bird_angle,

    output reg logo_enable,
    output reg ready_enable,
    output reg over_enable
);

always @(*) begin
    // stage_shift = 13;

    // pipe1_pos_x = 680;
    // pipe1_pos_y = -50;
    // pipe2_pos_x = 500;
    // pipe2_pos_y = 150;
    // pipe3_pos_x = 450;
    // pipe3_pos_y = 350;

    // bird_pos_x = 400;
    // bird_pos_y = 240;
    // bird_angle = 8'd10;
end

parameter front_speed = 5;
parameter bird_fly_pos_y = 100;
parameter gravity = 1;

parameter new_pipe_pos_x0 = 420;
// parameter new_pipe_pos_x = 500;
parameter new_pipe_pos_y = 480;

wire signed [15:0] new_pipe_pos_x;

parameter START = 0;
parameter READY = 1;
parameter FLY   = 2;
parameter OVER  = 3;

reg  signed [15:0] bird_fly_pos_x;
reg  signed [15:0] bird_fly_spd_x;
reg  signed [ 7:0] bird_fly_angle;
wire signed [ 7:0] bird_fly_angle_spd;

reg  new_frame2;
always @(posedge clk) begin
    if (~rstn) begin
        new_frame2 <= 0;
    end else begin
        new_frame2 <= new_frame;
    end
end

reg  button_flag;
always @(posedge clk) begin
    if (~rstn) begin
        button_flag <= 0;
    end else if (button_pulse) begin
        button_flag <= 1;
    end else if (new_frame2) begin
        button_flag <= 0;
    end
end

reg [3:0] game_status;
reg [3:0] game_status_next;
wire game_start;
wire game_ready;
wire game_fly;
wire game_over;

reg  [7:0] game_over_shake_count;
wire game_over_shake_after;

always @(posedge clk) begin
    if (~rstn) begin
        game_over_shake_count <= 0;
    end else if (game_over) begin
        if (new_frame && game_over_shake_count != 60) begin
            game_over_shake_count <= game_over_shake_count + 1;
        end
    end else begin
        game_over_shake_count <= 0;
    end
end
assign game_over_shake_after = game_over_shake_count == 60;

wire bird_dead;

always @(posedge clk) begin
    if (~rstn) begin
        game_status <= 0;
    end else if (new_frame) begin
        game_status <= game_status_next;
    end
end

assign game_start   = game_status[START];
assign game_ready   = game_status[READY];
assign game_fly     = game_status[FLY];
assign game_over    = game_status[OVER];

always @(*) begin
    game_status_next = 0;
    if (game_start) begin
        if (button_flag) begin
            game_status_next[READY] = 1;
        end else begin
            game_status_next[START] = 1;
        end
    end else if (game_ready) begin
        if (button_flag) begin
            game_status_next[FLY] = 1;
        end else begin
            game_status_next[READY] = 1;
        end
    end else if (game_fly) begin
        // if (button_flag) begin
        if (bird_dead) begin
            game_status_next[OVER] = 1;
        end else begin
            game_status_next[FLY] = 1;
        end
    end else if (game_over) begin
        if (button_flag && game_over_shake_after) begin
            game_status_next[START] = 1;
        end else begin
            game_status_next[OVER] = 1;
        end
    end else begin
        game_status_next[START] = 1;
    end
end

reg [5:0] flap_count1;
reg [3:0] flap_count2;
always @(posedge clk) begin
    if (~rstn) begin
        flap_count1 <= 0;
        flap_count2 <= 0;
        bird_status <= 0;
    end if (new_frame2) begin
        flap_count1 <= (flap_count1 == 5)? 0 : flap_count1 + 1;
        if (flap_count1 == 5) begin 
            flap_count2 <= (flap_count2 == 3)? 0 : flap_count2 + 1;
        end
        if (!game_over) begin
            if (flap_count2 == 0) begin
                bird_status <= 2'b00;
            end else if (flap_count2 == 2) begin
                bird_status <= 2'b10;
            end else begin
                bird_status <= 2'b01;
            end
        end
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        stage_shift <= 0;
    end else if (new_frame2 && !game_over) begin
        if (stage_shift + front_speed > 27) begin
            stage_shift <= stage_shift + front_speed - 28;
        end else begin
            stage_shift <= stage_shift + front_speed;
        end
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        bird_pos_x <= 0;
        bird_pos_y <= 0;
        bird_angle <= 0;
    end else if (new_frame2) begin
        if (game_start) begin
            bird_pos_x <= 420;
            bird_pos_y <= 206;
            bird_angle <= 0;
        end else if (game_ready) begin
            bird_pos_x <= 420;
            bird_pos_y <= 100;
            bird_angle <= 0;
        end else begin
            bird_pos_x <= bird_fly_pos_x;
            bird_pos_y <= bird_fly_pos_y;
            bird_angle <= bird_fly_angle;
        end
    end
end

assign bird_fly_angle_spd = (bird_fly_spd_x >> 3) * 3;

always @(posedge clk) begin
    if (~rstn) begin
        bird_fly_pos_x <= 0;
        bird_fly_spd_x <= 0;
        bird_fly_angle <= 0;
    end else if (new_frame2) begin
        if (game_ready) begin
            bird_fly_pos_x <= 420;
            bird_fly_spd_x <= 0;
            bird_fly_angle <= 0;
        end else if (game_fly || game_over) begin
        // end else if (game_fly) begin
            if (game_fly && button_flag) begin
                bird_fly_spd_x <= 13;
            end else begin
                bird_fly_spd_x <= bird_fly_spd_x - gravity;
            end

            if (game_fly && button_flag) begin
                if (bird_fly_angle < 0) begin
                    bird_fly_angle <= 0;
                end
            end else if (bird_fly_angle + bird_fly_angle_spd > 20) begin
                bird_fly_angle <= 20;
            end else if (bird_fly_angle + bird_fly_angle_spd < -60) begin
                bird_fly_angle <= -60;
            end else begin
                bird_fly_angle <= bird_fly_angle + bird_fly_angle_spd;
            end

            if (bird_fly_pos_x + bird_fly_spd_x > 728) begin
                bird_fly_pos_x <= 728;
            end else if (bird_fly_pos_x + bird_fly_spd_x < 104) begin
                bird_fly_pos_x <= 104;
                bird_fly_spd_x <= 0;
            end else begin
                bird_fly_pos_x <= bird_fly_pos_x + bird_fly_spd_x;
            end
        end
    end
end

wire [7:0] random;
random u_random(
    .clk    (clk),
    .rstn   (rstn),
    .random (random)
);

assign new_pipe_pos_x = new_pipe_pos_x0 + {8'd0, random};

reg [15:0] pipe_count;
wire new_pipe;
assign new_pipe = pipe_count == 0;
always @(posedge clk) begin
    if (~rstn) begin
        pipe_count <= 0;
    end else if (new_frame) begin
        if (pipe_count == 63) begin
            pipe_count <= 0;
        end else begin
            pipe_count <= pipe_count + 1;
        end
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        pipe1_pos_x <= 0;
        pipe1_pos_y <= 0;
        pipe2_pos_x <= 0;
        pipe2_pos_y <= 0;
        pipe3_pos_x <= 0;
        pipe3_pos_y <= 0;
    end if (new_frame2) begin
        if (game_fly) begin
            if (new_pipe) begin
                pipe1_pos_x <= pipe2_pos_x;
                pipe1_pos_y <= pipe2_pos_y - front_speed;
                pipe2_pos_x <= pipe3_pos_x;
                pipe2_pos_y <= pipe3_pos_y - front_speed;
                pipe3_pos_x <= new_pipe_pos_x;
                pipe3_pos_y <= new_pipe_pos_y;
            end else begin
                pipe1_pos_y <= pipe1_pos_y - front_speed;
                pipe2_pos_y <= pipe2_pos_y - front_speed;
                pipe3_pos_y <= pipe3_pos_y - front_speed;
            end
        end else if (!game_over) begin
            pipe1_pos_x <= 680;
            pipe2_pos_x <= 500;
            pipe3_pos_x <= 450;
            pipe1_pos_y <= -120;
            pipe2_pos_y <= -120;
            pipe3_pos_y <= -120;
        end
    end
end

wire bird_dead_x2;
wire bird_dead_y2;
wire bird_dead_ground;

assign bird_dead_x2 = pipe2_pos_x - bird_pos_x > 220 || pipe2_pos_x - bird_pos_x < 80;
assign bird_dead_y2 = pipe2_pos_y - bird_fly_pos_y <= 60 && pipe2_pos_y - bird_fly_pos_y >= -96;
assign bird_dead_ground = bird_pos_x <= 104;

assign bird_dead = 
    (bird_dead_x2 && bird_dead_y2) || 
    bird_dead_ground;

always @(posedge clk) begin
    if (~rstn) begin
        logo_enable <= 0;
        ready_enable <= 0;
        over_enable <= 0;
    end else if (new_frame2) begin
        logo_enable <= game_start;
        ready_enable <= game_ready;
        over_enable <= game_over;
    end
end

endmodule
