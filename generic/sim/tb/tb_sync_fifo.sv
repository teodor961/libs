`timescale 1ns / 1ps
// ------------------------------------------------------------------------------
// Project Name: psk-mod-ip
// File: tb_sync_fifo.sv
// Description: Block level testbench for sync_fifo.v
// 
// Copyright (c) 2024 Teodor Dimitrov
// All rights reserved.
// 
// This file is dual-licensed under:
// 1. Open-source license: [GPL v3] (See LICENSE file)
// 2. Commercial license: Contact teodorpd@gmail.com for details.
// ------------------------------------------------------------------------------

module tb_sync_fifo (

);

logic  rst;
logic  clk;

logic [7:0] tb_wr_data;
logic       tb_wr_en;
logic       tb_prog_full;
logic       tb_full;

logic [7:0] tb_rd_data;
logic       tb_rd_en;
logic       tb_empty;

// testbench control logic
typedef enum {READ=0, WRITE=1} rd_wr_state_t;

rd_wr_state_t STATE; // 0 = WRITE/1 = READ

logic [31:0] error_count = 0;


parameter CLK_PERIOD = 50;

    sync_fifo  #(
            .DATA_WIDTH   (8),
            .BUFFER_DEPTH (10)
    ) inst_sync_fifo (
            .rst       (rst),
            .clk       (clk),
            .wr_data   (tb_wr_data),
            .wr_en     (tb_wr_en),
            .full      (tb_full),
            .prog_full (tb_prog_full),
		    
            .rd_data   (tb_rd_data),
            .rd_en     (tb_rd_en_buff),
            .empty     (tb_empty)
    );
    
initial
  begin
      clk <= 1'b0;
      forever #(CLK_PERIOD) clk <= ~clk;
  end

  
initial
  begin
      rst <= 1'b1;
      #200 rst <= 1'b0;
  end
  
always @(posedge clk)
  begin
      if (rst)
        begin
            tb_wr_data <= 8'h01;
            tb_rd_en   <= 1'b0;
        end
      else 
          begin
              case (STATE)
                WRITE: begin // WRITE LOGIC
                          tb_rd_en <= 1'b0;
                          if (~tb_full)
                            begin
                                tb_wr_data <= tb_wr_data + 1;
                            end
                      end
                READ: begin // READ LOGIC
                          if (~tb_empty)
                            begin
                                tb_rd_en <= 1'b1;
                            end
                          else
                            begin
                                tb_rd_en <= 1'b0;
                            end
                      end
              endcase
          end
  end
  
  assign tb_rd_en_buff = tb_rd_en && ~tb_empty;
  
// TESTBENCH FSM LOGIC
  always @(posedge clk)
    begin
        if (rst)
          begin
              STATE <= WRITE;
          end
        else
          begin
              if (tb_full == 1'b1)
                STATE <= READ;
              else if (tb_empty == 1'b1)
                STATE <= WRITE; 
          end
    end
  
assign tb_wr_en = (STATE == WRITE) ? ~tb_full : 1'b0;
  
initial
  begin
      $display("Begin simulation tb_sync_fifo");
      #10000;
      
      
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
  
always @ (posedge clk)
  begin
      if (rst == 1'b0)
        begin
            assert (!(tb_full == 1'b1 && tb_wr_en == 1'b1))
              else 
                begin
                    $error("Buffer OVERFLOW detected");
                    error_count <= error_count + 1;
                end

            assert (!(tb_empty == 1'b1 && tb_rd_en_buff == 1'b1))
              else 
                begin
                    $error("Buffer UNDERFLOW detected");
                    error_count <= error_count + 1;
                end
           
            assert (!(tb_empty == 1'b1 && tb_full == 1'b1))
              else
                begin
                    $error("Invalid state! Cannot be both FULL and EMPTY");
                    error_count <= error_count + 1;
                end
            assert (!(tb_prog_full == 1'b0 && tb_full == 1'b1))
              else
                begin
                    $error("Cannot be full when prog_full is not set!");
                    error_count <= error_count + 1;
                end
        end
  end
endmodule
