`timescale 1ns / 1ps
// ------------------------------------------------------------------------------
// Project Name: psk-mod-ip
// File: tb_cdc_sync_handshake.sv
// Description: Block level testbench for cdc_sync_handshake.v
// 
// Copyright (c) 2024 Teodor Dimitrov
// All rights reserved.
// 
// This file is dual-licensed under:
// 1. Open-source license: [GPL v3] (See LICENSE file)
// 2. Commercial license: Contact teodorpd@gmail.com for details.
// ------------------------------------------------------------------------------

module tb_cdc_sync_handshake (

);

parameter DATA_WIDTH = 8;

logic  rst;
logic  tb_clk_src;
logic  tb_clk_dest;

logic [31:0] error_count = 0;

// Test signals
typedef enum {IDLE_SEND, SENDING} send_state_t;
typedef enum {IDLE_RECEIVE, RECEIVING, WAIT_REQ_DROP} receive_state_t;

send_state_t send_state;
receive_state_t receive_state;

logic [DATA_WIDTH-1:0] tb_data_in = 0;
logic                  tb_req_in = 0;
logic                  tb_ack_in;

logic [DATA_WIDTH-1:0] tb_data_out;
logic [DATA_WIDTH-1:0] tb_data_clean;
logic                  tb_req_out;
logic                  tb_ack_out = 0;

parameter SRC_CLK_PERIOD = 50;
parameter DEST_CLK_PERIOD = 63;

    cdc_sync_handshake  #(
            .DATA_WIDTH   (DATA_WIDTH)
    ) inst_cdc_sync_handshake (
            .clk_src   (tb_clk_src),
            .clk_dest  (tb_clk_dest),
            // Data in
            .in_data   (tb_data_in),
            .in_req    (tb_req_in),
            .in_ack    (tb_ack_in),
            // Data out
            .out_data  (tb_data_out),
            .out_req   (tb_req_out),
            .out_ack   (tb_ack_out)
           
    );
    
initial
  begin
      tb_clk_src <= 1'b0;
      forever #(SRC_CLK_PERIOD) tb_clk_src <= ~tb_clk_src;
  end

initial
  begin
      tb_clk_dest <= 1'b0;
      forever #(DEST_CLK_PERIOD) tb_clk_dest <= ~tb_clk_dest;
  end

  
initial
  begin
      rst <= 1'b1;
      #200 rst <= 1'b0;
  end

// Send FSM
always @(posedge tb_clk_src)
  begin
      case (send_state)
        IDLE_SEND: 
            begin
                if (tb_ack_in)
                  begin
                      tb_req_in <= 1'b0;
                  end
                else
                  begin
                      tb_data_in <= tb_data_in + 1;
                      tb_req_in  <= 1'b1;
		              send_state <= SENDING;
                  end
            end
	    SENDING:
            begin
                if (tb_ack_in)
                  begin
                      tb_req_in  <= 1'b0;
			          send_state <= IDLE_SEND;
                  end
		        else
		          begin
                      tb_req_in <= 1'b1;
		          end
            end
      endcase
  end

// Receive FSM
always @(posedge tb_clk_dest)
  begin
      case (receive_state)
        IDLE_RECEIVE:
          begin
              if (tb_req_out)
                begin
                    tb_data_clean <= tb_data_out;
                    tb_ack_out    <= 1'b1;
                    receive_state <= RECEIVING;
                end
          end
        RECEIVING:
          begin
              receive_state <= WAIT_REQ_DROP;
          end
        WAIT_REQ_DROP:
          begin
              if (tb_req_out == 0)
                begin
                    receive_state <= IDLE_RECEIVE;
                    tb_ack_out <= 1'b0;
                end
          end
      endcase
  end
  
 
initial
  begin
      $display("Begin simulation tb_cdc_sync_handshake");
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
  

endmodule
