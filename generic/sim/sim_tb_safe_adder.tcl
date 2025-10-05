# ------------------------------------------------------------------------------
# Project Name: psk-mod-ip
# File: sim_tb_safe_adder.tcl
# Description: Simulation launch script for tb_safe_adder.sv
#              testbench.
# 
# Copyright (c) 2024 Teodor Dimitrov
# All rights reserved.
# 
# This file is dual-licensed under:
# 1. Open-source license: [GPL v3] (See LICENSE file)
# 2. Commercial license: Contact teodorpd@gmail.com for details.
# ------------------------------------------------------------------------------

create_wave_config tb_safe_adder.wcfg

# Probe all signals recursively
add_wave -recursive tb_safe_adder

run all

###################################
## Check Results
###################################
if {[catch {set error_count [get_value -radix dec [get_scopes /]/error_count]} result]} {
    puts "\n\nERROR: Testbench MUST have a single top instance with an \"error_count\" signal in it.\n\n"
    exit 2
}

###################################
## Check Results
###################################
# Get the current directory where the script is located
set script_directory [file dirname [info script]]

# Create the file path for the "result" file in the same directory
set result_file [file join $script_directory "result_adder.txt"]

# Open the file for writing
set file_id [open $result_file "w"]

# Write the value of $error_count to the file
puts $file_id $error_count

# Close the file
close $file_id

exec ls

exit
