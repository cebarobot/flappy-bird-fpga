module game(
    input   clk,
    input   rstn,

    input   button_pulse,
    input   new_frame,

    output reg [7:0] stage_shift,

    output reg [1:0] bird_status,

    output reg signed [15:0] pipe1_pos_x,
    output reg signed [15:0] pipe1_pos_y,
    output reg signed [15:0] pipe2_pos_x,
    output reg signed [15:0] pipe2_pos_y,
    output reg signed [15:0] pipe3_pos_x,
    output reg signed [15:0] pipe3_pos_y,

    output reg signed [15:0] bird_pos_x,
    output reg signed [15:0] bird_pos_y,
    output reg signed [ 7:0] bird_angle
);

always @(*) begin
    stage_shift = 0;

    pipe1_pos_x = 680;
    pipe1_pos_y = -50;
    pipe2_pos_x = 500;
    pipe2_pos_y = 150;
    pipe3_pos_x = 450;
    pipe3_pos_y = 350;

    // bird_pos_x = 400;
    // bird_pos_y = 240;
    // bird_angle = 8'd10;
end

parameter speed = 5;

parameter START = 0;
parameter READY = 1;
parameter FLY   = 2;
parameter OVER  = 3;

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

wire dead = 0;

always @(posedge clk) begin
    if (~rstn) begin
        game_status <= 0;
    end else begin
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
        if (button_flag) begin
        // if (dead) begin
            game_status_next[OVER] = 1;
        end else begin
            game_status_next[FLY] = 1;
        end
    end else if (game_over) begin
        if (button_flag) begin
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
    end if (new_frame) begin
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
        bird_pos_x <= 0;
        bird_pos_y <= 0;
        bird_angle <= 0;
    end else if (new_frame2) begin
        if (game_start) begin
            bird_pos_x <= 600;
            bird_pos_y <= 380;
            bird_angle <= 0;
        end else if (game_ready) begin
            bird_pos_x <= 400;
            bird_pos_y <= 100;
            bird_angle <= 0;
        end else begin
            bird_pos_x <= 128;
            bird_pos_y <= 100;
            bird_angle <= -64;
        end
    end
end

endmodule