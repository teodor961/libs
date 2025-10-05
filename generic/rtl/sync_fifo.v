// ------------------------------------------------------------------------------
// Project Name: psk-mod-ip
// File: sync_fifo.v
// Description: Simple parameterized synchronous fifo block with
//              programmable full flag.
// 
// Copyright (c) 2024 Teodor Dimitrov
// All rights reserved.
// 
// This file is dual-licensed under:
// 1. Open-source license: [GPL v3] (See LICENSE file)
// 2. Commercial license: Contact teodorpd@gmail.com for details.
// ------------------------------------------------------------------------------

module sync_fifo #(
     parameter DATA_WIDTH = 8,
     parameter BUFFER_DEPTH = 10,
     parameter PROG_DEPTH = 8
    ) (
     input rst,
     input clk,
		    
     input  [DATA_WIDTH - 1 : 0] wr_data,
     input                       wr_en,
     output                      prog_full,
     output                      full,
		    
     output [DATA_WIDTH - 1 : 0] rd_data,
     input                       rd_en,
     output                      empty,
     
     output overflow,
     output underflow

);
        
    localparam ADDR_WIDTH = $clog2(BUFFER_DEPTH);
    integer i;
	
	// control signals
	reg  [ADDR_WIDTH - 1 : 0] rd_ptr;
	reg  [ADDR_WIDTH - 1 : 0] wr_ptr;
	wire [ADDR_WIDTH - 1 : 0] wr_plus_1;
	wire [ADDR_WIDTH - 1 : 0] wr_plus_prog;
	wire [ADDR_WIDTH - 1 : 0] wr_plus_prog_plus_1;
	reg                       r_full;
	reg                       r_prog_full;
	reg                       r_empty;
	
	// Memory model
    reg [DATA_WIDTH - 1 : 0]   mem [BUFFER_DEPTH - 1 : 0];
    
    	
    // Output data buffer
	assign rd_data = mem[rd_ptr];
	
	always @ (posedge clk)
	  begin
	      if (rst)
	        begin
	            rd_ptr <= 0;
	        end
	      else if (rd_en && ~(wr_ptr == rd_ptr)) //use empty condition instead of empty flag to avoid 1 cycle delay
	        begin
	            rd_ptr <= (rd_ptr == BUFFER_DEPTH - 1) ? 0 : rd_ptr + 1;
	        end
	  end
	  
	always @ (posedge clk)
	  begin
	      if (rst)
	        begin
	            wr_ptr <= 0;
	        end
	      else if (wr_en && ~(rd_ptr == wr_plus_1)) //use full condition instead of full flag to avoid 1 cycle delay
	        begin
	            wr_ptr <= (wr_ptr == BUFFER_DEPTH - 1) ? 0 : wr_ptr + 1;
	        end
	  end
	  
// Memory block
    always @(posedge clk)
      begin
          if (rst)
            begin
                for (i = 0; i < BUFFER_DEPTH; i = i + 1)
                mem[i] <= 0;
            end
          else if (wr_en)
            begin
                mem[wr_ptr] <= wr_data;  
            end
      end
      
      
      
	assign wr_plus_1 = (wr_ptr == BUFFER_DEPTH-1) ? 0 : wr_ptr + 1; // Patch loop-around for depths that aren't powers of 2
	assign wr_plus_prog = (wr_ptr >= PROG_DEPTH) ? (wr_ptr - PROG_DEPTH) : (wr_ptr + BUFFER_DEPTH - PROG_DEPTH); // necessary for prog_full logic
	assign wr_plus_prog_plus_1 = (wr_ptr >= PROG_DEPTH - 1) ? (wr_ptr - PROG_DEPTH + 1) : (wr_ptr + BUFFER_DEPTH - PROG_DEPTH + 1); // necessary for prog_full logic
	
// Flow control logic
	always @(posedge clk)
	  begin
	      if (rst)
	        begin
	            r_full      <= 1'b0;
	            r_prog_full <= 1'b0;
	            //r_empty     <= 1'b0;
	        end
	      else
	        begin
	            // FULL logic branch
	            if (rd_ptr == wr_plus_1)
	              begin
	                  r_full <= 1'b1;
	              end
	            else
	              begin
	                  r_full <= 1'b0;
	              end
	            
	            // PROG FULL logic branch
	            if (rd_ptr == wr_plus_prog)
	              begin
	                  r_prog_full <= 1'b1;
	              end
	            else if (rd_ptr == wr_plus_prog_plus_1)
	              begin
	                  r_prog_full <= 1'b0;
	              end
	            // EMPTY logic branch
	            //if (wr_ptr == rd_ptr)
	            //  begin
	            //      r_empty <= 1'b1;
	            //  end
	            //else
	            //  begin
	            //      r_empty <= 1'b0;
	            //  end
	        end
	  end
	  
	always @(*)
	  begin
	      if (wr_ptr == rd_ptr)
	        begin
	            r_empty = 1'b1;
	        end
	      else
	        begin
	            r_empty = 1'b0;
	        end
	  end
	
	assign full  = r_full;
	assign prog_full = r_prog_full;
	assign empty = r_empty;
	
	assign overflow  = wr_en && full;
	assign underflow = rd_en && empty;
	
endmodule
