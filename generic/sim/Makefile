################################################################################
## Copyright (c) 2024 Teodor Dimitrov
## All rights reserved.
## 
## This file is dual-licensed under:
## 1. Open-source license: [GPL v3] (See LICENSE file)
## 2. Commercial license: Contact teodorpd@gmail.com for details.
################################################################################

ESC:=$(shell printf '\033')
GREEN:=$(ESC)[1;32m
RED:=$(ESC)[1;31m
HL:=$(ESC)[0;33m
NC:=$(ESC)[0m

CLEAN_TARGET += *.cache
CLEAN_TARGET += *.data
CLEAN_TARGET += *.xpr
CLEAN_TARGET += *.log
CLEAN_TARGET += *.jou
CLEAN_TARGET +=  xgui
CLEAN_TARGET +=  gui
CLEAN_TARGET += *.runs
CLEAN_TARGET += *.srcs
CLEAN_TARGET += *.sdk
CLEAN_TARGET += *.hw
CLEAN_TARGET += *.sim
CLEAN_TARGET += .Xil
CLEAN_TARGET += *.ip_user_files
CLEAN_TARGET += *.str
CLEAN_TARGET += *.txt
CLEAN_TARGET += *.csv
CLEAN_TARGET += *.hbs
CLEAN_TARGET += *.gen
CLEAN_TARGET += *.bit
CLEAN_TARGET += *.xsa
CLEAN_TARGET += *.ltx
CLEAN_TARGET += *.mif
CLEAN_TARGET += *.tmp
CLEAN_TARGET += component.xml
CLEAN_TARGET += *.debug
CLEAN_TARGET += *.dcp
CLEAN_TARGET += *.mem
CLEAN_TARGET += *.pb
CLEAN_TARGET += *.wdb
CLEAN_TARGET += xsim.dir

SIM_SWITCH := --t
GUI := 0


.PHONY: clean gui 

all: results_tb_sync_fifo results_tb_fir_generic results_tb_safe_adder results_tb_safe_mult

clean:
	@echo "Cleaning $(HL)building blocks$(NC) simulation files ..."
	@rm -rf $(CLEAN_TARGET)
	
gui:
	$(eval GUI := 1)

#####################################################################################
## sync_fifo
#####################################################################################
xsim.dir/work/tb_sync_fifo.sdb: tb/tb_sync_fifo.sv
	@echo -n "Compile testbench $(HL)tb_sync_fifo$(NC) ... "; 
	@if xvlog -sv tb/tb_sync_fifo.sv > tb_sync_fifo_compile.log; then \
	    echo " $(GREEN)OK$(NC)"; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/tb_sync_fifo_compile.log$(NC)"; \
	    exit 1; \
	fi;
	
xsim.dir/work/sync_fifo.sdb: ../rtl/sync_fifo.v
	@echo -n "Compile module $(HL)sync_fifo$(NC) ... "
	@if xvlog ../rtl/sync_fifo.v > sync_fifo_compile.log; then \
		echo " $(GREEN)OK$(NC)"; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/sync_fifo_compile.log$(NC)"; \
	    exit 1; \
	fi;
	
elab_tb_sync_fifo: xsim.dir/work/sync_fifo.sdb xsim.dir/work/tb_sync_fifo.sdb
	@echo -n "Elaborate $(HL)tb_sync_fifo$(NC) ... "
	@if xelab --relax --debug all tb_sync_fifo > tb_sync_fifo_elab.log; then \
	    echo " $(GREEN)OK$(NC)"; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/tb_sync_fifo_elab.log$(NC)"; \
	    exit 1; \
	fi;

sim_tb_sync_fifo: clean elab_tb_sync_fifo
	@echo -n "Run simulation for $(HL)tb_sync_fifo$(NC) ... "
	@xsim tb_sync_fifo $(SIM_SWITCH) sim_tb_sync_fifo.tcl > tb_sync_fifo_sim.log
	@if [ $(GUI) -eq "1" ]; then \
		echo "LAUNCH WAVEFORM VIEWER"; \
		xsim work.tb_sync_fifo.wdb --gui; \
	fi;

results_tb_sync_fifo: sim_tb_sync_fifo
	@if [ $(file < result_sync_fifo.txt) -eq "0" ]; then \
	    echo " $(GREEN)OK$(NC)"; \
	    exit 0; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/tb_sync_fifo_sim.log$(NC)"; \
	    exit 1; \
	fi;
#####################################################################################
## ES FIR FILTER
#####################################################################################
xsim.dir/work/tb_fir_generic.sdb: tb/tb_fir_generic.sv
	@echo -n "Compile testbench $(HL)tb_fir_generic$(NC) ... "; 
	@if xvlog -sv tb/tb_fir_generic.sv > tb_fir_generic_compile.log; then \
	    echo " $(GREEN)OK$(NC)"; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/tb_fir_generic_compile.log$(NC)"; \
	    exit 1; \
	fi;
	
xsim.dir/work/fir_generic.sdb: ../rtl/fir_generic.v ../rtl/safe_adder.v ../rtl/safe_mult.v
	@echo -n "Compile module $(HL)fir_generic$(NC) ... "
	@if xvlog ../rtl/fir_generic.v ../rtl/safe_adder.v ../rtl/safe_mult.v > fir_generic_compile.log; then \
		echo " $(GREEN)OK$(NC)"; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/fir_generic_compile.log$(NC)"; \
	    exit 1; \
	fi;
	
elab_tb_fir_generic: xsim.dir/work/fir_generic.sdb xsim.dir/work/tb_fir_generic.sdb
	@echo -n "Elaborate $(HL)tb_fir_generic$(NC) ... "
	@if xelab --relax --debug all tb_fir_generic > tb_fir_generic_elab.log; then \
	    echo " $(GREEN)OK$(NC)"; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/tb_fir_generic_elab.log$(NC)"; \
	    exit 1; \
	fi;

sim_tb_fir_generic: clean elab_tb_fir_generic
	@echo -n "Run simulation for $(HL)tb_fir_generic$(NC) ... "
	@xsim tb_fir_generic $(SIM_SWITCH) sim_tb_fir_generic.tcl > tb_fir_generic_sim.log
	@if [ $(GUI) -eq "1" ]; then \
		echo "LAUNCH WAVEFORM VIEWER"; \
		xsim work.tb_fir_generic.wdb --gui; \
	fi;

results_tb_fir_generic: sim_tb_fir_generic
	@if [ $(file < result_fir_filter.txt) -eq "0" ]; then \
	    echo " $(GREEN)OK$(NC)"; \
	    exit 0; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/tb_fir_generic_sim.log$(NC)"; \
	    exit 1; \
	fi;

#####################################################################################
## ES ADDER
#####################################################################################
xsim.dir/work/tb_safe_adder.sdb: tb/tb_safe_adder.sv
	@echo -n "Compile testbench $(HL)tb_safe_adder$(NC) ... "; 
	@if xvlog -sv tb/tb_safe_adder.sv > tb_safe_adder_compile.log; then \
	    echo " $(GREEN)OK$(NC)"; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/tb_safe_adder.log$(NC)"; \
	    exit 1; \
	fi;
	
xsim.dir/work/safe_adder.sdb: ../rtl/safe_adder.v
	@echo -n "Compile module $(HL)safe_adder$(NC) ... "
	@if xvlog ../rtl/safe_adder.v > safe_adder_compile.log; then \
		echo " $(GREEN)OK$(NC)"; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/safe_adder_compile.log$(NC)"; \
	    exit 1; \
	fi;
	
elab_tb_safe_adder: xsim.dir/work/safe_adder.sdb xsim.dir/work/tb_safe_adder.sdb
	@echo -n "Elaborate $(HL)tb_safe_adder$(NC) ... "
	@if xelab --relax --debug all tb_safe_adder > tb_safe_adder_elab.log; then \
	    echo " $(GREEN)OK$(NC)"; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/tb_safe_adder_elab.log$(NC)"; \
	    exit 1; \
	fi;

sim_tb_safe_adder: clean elab_tb_safe_adder
	@echo -n "Run simulation for $(HL)tb_safe_adder$(NC) ... "
	@xsim tb_safe_adder $(SIM_SWITCH) sim_tb_safe_adder.tcl > tb_safe_adder_sim.log
	@if [ $(GUI) -eq "1" ]; then \
		echo "LAUNCH WAVEFORM VIEWER"; \
		xsim work.tb_safe_adder.wdb --gui; \
	fi;

results_tb_safe_adder: sim_tb_safe_adder
	@if [ $(file < result_adder.txt) -eq "0" ]; then \
	    echo " $(GREEN)OK$(NC)"; \
	    exit 0; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/tb_safe_adder_sim.log$(NC)"; \
	    exit 1; \
	fi;
	
#####################################################################################
## ES MULT
#####################################################################################
xsim.dir/work/tb_safe_mult.sdb: tb/tb_safe_mult.sv
	@echo -n "Compile testbench $(HL)tb_safe_mult$(NC) ... "; 
	@if xvlog -sv tb/tb_safe_mult.sv > tb_safe_mult_compile.log; then \
	    echo " $(GREEN)OK$(NC)"; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/tb_safe_mult_compile.log$(NC)"; \
	    exit 1; \
	fi;
	
xsim.dir/work/safe_mult.sdb: ../rtl/safe_mult.v
	@echo -n "Compile module $(HL)safe_mult$(NC) ... "
	@if xvlog ../rtl/safe_mult.v > safe_mult_compile.log; then \
		echo " $(GREEN)OK$(NC)"; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/safe_mult_compile.log$(NC)"; \
	    exit 1; \
	fi;
	
elab_tb_safe_mult: xsim.dir/work/safe_mult.sdb xsim.dir/work/tb_safe_mult.sdb
	@echo -n "Elaborate $(HL)tb_safe_mult$(NC) ... "
	@if xelab --relax --debug all tb_safe_mult > tb_safe_mult_elab.log; then \
	    echo " $(GREEN)OK$(NC)"; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/tb_safe_mult_elab.log$(NC)"; \
	    exit 1; \
	fi;

sim_tb_safe_mult: clean elab_tb_safe_mult
	@echo -n "Run simulation for $(HL)tb_safe_mult$(NC) ... "
	@xsim tb_safe_mult $(SIM_SWITCH) sim_tb_safe_mult.tcl > tb_safe_mult_sim.log
	@if [ $(GUI) -eq "1" ]; then \
		echo "LAUNCH WAVEFORM VIEWER"; \
		xsim work.tb_safe_mult.wdb --gui; \
	fi;

results_tb_safe_mult: sim_tb_safe_mult
	@if [ $(file < result_mult.txt) -eq "0" ]; then \
	    echo " $(GREEN)OK$(NC)"; \
	    exit 0; \
	else \
	    echo " $(RED)FAILED$(NC)"; \
	    echo "For details see $(HL)$(CURDIR)/tb_safe_mult_sim.log$(NC)"; \
	    exit 1; \
	fi;
