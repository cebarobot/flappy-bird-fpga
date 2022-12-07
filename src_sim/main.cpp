#include <iostream>
#include <memory>
#include <SDL2/SDL.h>

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"

VerilatedContext * context_p = NULL;
Vtop * top = NULL;
VerilatedVcdC * trace_p = NULL;

SDL_Window* sdl_window = NULL;
SDL_Renderer * sdl_renderer = NULL;
SDL_Texture * sdl_texture = NULL;

uint16_t* frame_pixels = NULL;

const int h_res = 480;
const int v_res = 800;

void verilator_init(int argc, char** argv) {
    Verilated::mkdir("logs");
    context_p = new VerilatedContext;
    top = new Vtop{context_p, "TOP"};

    #ifdef TRACE_WAVE
        trace_p = new VerilatedVcdC;
        context_p->traceEverOn(true);
        top->trace(trace_p, 99);
        trace_p->open("logs/vlt_dump.vcd");
    #endif

    context_p->commandArgs(argc, argv);
}

void verilator_exit() {
    top->final();
    #ifdef TRACE_WAVE
        trace_p->close();
    #endif

    delete context_p;
    delete top;

    #ifdef TRACE_WAVE
        delete trace_p;
    #endif
}

void sdl_init() {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL init failed: " << SDL_GetError() << std::endl;
        exit(-1);
    }
    
    sdl_window = SDL_CreateWindow("Flappy Bird on FPGA", SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED, h_res, v_res, SDL_WINDOW_SHOWN);
    if (!sdl_window) {
        std::cerr << "Windows creation failed: " << SDL_GetError() << std::endl;
        exit(-1);
    }

    sdl_renderer = SDL_CreateRenderer(sdl_window, -1, 
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!sdl_renderer) {
        std::cerr << "Renderer creation failed: " << SDL_GetError() << std::endl;
        exit(-1);
    }

    sdl_texture = SDL_CreateTexture(sdl_renderer, SDL_PIXELFORMAT_RGB565,
        SDL_TEXTUREACCESS_TARGET, h_res, v_res);
    if (!sdl_texture) {
        std::cerr << "Texture creation failed: " << SDL_GetError() << std::endl;
        exit(-1);
    }

    frame_pixels = new uint16_t[h_res * v_res];
}

void sdl_exit() {
    SDL_DestroyTexture(sdl_texture);
    SDL_DestroyRenderer(sdl_renderer);
    SDL_DestroyWindow(sdl_window);
    SDL_Quit();
    delete frame_pixels;
}

void sdl_update() {
    static int cur_x = 0;
    static int cur_y = 0;
    static int last_hsync = 0;
    static int last_vsync = 0;

    if (top->vga_de) {
        uint16_t cur_pixel = (
            (top->vga_r << 11) |
            (top->vga_g << 5 ) |
            (top->vga_b << 0 )
        );
        if (cur_x < v_res && cur_y < h_res) {
            frame_pixels[cur_y + (v_res - cur_x - 1) * h_res] = cur_pixel;
        }
        cur_x += 1;
    }

    if (last_hsync && !top->vga_hsync) {
        cur_x = 0;
        cur_y += 1;
    }
    if (last_vsync && !top->vga_vsync) {
        cur_x = 0;
        cur_y = 0;

        SDL_UpdateTexture(sdl_texture, NULL, frame_pixels, h_res * sizeof(uint16_t));
        SDL_RenderClear(sdl_renderer);
        SDL_RenderCopy(sdl_renderer, sdl_texture, NULL, NULL);
        SDL_RenderPresent(sdl_renderer);
    }

    last_hsync = top->vga_hsync;
    last_vsync = top->vga_vsync;
}

int main(int argc, char** argv, char** env) {

    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    verilator_init(argc, argv);
    sdl_init();

    top->clk_in = 0;
    top->resetn = !0;

    // Simulate
    while (!context_p->gotFinish()) {

        context_p->timeInc(1);
        if (context_p->time() % 1 == 0) {
            top->clk_in = !top->clk_in;
        }
        
        // reset
        if (context_p->time() > 1 && context_p->time() < 8) {
            top->resetn = !1;  // Assert reset
        } else {
            top->resetn = !0;  // Deassert reset
        }

        // Evaluate model
        top->eval();

        #ifdef TRACE_WAVE
            trace_p->dump(context_p->time());
        #endif

        if (!top->clk_in) {
            sdl_update();
        }
    }
    
    // Coverage analysis
    context_p->coveragep()->write("logs/coverage.dat");

    sdl_exit();
    verilator_exit();

    return 0;
}
