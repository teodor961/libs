//--------------------------------------------------
// Created by : Teodor Dimitrov
// Design     : async_fifo
// Module name: async_fifo_top.v
//
// Description: Top level module for the asynchronous fifo design
//              Design hierarchy is as follows:
//                async_fifo  -> top module
//                  \_ mem.v  -> RAM block
//                  \_ bin2gray.v -> gray encoder for sync logic 
//                  \_ gray2bin.v -> gray decoder for sync logic 
//
// TODO: Create handshake synchronizer to replace 2 flop sync - 2 flop sync wont work for crossing faster to slower clock domain...

module cdc_sync_handshake (
      parameter DATA_WIDTH = 1
     ) (
     input  clk_src,                    // Sending clock domain
     input  clk_dest,                   // Receiving clock domain
     
     input  [DATA_WIDTH-1:0]  in_data,  // Input data signal
     input                    in_req,
     output                   in_ack,
     
     output [DATA_WIDTH-1:0]  out_data, // Synchronized output signal
     output                   out_req,
     input                    out_ack
);

reg r1_req;
reg r2_req;

reg r1_ack;
reg r2_ack;

    always @(posedge clk_dest)
      begin
          r1_req <= in_req;
          r2_req <= r1_req;
      end

    always @(posedge clk_src)
      begin
          r1_ack <= out_ack;
          r2_ack <= r1_ack;
      end

    assign out_req = r2_req;
    assign in_ack = r2_ack;

endmodule
