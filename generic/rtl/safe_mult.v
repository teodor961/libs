// ------------------------------------------------------------------------------
// Project Name: psk-mod-ip
// File: safe_mult.v
// Description: Parameterized multiplier block. All input and output ports have
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

module safe_mult #(
        parameter A_WIDTH = 16, // A total width
        parameter A_FRAC  = 14, // A fractional width
        parameter B_WIDTH = 16, // B total width
        parameter B_FRAC  = 14, // B fractional width
        parameter Q_WIDTH = 16, // Q total width
        parameter Q_FRAC  = 14  // Q fractional width
    ) (
        input signed [A_WIDTH-1:0] A,
        input signed [B_WIDTH-1:0] B,
        
        output [Q_WIDTH-1:0] Q,
        output overflow
    );
    
    localparam A_INT = A_WIDTH - A_FRAC;
    localparam B_INT = B_WIDTH - B_FRAC;
    
    localparam Q_FULLSCALE_FRAC = A_FRAC + B_FRAC;
    localparam Q_FULLSCALE_INT  = A_INT + B_INT;
    localparam Q_FULLSCALE_WIDTH = Q_FULLSCALE_INT + Q_FULLSCALE_FRAC;
    
    localparam Q_FRAC_OVERHEAD = (Q_FULLSCALE_FRAC >= Q_FRAC) ? (Q_FULLSCALE_FRAC-Q_FRAC) : (Q_FRAC-Q_FULLSCALE_FRAC);
    
    localparam Q_int = Q_WIDTH - Q_FRAC;
    
    localparam GUARD_WIDTH = (Q_FULLSCALE_INT > Q_int) ? Q_FULLSCALE_INT - Q_int : 1; // Else case is just to prevent errors
    
    wire [GUARD_WIDTH-1:0] guard_bits;
    
    wire signed [Q_FULLSCALE_WIDTH - 1:0]  Q_fullscale;
    wire        [Q_FULLSCALE_INT-1:0]  Q_fullscale_int_bits;
    wire        [Q_FULLSCALE_FRAC-1:0] Q_fullscale_frac_bits;
    
    wire        [Q_int-1:0]            Q_int_bits;
    wire        [Q_FRAC-1:0]           Q_frac_bits;
    
    
    //----------------------------------------
    // Full scale
    //----------------------------------------
    assign Q_fullscale = A*B;
    assign Q_fullscale_int_bits  = Q_fullscale[Q_FULLSCALE_WIDTH-1:Q_FULLSCALE_FRAC];
    assign Q_fullscale_frac_bits = Q_fullscale[Q_FULLSCALE_FRAC-1:0];
    
    //-----------------------------------------
    // Rescale to output aperture
    //-----------------------------------------
    assign Q_int_bits = (Q_FULLSCALE_INT >= Q_int)   ? Q_fullscale_int_bits[Q_int-1:0] : { {Q_int - Q_FULLSCALE_INT{Q_fullscale_int_bits[Q_FULLSCALE_INT-1]}} , Q_fullscale_int_bits};
    assign Q_frac_bits = (Q_FULLSCALE_FRAC >= Q_FRAC) ? Q_fullscale_frac_bits[Q_FULLSCALE_FRAC-1:Q_FRAC_OVERHEAD] : {Q_fullscale_frac_bits, {Q_FRAC_OVERHEAD{1'b0}}};
    assign Q = {Q_int_bits, Q_frac_bits};
    
    //-----------------------------------------
    // Overflow detection
    //-----------------------------------------
    // Check if extra bits match the result sign bit. If any of them don't, the result has overflown
    assign guard_bits = (Q_FULLSCALE_INT > Q_int) ? Q_fullscale[Q_FULLSCALE_WIDTH-1:Q_FULLSCALE_WIDTH-GUARD_WIDTH] : 0;
    // When all guard bits == Q(MSB) = 0 or All guard bits == Q(MSB) == 1 - No overflow occurs for Q when truncating
    assign overflow = (Q_FULLSCALE_INT > Q_int) ? ( (Q[Q_WIDTH-1] == 1'b0) ? |guard_bits != 1'b0 : &guard_bits != 1'b1) : 1'b0;

endmodule
