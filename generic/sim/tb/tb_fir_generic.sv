`timescale 1ns / 1ps
// ------------------------------------------------------------------------------
// Project Name: psk-mod-ip
// File: tb_fir_generic.sv
// Description: Block level testbench for fir_generic.v
// 
// Copyright (c) 2024 Teodor Dimitrov
// All rights reserved.
// 
// This file is dual-licensed under:
// 1. Open-source license: [GPL v3] (See LICENSE file)
// 2. Commercial license: Contact teodorpd@gmail.com for details.
// ------------------------------------------------------------------------------

module tb_fir_generic(

    );
    
    parameter CLK_PERIOD = 4.00;
    parameter TAPS = 26;
    parameter DATA_WIDTH = 16;
    parameter DATA_FRAC_WIDTH = 14;
    
    logic tb_clk = 0;
    logic tb_rst = 1;

    logic [31:0] error_count = 0;
    
    genvar i;
    
    logic signed [DATA_WIDTH - 1:0] test_data = 0;
    logic                           sample_test_data = 0;
    logic signed [DATA_WIDTH - 1:0] filtered_data;
    logic                           filtered_data_valid;
    
    
    
    //parameter [DATA_WIDTH - 1:0] coeff [TAPS-1:0] = {-33, 57, 214, 124}; // Coefficients from highest order to lowest order
    parameter [DATA_WIDTH - 1:0] coeff [TAPS-1:0] = {0, -4, -2, 2, 2, -3, -4, 5, 6, -8, -11, 19, 57, 57, 19, -11, -8, 6, 5, -4, -3, 2, 2, -2, -4, 0}; // Coefficients from highest order to lowest order
 
                                                     
    logic signed [DATA_WIDTH*TAPS - 1 : 0] coeff_vector;
        
   for (i = 1; i <= TAPS; i = i + 1)
      begin
          assign coeff_vector[i*DATA_WIDTH-1 : (i-1)*DATA_WIDTH] = coeff[i-1];
      end
    
    fir_generic #(
        .INPUT_DATA_WIDTH       (DATA_WIDTH),
        .INPUT_DATA_FRAC_WIDTH  (DATA_FRAC_WIDTH),
        .OUTPUT_DATA_WIDTH      (DATA_WIDTH),
        .OUTPUT_DATA_FRAC_WIDTH (DATA_FRAC_WIDTH),
        .FILTER_TAPS            (TAPS)
    ) inst_fir_filter (
        .clk          (tb_clk),
        .rst          (tb_rst),
        .coeff_vector (coeff_vector),
        
        .data_in      (test_data),
        .sample_en    (sample_test_data),
        .data_out     (filtered_data),
        .sample_valid (filtered_data_valid)
    );
    
    
    always @ (posedge tb_clk)
      begin
          if (tb_rst)
            begin
                sample_test_data <= 1'b0;
            end
          else
            begin
                sample_test_data <= ~sample_test_data;
            end
      end
    
    
    initial
      begin
          #20 tb_rst <= 1'b0;
      end
    
    initial 
      begin
          forever #(CLK_PERIOD/2) tb_clk <= ~tb_clk;  
      end
      
      
    initial
      begin
          $display("Begin simulation tb_fir_filter");
          wait(tb_rst == 1'b0);
          @ (posedge tb_clk);
          test_data = 10000;
          @ (posedge tb_clk);
          test_data = 0;
          
          #1000;      
          // TALLY UP COUNTED ERRORS
          if (error_count == 32'h0000_0000)
            begin
                $display("##########################");
                $display("## TEST CASE SUCCESSFUL ##");
                $display("##########################");
            end
          else 
            begin
                $display("######################");
                $display("## TEST CASE FAILED ##");
                $display("######################");
                $display("Number of failures: %0d", error_count);
            end
      $finish;
      end
endmodule
