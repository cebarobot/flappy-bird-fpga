#include <iostream>
#include <memory>

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"

int main(int argc, char** argv, char** env) {

    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");

    // Construct context class
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    // Construct the Verilated model
    const std::unique_ptr<Vtop> top{new Vtop{contextp.get(), "TOP"}};
    // Construct trace save object
    const std::unique_ptr<VerilatedVcdC> trace_p{new VerilatedVcdC};

    // Set debug level, 0 is off, 9 is highest presently used
    contextp->debug(0);

    // Randomization reset policy
    contextp->randReset(2);

    // Verilator must compute traced signals
    contextp->traceEverOn(true);
    top->trace(trace_p.get(), 99);
    trace_p->open("logs/vlt_dump.vcd");

    contextp->commandArgs(argc, argv);

    // inital value of signals
    top->clk_in = 0;
    top->resetn = !0;

    // Simulate until $finish
    while (!contextp->gotFinish()) {

        contextp->timeInc(1);  // 1 timeprecision period passes...

        if (contextp->time() % 1 == 0) {
            top->clk_in = !top->clk_in;
        }
        
        // reset
        if (contextp->time() > 1 && contextp->time() < 8) {
            top->resetn = !1;  // Assert reset
        } else {
            top->resetn = !0;  // Deassert reset
        }

        // Evaluate model
        top->eval();
        trace_p->dump(contextp->time());
    }
    
    // Coverage analysis (calling write only after the test is known to pass)
    contextp->coveragep()->write("logs/coverage.dat");

    // Final model cleanup
    top->final();
    trace_p->close();

    return 0;
}
