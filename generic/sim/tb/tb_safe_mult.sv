`timescale 1ns / 1ps
// ------------------------------------------------------------------------------
// Project Name: psk-mod-ip
// File: tb_safe_mult.sv
// Description: Block level testbench for safe_mult.v
// 
// Copyright (c) 2024 Teodor Dimitrov
// All rights reserved.
// 
// This file is dual-licensed under:
// 1. Open-source license: [GPL v3] (See LICENSE file)
// 2. Commercial license: Contact teodorpd@gmail.com for details.
// ------------------------------------------------------------------------------

module tb_safe_mult(

    );
    
    parameter CLK_PERIOD   = 4;
    logic tb_clk = 0;
    
   // Equal widths, equal fractionals
    logic [12:0] A1; // Q(13,8)
    logic [12:0] B1; // Q(13,8)
    logic [12:0] Q1; // Q(13,8)
    logic        ovfl1;
    
    // A_int = B_int, A_FRAC > B_FRAC
    logic [12:0] A3; // Q(13,8)
    logic [10:0] B3; // Q(11,8)
    logic [12:0] Q3; // Q(13,8)
    logic        ovfl3;
    
    // A_int = B_int, A_FRAC < B_FRAC
    logic [15:0] A4; // Q(16,10)
    logic [17:0] B4; // Q(18,12)
    logic [19:0] Q4; // Q(20,14)
    logic        ovfl4;
    
    // A_int > B_int, A_FRAC = B_FRAC
    logic [14:0] A5; // Q(15,10)
    logic [12:0] B5; // Q(13,10)
    logic [13:0] Q5; // Q(14,10)
    logic        ovfl5;
    
    // A_int < B_int, A_FRAC = B_FRAC
    logic [12:0] A6; // Q(13,10)
    logic [14:0] B6; // Q(15,10)
    logic [13:0] Q6; // Q(14,10)
    logic        ovfl6;
    
    // A_int > B_int, A frac > B frac
    logic [16:0] A7; // Q(17,12)
    logic [9:0]  B7; // Q(10,5)
    logic [10:0] Q7; // Q(11,6)
    logic        ovfl7;
    
    // A_int > B_int, A_FRAC < B_FRAC
    logic [16:0] A8; // Q(17,8)
    logic [11:0] B8; // Q(12,10)
    logic [18:0] Q8; // Q(19,12)
    logic        ovfl8;
    
    // A_int < B_int, A_FRAC < B_FRAC
    logic [7:0]  A9; // Q(8,3)
    logic [12:0] B9; // Q(13,8)
    logic [14:0] Q9; // Q(15,10)
    logic        ovfl9;
    
    // A_int < B_int > A_FRAC > B_FRAC
    logic [14:0] A10; // Q(15,12)
    logic [14:0] B10; // Q(15,8)
    logic [9:0]  Q10; // Q(10,5)
    logic        ovfl10;
    
    // TB Signals
    logic [31:0] error_count = 0;
    logic op1_done = 0;
    logic op2_done = 0;
    logic op3_done = 0;
    
    logic overflow;
    
    
  
//-------------------------------------------
// Equal Widths, Equal fractionals
//-------------------------------------------
    safe_mult #(
        .A_WIDTH (13), // A total width
        .A_FRAC  (8), // A fractional width
        .B_WIDTH (13), // B total width
        .B_FRAC  (8), // B fractional width
        .Q_WIDTH (13), // Q total width
        .Q_FRAC  (8)  // Q fractional width
    ) inst_safe_mult1 (
        .A        (A1),
        .B        (B1),
        
        .Q        (Q1),
        .overflow (ovfl1)
    );
    
    // Multiplier 1
    initial
      begin
          A1 = 13'h0200; // 2
          B1 = 13'h0300; // 3
          #100ns;
          
          A1 = 13'h0200; // 2
          B1 = 13'h1d00; // -3
          #100ns;
          
          // Overflow
          A1 = 13'h0920; // 9.125
          B1 = 13'h0920; // -9.125
          #100ns;
          
      end
      
//-------------------------------------------
// A_int = B_int, A_FRAC > B_FRAC
//-------------------------------------------
    safe_mult #(
        .A_WIDTH (13), // A total width
        .A_FRAC  (8), // A fractional width
        .B_WIDTH (11), // B total width
        .B_FRAC  (6), // B fractional width
        .Q_WIDTH (13), // Q total width
        .Q_FRAC  (8)  // Q fractional width
    ) inst_safe_mult3 (
        .A        (A3),
        .B        (B3),
        
        .Q        (Q3),
        .overflow (ovfl3)
    );
    
    // Multiplier 3
    initial
      begin
          A3 = 13'h0280; // 2.5
          B3 = 11'h0f1;  // 3.7656
          #100ns;
          
          A3 = 13'h0280; // 2.5
          B3 = 11'h70f;  // -3.7656
          #100ns;
          
          // Overflow
          A3 = 13'h04c9; // 4.7865
          B3 = 11'h0dc;  // 3.4375
          #100ns;
          
      end  
      
//-------------------------------------------
// A_int = B_int, A_FRAC < B_FRAC
//-------------------------------------------
    safe_mult #(
        .A_WIDTH (16), // A total width
        .A_FRAC  (10), // A fractional width
        .B_WIDTH (18), // B total width
        .B_FRAC  (12), // B fractional width
        .Q_WIDTH (20), // Q total width
        .Q_FRAC  (14) // Q fractional width
    ) inst_safe_mult4 (
        .A        (A4),
        .B        (B4),
        
        .Q        (Q4),
        .overflow (ovfl4)
    );
    
    // Multiplier 4
    initial
      begin
          A4 = 16'h0a00;  // 2.5
          B4 = 18'h08100; // 8.0625
          #100ns;
          
          A4 = 16'h0a00;  // 2.5
          B4 = 18'h37f00; // -8.0625
          #100ns;
          
          // Overflow
          A4 = 16'h2480;  // 9.125
          B4 = 18'h19aeb; // 25.6824
          #100ns;
          
      end
      
//-------------------------------------------
// A_int > B_int, A_FRAC == B_FRAC
//-------------------------------------------
    safe_mult #(
        .A_WIDTH (15), // A total width
        .A_FRAC  (10), // A fractional width
        .B_WIDTH (13), // B total width
        .B_FRAC  (10), // B fractional width
        .Q_WIDTH (14), // Q total width
        .Q_FRAC  (10) // Q fractional width
    ) inst_safe_mult5 (
        .A        (A5),
        .B        (B5),
        
        .Q        (Q5),
        .overflow (ovfl5)
    );
    
    // Multiplier 5
    initial
      begin
          A5 = 15'h0a9c;  // 2.6523
          B5 = 13'h0a00;  // 2.5
          #100ns;
          
          A5 = 15'h0595; // 1.3955
          B5 = 13'h10f0; // -3.7656
          #100ns;
          
          // Overflow
          A5 = 15'h2040;  // 8.0625
          B5 = 13'h10f0;  // -3.7656
          #100ns;
          
      end 

//-------------------------------------------
// A_int < B_int, A_FRAC = B_FRAC
//-------------------------------------------
    safe_mult #(
        .A_WIDTH (13), // A total width
        .A_FRAC  (10), // A fractional width
        .B_WIDTH (15), // B total width
        .B_FRAC  (10), // B fractional width
        .Q_WIDTH (14), // Q total width
        .Q_FRAC  (10) // Q fractional width
    ) inst_safe_mult6 (
        .A        (A6),
        .B        (B6),
        
        .Q        (Q6),
        .overflow (ovfl6)
    );
    
    // Multiplier 6
    initial
      begin
          A6 = 13'h0500;  // 1.25
          B6 = 15'h0e9c;  // 3.6523
          #100ns;
          
          A6 = 13'h10f0; // -3.7656
          B6 = 15'h0480; // 1.125
          #100ns;
          
          // Overflow
          A6 = 13'h0c00;  // 3
          B6 = 15'h0c40;  // 3.0625
          #100ns;
          
      end 
//-------------------------------------------
// A_int > B_int, A frac > B frac
//-------------------------------------------
    safe_mult #(
        .A_WIDTH (17), // A total width
        .A_FRAC  (12), // A fractional width
        .B_WIDTH (10), // B total width
        .B_FRAC  (5),  // B fractional width
        .Q_WIDTH (11), // Q total width
        .Q_FRAC  (6)   // Q fractional width
    ) inst_safe_mult7 (
        .A        (A7),
        .B        (B7),
        
        .Q        (Q7),
        .overflow (ovfl7)
    );
    
    // Multiplier 7
    initial
      begin
          A7 = 17'h02393; // 2.2234
          B7 = 10'h0b7;   // 5.7188
          #100ns;
          
          A7 = 17'h02393; // 2.2234
          B7 = 10'h349;   // -5.7188
          #100ns;
          
          // Overflow
          A7 = 17'h02393; // 2.2234
          B7 = 10'h100;   // 8.0000
          #100ns;
          
      end 
//-------------------------------------------
// A_int > B_int, A frac < B frac
//-------------------------------------------
    safe_mult #(
        .A_WIDTH (17), // A total width
        .A_FRAC  (8),  // A fractional width
        .B_WIDTH (12), // B total width
        .B_FRAC  (10), // B fractional width
        .Q_WIDTH (19), // Q total width
        .Q_FRAC  (12)  // Q fractional width
    ) inst_safe_mult8 (
        .A        (A8),
        .B        (B8),
        
        .Q        (Q8),
        .overflow (ovfl8)
    );
    
    // Multiplier 8
    initial
      begin
          A8 = 17'h03e20; // 62.1250
          B8 = 12'h281;   // 0.6260
          #100ns;
          
          A8 = 17'h1c1e0; // -62.1250
          B8 = 12'h14d;   // -0.325
          #100ns;
          
          // Overflow
          A8 = 17'h03e20; // 62.1250
          B8 = 12'h4c6;   // 1.1934
          #100ns;
          
      end 
//-------------------------------------------
// A_int < B_int, A frac < B frac
//-------------------------------------------
    safe_mult #(
        .A_WIDTH (8),  // A total width
        .A_FRAC  (3),  // A fractional width
        .B_WIDTH (13), // B total width
        .B_FRAC  (8),  // B fractional width
        .Q_WIDTH (15), // Q total width
        .Q_FRAC  (10)  // Q fractional width
    ) inst_safe_mult9 (
        .A        (A9),
        .B        (B9),
        
        .Q        (Q9),
        .overflow (ovfl9)
    );
    
    // Multiplier 9
    initial
      begin
          A9 = 8'h47;    // 8.8750
          B9 = 13'h01ac; // 1.6719
          #100ns;
          
          A9 = 8'h79;    // 15.1250
          B9 = 13'h1f4f; // -0.6914
          #100ns;
          
          // Overflow
          A9 = 8'h79;    // 15.1250
          B9 = 13'h012d; // 1.1754
          #100ns;
      end    
//-------------------------------------------
// A_int < B_int, A frac > B frac
//-------------------------------------------
    safe_mult #(
        .A_WIDTH (15), // A total width
        .A_FRAC  (12), // A fractional width
        .B_WIDTH (15), // B total width
        .B_FRAC  (8),  // B fractional width
        .Q_WIDTH (10), // Q total width
        .Q_FRAC  (5)   // Q fractional width
    ) inst_safe_mult10 (
        .A        (A10),
        .B        (B10),
        
        .Q        (Q10),
        .overflow (ovfl10)
    );
    
    // Multiplier 10
    initial
      begin
          A10 = 15'h2800; // 2.5
          B10 = 15'h0342; // 3.2578
          #100ns;
          
          A10 = 15'h2800; // 2.5
          B10 = 15'h7cbe; // -3.2578
          #100ns;
          
          // Overflow
          A10 = 15'h3c00; // 3.125
          B10 = 15'h05a0; // 5.625
          #100ns;
          
      end
    
    // Combine all overflow flags
    assign overflow = ovfl1 && ovfl3 && ovfl4 && ovfl5 && ovfl6 && ovfl7 && ovfl8 && ovfl9 && ovfl10;          

    initial
      begin
      #100ns
      op1_done = 1'b1;
      #100ns;
      op2_done = 1'b1;
      #100ns;
      op3_done = 1'b1;
      
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
      
always @ (posedge tb_clk)
  begin
      if (!op1_done)
        begin
            assert (!overflow)
              else 
                begin
                    $error("Overflow detected in first operation");
                    error_count <= error_count + 1;
                end
        end
      else if (!op2_done)
        begin
            assert (!overflow)
              else 
                begin
                    $error("Overflow detected in second operation");
                    error_count <= error_count + 1;
                end
        end
      else if (!op3_done)
        begin
            assert (overflow)
              else
                begin
                    $error("No overflow detected in third operation");
                    error_count <= error_count + 1;
                end
        end
  end
  
  initial
    begin
        forever #(CLK_PERIOD) tb_clk <= ~tb_clk;
    end
      
endmodule
