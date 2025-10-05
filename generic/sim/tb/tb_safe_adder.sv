`timescale 1ns / 1ps
// ------------------------------------------------------------------------------
// Project Name: psk-mod-ip
// File: tb_safe_adder.sv
// Description: Block level testbench for safe_adder.v
// 
// Copyright (c) 2024 Teodor Dimitrov
// All rights reserved.
// 
// This file is dual-licensed under:
// 1. Open-source license: [GPL v3] (See LICENSE file)
// 2. Commercial license: Contact teodorpd@gmail.com for details.
// ------------------------------------------------------------------------------

module tb_safe_adder(

    );
    
    parameter CLK_PERIOD   = 4;
    logic tb_clk = 0;
    
    
    // Equal widths, equal fractionals
    logic [12:0] A1; // Q(13,8)
    logic [12:0] B1; // Q(13,8)
    logic [12:0] Q1; // Q(13,8)
    logic        ovfl1;
    
    // Equal widths, equal fractionals, op = SUB
    logic [12:0] A2; // Q(13,8)
    logic [12:0] B2; // Q(13,8)
    logic [12:0] Q2; // Q(13,8)
    logic        ovfl2;
    
    // A_int = B_int, A_FRAC > B_FRAC, op = SUB
    logic [12:0] A3; // Q(13,8)
    logic [10:0] B3; // Q(11,8)
    logic [12:0] Q3; // Q(13,8)
    logic        ovfl3;
    
    // A_int = B_int, A_FRAC < B_FRAC, op = ADD
    logic [15:0] A4; // Q(16,10)
    logic [17:0] B4; // Q(18,12)
    logic [19:0] Q4; // Q(20,14)
    logic        ovfl4;
    
    // A_int > B_int, A_FRAC = B_FRAC, op = ADD
    logic [14:0] A5; // Q(15,10)
    logic [12:0] B5; // Q(13,10)
    logic [13:0] Q5; // Q(14,10)
    logic        ovfl5;
    
    // A_int < B_int, A_FRAC = B_FRAC, op = ADD
    logic [12:0] A6; // Q(13,10)
    logic [14:0] B6; // Q(15,10)
    logic [13:0] Q6; // Q(14,10)
    logic        ovfl6;
    
    // A_int > B_int, A frac > B frac, op = ADD
    logic [16:0] A7; // Q(17,12)
    logic [9:0]  B7; // Q(10,5)
    logic [10:0] Q7; // Q(11,6)
    logic        ovfl7;
    
    // A_int > B_int, A_FRAC < B_FRAC, op = ADD
    logic [16:0] A8; // Q(17,8)
    logic [11:0] B8; // Q(12,10)
    logic [18:0] Q8; // Q(19,12)
    logic        ovfl8;
    
    // A_int < B_int, A_FRAC < B_FRAC, op = ADD
    logic [7:0]  A9; // Q(8,3)
    logic [12:0] B9; // Q(13,8)
    logic [14:0] Q9; // Q(15,10)
    logic        ovfl9;
    
    // A_int < B_int > A_FRAC > B_FRAC, op = ADD
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
// Equal Widths, Equal fractionals, Addition
//-------------------------------------------
    safe_adder #(
        .A_WIDTH (13), // A total width
        .A_FRAC  (8), // A fractional width
        .B_WIDTH (13), // B total width
        .B_FRAC  (8), // B fractional width
        .Q_WIDTH (13), // Q total width
        .Q_FRAC  (8),  // Q fractional width
        .OP      ("ADD")
    ) inst_safe_adder1 (
        .A        (A1),
        .B        (B1),
        
        .Q        (Q1),
        .overflow (ovfl1)
    );
    
    // Adder 1
    initial
      begin
          // Add
          A1 = 13'h0280; // 2.5
          B1 = 13'h0842; // 8.2578
          #100ns;
          
          // Subtract
          A1 = 13'h0280; // 2.5
          B1 = 13'h17be; // -8.2578
          #100ns;
          
          // Overflow
          A1 = 13'h0920; // 9.125
          B1 = 13'h0920; // -9.125
          #100ns;
          
      end
      
//-------------------------------------------
// Equal Widths, Equal Fractionals, Subtraction
//-------------------------------------------
    safe_adder #(
        .A_WIDTH (13), // A total width
        .A_FRAC  (8), // A fractional width
        .B_WIDTH (13), // B total width
        .B_FRAC  (8), // B fractional width
        .Q_WIDTH (13), // Q total width
        .Q_FRAC  (8),  // Q fractional width
        .OP      ("SUB")
    ) inst_safe_adder2 (
        .A        (A2),
        .B        (B2),
        
        .Q        (Q2),
        .overflow (ovfl2)
    );
    
    // Adder 2
    initial
      begin
          // Add
          A2 = 13'h0280; // 2.5
          B2 = 13'h0842; // 8.2578
          #100ns;
          
          // Subtract
          A2 = 13'h0280; // 2.5
          B2 = 13'h17be; // -8.2578
          #100ns;
          
          // Overflow
          A2 = 13'h0920; // 9.125
          B2 = 13'h16e0; // 9.125
          #100ns;
          
      end
      
//-------------------------------------------
// A_int = B_int, A_FRAC > B_FRAC, Addition
//-------------------------------------------
    safe_adder #(
        .A_WIDTH (13), // A total width
        .A_FRAC  (8), // A fractional width
        .B_WIDTH (11), // B total width
        .B_FRAC  (6), // B fractional width
        .Q_WIDTH (13), // Q total width
        .Q_FRAC  (8),  // Q fractional width
        .OP      ("ADD")
    ) inst_safe_adder3 (
        .A        (A3),
        .B        (B3),
        
        .Q        (Q3),
        .overflow (ovfl3)
    );
    
    // Adder 3
    initial
      begin
          // Add
          A3 = 13'h0280; // 2.5
          B3 = 11'h204;  // 8.0625
          #100ns;
          
          // Subtract
          A3 = 13'h0280; // 2.5
          B3 = 11'h5fc;  // -8.0625
          #100ns;
          
          // Overflow
          A3 = 13'h0920; // 9.125
          B3 = 11'h248;  // 9.125
          #100ns;
          
      end  
      
//-------------------------------------------
// A_int = B_int, A_FRAC < B_FRAC, Addition
//-------------------------------------------
    safe_adder #(
        .A_WIDTH (16), // A total width
        .A_FRAC  (10), // A fractional width
        .B_WIDTH (18), // B total width
        .B_FRAC  (12), // B fractional width
        .Q_WIDTH (20), // Q total width
        .Q_FRAC  (14), // Q fractional width
        .OP      ("ADD")
    ) inst_safe_adder4 (
        .A        (A4),
        .B        (B4),
        
        .Q        (Q4),
        .overflow (ovfl4)
    );
    
    // Adder 4
    initial
      begin
          // Add
          A4 = 16'h0a00;  // 2.5
          B4 = 18'h08100; // 8.0625
          #100ns;
          
          // Subtract
          A4 = 16'h0a00; // 2.5
          B4 = 18'h37f00;  // -8.0625
          #100ns;
          
          // Overflow
          A4 = 16'h2480;  // 9.125
          B4 = 18'h19aeb; // 25.6824
          #100ns;
          
      end
      
//-------------------------------------------
// A_int > B_int, A_FRAC == B_FRAC
//-------------------------------------------
    safe_adder #(
        .A_WIDTH (15), // A total width
        .A_FRAC  (10), // A fractional width
        .B_WIDTH (13), // B total width
        .B_FRAC  (10), // B fractional width
        .Q_WIDTH (14), // Q total width
        .Q_FRAC  (10), // Q fractional width
        .OP      ("ADD")
    ) inst_safe_adder5 (
        .A        (A5),
        .B        (B5),
        
        .Q        (Q5),
        .overflow (ovfl5)
    );
    
    // Adder 5
    initial
      begin
          // Add
          A5 = 15'h0e9c;  // 3.6523
          B5 = 13'h0a00;  // 2.5
          #100ns;
          
          // Subtract
          A5 = 15'h2040; // 8.0625
          B5 = 13'h10f0; // -3.7656
          #100ns;
          
          // Overflow
          A5 = 15'h2040;  // 8.0625
          B5 = 13'h0a00;  // 2.5
          #100ns;
          
      end 

//-------------------------------------------
// A_int < B_int, A_FRAC = B_FRAC Addition
//-------------------------------------------
    safe_adder #(
        .A_WIDTH (13), // A total width
        .A_FRAC  (10), // A fractional width
        .B_WIDTH (15), // B total width
        .B_FRAC  (10), // B fractional width
        .Q_WIDTH (14), // Q total width
        .Q_FRAC  (10), // Q fractional width
        .OP      ("ADD")
    ) inst_safe_adder6 (
        .A        (A6),
        .B        (B6),
        
        .Q        (Q6),
        .overflow (ovfl6)
    );
    
    // Adder 6
    initial
      begin
          // Add
          A6 = 13'h0a00;  // 2.5
          B6 = 15'h0e9c;  // 3.6523
          #100ns;
          
          // Subtract
          A6 = 13'h10f0; // -3.7656
          B6 = 15'h2040; // 8.0625
          #100ns;
          
          // Overflow
          A6 = 13'h0a00;  // 2.5
          B6 = 15'h2040;  // 8.0625
          #100ns;
          
      end 
//-------------------------------------------
// A_int > B_int, A frac > B frac, Addition
//-------------------------------------------
    safe_adder #(
        .A_WIDTH (17), // A total width
        .A_FRAC  (12), // A fractional width
        .B_WIDTH (10), // B total width
        .B_FRAC  (5), // B fractional width
        .Q_WIDTH (11), // Q total width
        .Q_FRAC  (6), // Q fractional width
        .OP      ("ADD")
    ) inst_safe_adder7 (
        .A        (A7),
        .B        (B7),
        
        .Q        (Q7),
        .overflow (ovfl7)
    );
    
    // Adder 7
    initial
      begin
          // Add
          A7 = 17'h02393; // 2.2234
          B7 = 10'h118;   // 8.7500
          #100ns;
          
          // Subtract
          A7 = 17'h02393; // 2.2234
          B7 = 10'h2e8;   // -8.7500
          #100ns;
          
          // Overflow
          A7 = 17'h02393; // 2.2234
          B7 = 10'h1fc;   // 15.8750
          #100ns;
          
      end 
//-------------------------------------------
// A_int > B_int, A frac < B frac, Addition
//-------------------------------------------
    safe_adder #(
        .A_WIDTH (17), // A total width
        .A_FRAC  (8), // A fractional width
        .B_WIDTH (12), // B total width
        .B_FRAC  (10), // B fractional width
        .Q_WIDTH (19), // Q total width
        .Q_FRAC  (12), // Q fractional width
        .OP      ("ADD")
    ) inst_safe_adder8 (
        .A        (A8),
        .B        (B8),
        
        .Q        (Q8),
        .overflow (ovfl8)
    );
    
    // Adder 7
    initial
      begin
          // Add
          A8 = 17'h03e20; // 62.1250
          B8 = 12'h281;   // 0.6260
          #100ns;
          
          // Subtract
          A8 = 17'h03e20; // 62.1250
          B8 = 12'h800;   // -2
          #100ns;
          
          // Overflow
          A8 = 17'h03e20; // 62.1250
          B8 = 12'h7ff;   // 1.9961
          #100ns;
          
      end 
//-------------------------------------------
// A_int < B_int, A frac < B frac, Addition
//-------------------------------------------
    safe_adder #(
        .A_WIDTH (8), // A total width
        .A_FRAC  (3), // A fractional width
        .B_WIDTH (13), // B total width
        .B_FRAC  (8),  // B fractional width
        .Q_WIDTH (15), // Q total width
        .Q_FRAC  (10),  // Q fractional width
        .OP      ("ADD")
    ) inst_safe_adder9 (
        .A        (A9),
        .B        (B9),
        
        .Q        (Q9),
        .overflow (ovfl9)
    );
    
    // Adder 9
    initial
      begin
          // Add
          A9 = 8'h57;    // 10.8750
          B9 = 13'h03ac; // 3.6719
          #100ns;
          
          // Subtract
          A9 = 8'h79;    // 15.1250
          B9 = 13'h1000; // -15.9961
          #100ns;
          
          // Overflow
          A9 = 8'h79;    // 15.1250
          B9 = 13'h0fff; // 15.9961
          #100ns;
      end    
//-------------------------------------------
// A_int < B_int, A frac > B frac, Addition
//-------------------------------------------
    safe_adder #(
        .A_WIDTH (15), // A total width
        .A_FRAC  (12), // A fractional width
        .B_WIDTH (15), // B total width
        .B_FRAC  (8),  // B fractional width
        .Q_WIDTH (10), // Q total width
        .Q_FRAC  (5),  // Q fractional width
        .OP      ("ADD")
    ) inst_safe_adder10 (
        .A        (A10),
        .B        (B10),
        
        .Q        (Q10),
        .overflow (ovfl10)
    );
    
    // Adder 10
    initial
      begin
          // Add
          A10 = 15'h2800; // 2.5
          B10 = 15'h0842; // 8.2578
          #100ns;
          
          // Subtract
          A10 = 15'h2800; // 2.5
          B10 = 15'h77be; // -8.2578
          #100ns;
          
          // Overflow
          A10 = 15'h3c00; // 3.125
          B10 = 15'h3ca0; // 60.625
          #100ns;
          
      end
    
    // Combine all overflow flags
    assign overflow = ovfl1 && ovfl2 && ovfl3 && ovfl4 && ovfl5 && ovfl6 && ovfl7 && ovfl8 && ovfl9 && ovfl10;
      
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
