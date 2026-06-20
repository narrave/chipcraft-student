# ChipCraft Lab — Verilog compile & simulate
#
# Usage (from any directory):
#   make                   – compile + simulate (all files with testbench)
#   make wave              – compile + simulate + open GTKWave
#   make compile           – compile only
#   make sim               – run simulation only (after compile)
#   make run FILE=counter  – compile + simulate a single file
#   make counter           – compile + simulate counter.v directly
#   make clean             – remove build outputs
#
# LABS can be overridden: make LABS=~/mydir

# Directory where decrypted .v files live (tmpfs)
LABS    ?= $(HOME)/labs

# Single-file variable (for: make run FILE=counter)
FILE    ?= counter

# Auto-detect the testbench and all design files inside LABS
TB      := $(firstword $(wildcard $(LABS)/tb_*.v))
TOP     := $(basename $(notdir $(TB)))
SRCS    := $(wildcard $(LABS)/*.v)
SIM_OUT := $(LABS)/sim.vvp
VCD     := $(LABS)/$(patsubst tb_%.v,%.vcd,$(notdir $(TB)))

# Colour helpers
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RESET  := \033[0m

.PHONY: all compile sim wave run clean

all: compile sim

compile: $(SIM_OUT)

$(SIM_OUT): $(SRCS)
	@echo "$(GREEN)Compiling: $(notdir $(SRCS))$(RESET)"
	iverilog -g2012 -Wall -o $(SIM_OUT) $(SRCS)
	@echo "$(GREEN)Done — run 'make sim' to simulate$(RESET)"

sim: $(SIM_OUT)
	@echo "$(YELLOW)Running simulation …$(RESET)"
	vvp $(SIM_OUT)
	@echo "$(GREEN)Simulation complete.$(RESET)"
	@[ -f $(VCD) ] && echo "$(GREEN)Waveform: $(notdir $(VCD))  →  run 'make wave' to open GTKWave$(RESET)" || true

wave: sim
	@echo "$(YELLOW)Opening GTKWave …$(RESET)"
	gtkwave $(VCD) &

# Single-file: make run FILE=counter
run:
	@echo "$(GREEN)Compiling: $(FILE).v$(RESET)"
	iverilog -g2012 -Wall -o $(LABS)/$(FILE).vvp $(LABS)/$(FILE).v
	@echo "$(YELLOW)Running $(FILE) …$(RESET)"
	vvp $(LABS)/$(FILE).vvp
	@echo "$(GREEN)Done.$(RESET)"

# Pattern rule: make counter  →  compiles + runs counter.v
%: $(LABS)/%.v
	@echo "$(GREEN)Compiling: $<$(RESET)"
	iverilog -g2012 -Wall -o $(LABS)/$@.vvp $<
	@echo "$(YELLOW)Running $@ …$(RESET)"
	vvp $(LABS)/$@.vvp
	@echo "$(GREEN)Done.$(RESET)"

clean:
ifdef FILE
	rm -f $(LABS)/$(FILE).vvp $(LABS)/$(FILE).vcd
	@echo "Cleaned $(FILE)."
else
	rm -f $(SIM_OUT) $(LABS)/*.vcd $(LABS)/*.vvp
	@echo "Cleaned."
endif
