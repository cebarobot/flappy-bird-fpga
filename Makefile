# BASED ON Verilator Example Makefile

######################################################################
# Check for sanity to avoid later confusion
ifneq ($(words $(CURDIR)),1)
 $(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

######################################################################
# Set up variables

# If $VERILATOR_ROOT isn't in the environment, we assume it is part of a
# package install, and verilator is in your path. Otherwise find the
# binary relative to $VERILATOR_ROOT (such as when inside the git sources).
ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
VERILATOR_COVERAGE = verilator_coverage
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
VERILATOR_COVERAGE = $(VERILATOR_ROOT)/bin/verilator_coverage
endif

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe
# Generate makefile dependencies (enabled for --cc or --sc modes by default)
#VERILATOR_FLAGS += -MMD
# Optimize
VERILATOR_FLAGS += -Os -x-assign 0
# Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wall -Wno-UNUSED
# Make waveforms
VERILATOR_FLAGS += --trace
# Check SystemVerilog assertions
VERILATOR_FLAGS += --assert
# Generate coverage analysis
VERILATOR_FLAGS += --coverage
# Run Verilator in debug mode
#VERILATOR_FLAGS += --debug
# Add this trace to get a backtrace in gdb
#VERILATOR_FLAGS += --gdbbt
# Include directories for Verilator
VERILATOR_FLAGS += -y src_hw/shell
VERILATOR_FLAGS += -y src_hw/core
VERILATOR_FLAGS += -y src_hw/include
VERILATOR_FLAGS += -y src_tb

# Input files for Verilator
VERILATOR_INPUT = src/top.v src_sim/main.cpp

######################################################################
default: all

all: verilate build run

verilate:
	@echo
	@echo "-- VERILATE ----------------"
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT)

lint:
	@echo
	@echo "-- VERILATE LINT -----------"
	$(VERILATOR) --lint-only $(VERILATOR_FLAGS) $(VERILATOR_INPUT)

build:
	@echo
	@echo "-- BUILD -------------------"
# To compile, we can either
# 1. Pass --build to Verilator by editing VERILATOR_FLAGS above.
# 2. Or, run the make rules Verilator does:
	$(MAKE) -j -C obj_dir -f Vtop.mk
# 3. Or, call a submakefile where we can override the rules ourselves:
#	$(MAKE) -j -C obj_dir -f ../obj.mk

run:
	@echo
	@echo "-- RUN ---------------------"
	@rm -rf logs
	@mkdir -p logs
	obj_dir/Vtop +trace

coverage:
	@echo
	@echo "-- COVERAGE ----------------"
	@rm -rf logs/annotated
	$(VERILATOR_COVERAGE) --annotate logs/annotated logs/coverage.dat

######################################################################
# Other targets

wave:
	gtkwave logs/vlt_dump.vcd -a wave.gtkw

help:
	@echo "-- Make help for Flappy Bird on FPGA --"
	@echo "    help:     show help"
	@echo "    verilate: Convert Verilog to C++"
	@echo "    build:    Compile C++ program"
	@echo "    run:      Run simulation"
	@echo "    all:      verilate, build & run"

show-config:
	$(VERILATOR) -V

maintainer-copy::
clean mostlyclean distclean maintainer-clean::
	-rm -rf obj_dir logs *.log *.dmp *.vpd coverage.dat core
