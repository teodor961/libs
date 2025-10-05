// ------------------------------------------------------------------------------
// Project Name: psk-mod-ip
// File: fir_generic.v
// Description: Parameterized fir filter block. Coefficients are passed in
//              as one large input vector.
//              A transposed FIR filter topology is used, to avoid generating
//              long combinatorial paths for higher filter orders.
// 
// Copyright (c) 2024 Teodor Dimitrov
// All rights reserved.
// 
// This file is dual-licensed under:
// 1. Open-source license: [GPL v3] (See LICENSE file)
// 2. Commercial license: Contact teodorpd@gmail.com for details.
// ------------------------------------------------------------------------------


module fir_generic #(
        parameter INPUT_W       = 16,
        parameter INPUT_FRAC_W  = 14,
        parameter COEFF_W       = 16,
        parameter COEFF_FRAC_W  = 14,
        parameter OUTPUT_W      = 16,
        parameter OUTPUT_FRAC_W = 14,
        parameter FILTER_TAPS   = 4
    ) (
        input rst,
        input clk,
        
        input         [FILTER_TAPS*COEFF_W - 1 : 0] coeff_vector,
        
        input  signed [INPUT_W-1:0]                 data_in,
        input                                       sample_en,
        
        output signed [OUTPUT_W-1:0]                data_out,
        output reg                                  sample_valid,
        
        output                                      overflow

    );
    
    localparam MULT_W = INPUT_W + COEFF_W;
    localparam MULT_FRAC_W = OUTPUT_FRAC_W + COEFF_FRAC_W;
    
    localparam ACC_W = (MULT_W + FILTER_TAPS);
    localparam ACC_FRAC_W = MULT_FRAC_W;
    
    wire signed [MULT_W - 1: 0] filter_product [FILTER_TAPS - 1: 0];
    //wire signed [MULT_W- 1: 0] filter_product_trunc [FILTER_TAPS - 1: 0];
    wire signed [ACC_W - 1: 0] filter_sum [FILTER_TAPS - 2: 0];
    reg  signed [ACC_W - 1: 0] filter_pipeline [FILTER_TAPS - 1: 0];
    wire signed [OUTPUT_W - 1: 0] result;
    
    wire signed [INPUT_W - 1: 0] coeff[FILTER_TAPS-1: 0];
    
    // overflow flags
    wire [FILTER_TAPS-1:0] mult_overflow;
    wire [FILTER_TAPS-2:0] add_overflow;
    wire                   rescale_overflow;
    
    genvar i;
    
    
    generate
        for (i = 1; i <= FILTER_TAPS; i = i + 1)
          begin
              assign coeff[i-1] = coeff_vector[i*INPUT_W - 1 : (i-1)*INPUT_W];
          end
    endgenerate
    
   //generate
   //  for (i=0; i< FILTER_TAPS; i=i+1)
   //   begin
   //       assign filter_product[i] = data_in*coeff[i];
   //       assign filter_product_trunc[i] = filter_product[i][2*INPUT_W-1 : CUT_BITS - PRC_BITS];
   //   end
  //endgenerate
    
    generate
      for (i = 0; i < FILTER_TAPS; i = i + 1)
        begin
            safe_mult #(
                .A_WIDTH (INPUT_W), // A total width
                .A_FRAC  (INPUT_FRAC_W), // A fractional width
                .B_WIDTH (COEFF_W), // B total width
                .B_FRAC  (COEFF_FRAC_W), // B fractional width
                .Q_WIDTH (MULT_W), // Q total width
                .Q_FRAC  (MULT_FRAC_W)  // Q fractional width
            ) filter_mult (
                .A        (data_in),
                .B        (coeff[i]),
                .Q        (filter_product[i]),
                .overflow (mult_overflow[i])
            );
        end
    endgenerate
    
    always @(posedge clk)
      begin: PIPELINE
          integer k;
          if (rst)
            begin
                for (k = 0; k <= FILTER_TAPS-1; k = k + 1)
                  begin
                      filter_pipeline[k] <= 0;
                  end
                sample_valid <= 1'b0;
            end
          else if (sample_en)
             begin
                 filter_pipeline[FILTER_TAPS-1] <= filter_product[FILTER_TAPS-1];
                 for (k = 0; k < FILTER_TAPS-1; k = k + 1)
                   begin
                       filter_pipeline[k] <= filter_sum[k];
                   end
                 sample_valid <= 1'b1;
             end
          else
            begin
                sample_valid <= 1'b0;
            end
      end
    
    genvar j;
    
    generate
        for (j = 0; j < FILTER_TAPS - 1; j = j + 1)
          begin
              safe_adder #(
                  .A_WIDTH (ACC_W), // A total width
                  .A_FRAC  (ACC_FRAC_W), // A fractional width
                  .B_WIDTH (MULT_W), // B total width
                  .B_FRAC  (MULT_FRAC_W), // B fractional width
                  .Q_WIDTH (ACC_W), // Q total width
                  .Q_FRAC  (ACC_FRAC_W),  // Q fractional width
                  .OP ("ADD")    // ADD / SUB
              ) filter_add (
                  .A (filter_pipeline[j+1]),
                  .B (filter_product[j]),
                  .Q (filter_sum[j]),
                  .overflow (add_overflow[j])
              );
          end
    endgenerate
//------------------------------------------------
// Rescaling logic
//------------------------------------------------
// Rescale using zero add
    safe_adder #(
          .A_WIDTH (ACC_W), // A total width
          .A_FRAC  (ACC_FRAC_W), // A fractional width
          .B_WIDTH (2), // B total width
          .B_FRAC  (1), // B fractional width
          .Q_WIDTH (OUTPUT_W), // Q total width
          .Q_FRAC  (OUTPUT_FRAC_W),  // Q fractional width
          .OP ("ADD")    // ADD / SUB
      ) output_rescale (
          .A (filter_pipeline[0]),
          .B (2'd0),
          .Q (result),
          .overflow (rescale_overflow)
      );
    
    assign data_out = result;

//-------------------------------------------------
// Overflow flag logic
//-------------------------------------------------
    assign overflow = |add_overflow | |mult_overflow | rescale_overflow;

endmodule
