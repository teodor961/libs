// ------------------------------------------------------------------------------
// Project Name: psk-mod-ip
// File: fixp_counter.v
// Description: Fixed point number counter. 
// 
// Copyright (c) 2024 Teodor Dimitrov
// All rights reserved.
// 
// This file is dual-licensed under:
// 1. Open-source license: [GPL v3] (See LICENSE file)
// 2. Commercial license: Contact teodorpd@gmail.com for details.
// ------------------------------------------------------------------------------

module fixp_counter(
        input         rst,
        input         clk,
        input         clk_en,
        
        input [7:0]   step_size, // Q(8,8), unsigned
        output [15:0] counter_out
    );
    
    reg [15:0] counter_reg; // Q(16,8), unsigned
    
    always @(posedge clk)
      begin
          if (rst)
            begin
                counter_reg <= 16'h0000;
            end
          else if (clk_en)
            begin
                counter_reg <= (counter_reg + step_size >= {step_size, 8'h00}) ? 16'h0000 : counter_reg + {8'h00, step_size};
            end
      end
    
    assign counter_out = counter_reg;
    
endmodule
