// ------------------------------------------------------------------------------
// Project Name: psk-mod-ip
// File: safe_adder.v
// Description: Parameterized adder block. All input and output ports have
//              selectable integer and fractional widths.
//              Output is truncated or extended based on selected width.
//              Overflow logic tracks for errors after truncation.
// 
// Copyright (c) 2024 Teodor Dimitrov
// All rights reserved.
// 
// This file is dual-licensed under:
// 1. Open-source license: [GPL v3] (See LICENSE file)
// 2. Commercial license: Contact teodorpd@gmail.com for details.
// ------------------------------------------------------------------------------

module safe_adder #(
        parameter A_WIDTH = 16, // A total width
        parameter A_FRAC  = 14, // A fractional width
        parameter B_WIDTH = 16, // B total width
        parameter B_FRAC  = 14, // B fractional width
        parameter Q_WIDTH = 16, // Q total width
        parameter Q_FRAC  = 14,  // Q fractional width
        parameter OP = "ADD"    // ADD / SUB
    ) (
        input signed [A_WIDTH-1:0] A,
        input signed [B_WIDTH-1:0] B,
        
        output [Q_WIDTH-1:0] Q,
        output overflow
    );
    
    initial
      begin
          if (OP != "ADD" && OP != "SUB")
              $error("Illegal value for OP parameter");
      end
    
    localparam A_INT = A_WIDTH - A_FRAC;
    localparam B_INT = B_WIDTH - B_FRAC;

    localparam Q_FULLSCALE_FRAC = (A_FRAC > B_FRAC) ? A_FRAC : B_FRAC;
    localparam Q_FULLSCALE_INT  = (A_INT > B_INT) ? A_INT + 1 : B_INT + 1; // Add 1 guard bit for overflows
    localparam Q_FULLSCALE_WIDTH = Q_FULLSCALE_INT + Q_FULLSCALE_FRAC;
    
    localparam Q_FRAC_OVERHEAD = (Q_FULLSCALE_FRAC >= Q_FRAC) ? (Q_FULLSCALE_FRAC-Q_FRAC) : (Q_FRAC-Q_FULLSCALE_FRAC);
    
    localparam Q_INT = Q_WIDTH - Q_FRAC;
    
    localparam GUARD_WIDTH = (Q_FULLSCALE_INT > Q_INT) ? Q_FULLSCALE_INT - Q_INT : 1; // Else case is just to prevent errors
    
    wire [GUARD_WIDTH-1:0] guard_bits;

    wire signed [Q_FULLSCALE_WIDTH - 1:0]  Q_fullscale;
    wire        [Q_FULLSCALE_INT-1:0]  Q_fullscale_int_bits;
    wire        [Q_FULLSCALE_FRAC-1:0] Q_fullscale_frac_bits;
    wire        [Q_INT-1:0]            Q_int_bits;
    wire        [Q_FRAC-1:0]           Q_frac_bits;
    
// Invert B operand for SUBTRACTION
    wire signed [B_WIDTH-1:0] B_buff;
    
    assign B_buff = (OP == "SUB") ? ~(B) + 1 : B;
    wire [Q_FULLSCALE_WIDTH-2:0] B_scaled; // for debug
    wire [Q_FULLSCALE_WIDTH-2:0] A_scaled; // for debug
//---------------------------------------
// Generate addition with custom scaling
//---------------------------------------
    generate
        if (A_WIDTH == B_WIDTH && A_FRAC == B_FRAC) // Equal width inputs, equal fractional parts
          begin 
              assign Q_fullscale = A + B_buff;
          end
        else if (A_INT == B_INT && A_FRAC > B_FRAC) // Equal ranges, A higher resolution than B
          begin
              assign A_scaled = A;
              assign B_scaled = {B_buff, {A_FRAC-B_FRAC{1'b0}}};
              assign Q_fullscale = A + $signed({B_buff, {A_FRAC-B_FRAC{1'b0}}});
          end
        else if (A_INT == B_INT && A_FRAC < B_FRAC) // Equal widths, B higher resolution than B
          begin
              assign A_scaled = {A, {B_FRAC-A_FRAC{1'b0}}};
              assign B_scaled = B_buff;
              assign Q_fullscale = $signed({A, {B_FRAC-A_FRAC{1'b0}}}) + B_buff;
          end
        else if (A_INT > B_INT && A_FRAC == B_FRAC) // A higher range than B, Equal resolution
          begin
              assign A_scaled = A;
              assign B_scaled = {{A_INT-B_INT{B_buff[B_WIDTH-1]}}, B_buff};
              assign Q_fullscale = A + $signed({{A_INT-B_INT{B_buff[B_WIDTH-1]}}, B_buff}); // Sign extend B by repeating MSB n-times (n = A_INT - B_INT)
          end
        else if (A_INT < B_INT && A_FRAC == B_FRAC) // B higher range than A, Equal resolution
          begin
              assign A_scaled = {{B_INT-A_INT{A[A_WIDTH-1]}}, A};
              assign B_scaled = B_buff;
              assign Q_fullscale = $signed({{B_INT-A_INT{A[A_WIDTH-1]}}, A}) + B_buff;  // Sign extend A by repeating MSB n-times (n = B_INT - A_INT)
          end
        else if (A_INT > B_INT && A_FRAC > B_FRAC)
          begin
              assign A_scaled = A;
              assign B_scaled = {{A_INT-B_INT{B_buff[B_WIDTH-1]}}, B_buff, {A_FRAC-B_FRAC{1'b0}}};
              assign Q_fullscale = A + $signed({{A_INT-B_INT{B_buff[B_WIDTH-1]}}, B_buff, {A_FRAC-B_FRAC{1'b0}}}); // Sign extend B and append zeros
          end
        else if (A_INT > B_INT && A_FRAC < B_FRAC)
          begin
              assign A_scaled = {A, {B_FRAC-A_FRAC{1'b0}}};
              assign B_scaled = {{A_INT-B_INT{B_buff[B_WIDTH-1]}}, B_buff};
              assign Q_fullscale = $signed({A, {B_FRAC-A_FRAC{1'b0}}}) + $signed({{A_INT-B_INT{B_buff[B_WIDTH-1]}}, B_buff}); // Append zeros to A, sign extend B
          end
        else if (A_INT < B_INT && A_FRAC < B_FRAC)
          begin
              assign A_scaled = {{B_INT-A_INT{A[A_WIDTH-1]}}, A, {B_FRAC-A_FRAC{1'b0}}};
              assign B_scaled = B_buff;
              assign Q_fullscale = $signed({{B_INT-A_INT{A[A_WIDTH-1]}}, A, {B_FRAC-A_FRAC{1'b0}}}) + B_buff;
          end
        else if (A_INT < B_INT && A_FRAC > B_FRAC)
          begin
              assign B_scaled    = {B_buff, {A_FRAC-B_FRAC{1'b0}}};
              assign A_scaled    = {{B_INT-A_INT{A[A_WIDTH-1]}}, A};
              assign Q_fullscale = $signed({{B_INT-A_INT{A[A_WIDTH-1]}}, A}) +$signed( {B_buff, {A_FRAC-B_FRAC{1'b0}}});
          end
        else
          begin
              assign Q_fullscale = A + B_buff;
          end 
    endgenerate

//---------------------------------------
// Output formatting
//---------------------------------------
    integer test_width1;
    integer test_width2;
    
    initial begin
        //test_width1 = $size({Q_fullscale_frac_bits, {Q_FRAC_OVERHEAD{1'b0}}});
        //test_width2 = $size(Q_fullscale_frac_bits[Q_FULLSCALE_FRAC-1:Q_FRAC_OVERHEAD]);
    end
    
    assign Q_fullscale_int_bits  = Q_fullscale[Q_FULLSCALE_WIDTH-1:Q_FULLSCALE_FRAC];
    assign Q_fullscale_frac_bits = Q_fullscale[Q_FULLSCALE_FRAC-1:0];
    assign Q_int_bits = (Q_FULLSCALE_INT >= Q_INT)   ? Q_fullscale_int_bits[Q_INT-1:0] : { {Q_INT - Q_FULLSCALE_INT{Q_fullscale_int_bits[Q_FULLSCALE_INT-1]}} , Q_fullscale_int_bits};
    assign Q_frac_bits = (Q_FULLSCALE_FRAC >= Q_FRAC) ? Q_fullscale_frac_bits[Q_FULLSCALE_FRAC-1:Q_FRAC_OVERHEAD] : {Q_fullscale_frac_bits, {Q_FRAC_OVERHEAD{1'b0}}};
    assign Q = {Q_int_bits, Q_frac_bits};
    
//---------------------------------------
// Overflow detection
//---------------------------------------
// Check if extra bits match the result sign bit. If any of them don't, the result has overflown
    assign guard_bits = (Q_FULLSCALE_INT > Q_INT) ? Q_fullscale[Q_FULLSCALE_WIDTH-1:Q_FULLSCALE_WIDTH-(Q_FULLSCALE_INT-Q_INT)] : 0;
    // When all guard bits == Q(MSB) = 0 or All guard bits == Q(MSB) == 1 - No overflow occurs for Q when truncating
    assign overflow = (Q_FULLSCALE_INT > Q_INT) ? ( (Q[Q_WIDTH-1] == 1'b0) ? |guard_bits != 1'b0 : &guard_bits != 1'b1) : 1'b0;

endmodule
