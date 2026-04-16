`timescale 1ns / 10ps
/* verilator coverage_off */
module tb_ahb_subordinate_usb ();

   localparam CLK_PERIOD = 10ns;
   localparam TIMEOUT = 1000;

   localparam BURST_SINGLE = 3'd0;

   initial begin
       $dumpfile("waveform.fst");
       $dumpvars;
   end


   logic clk, n_rst;

   //clockgen
   always begin
       clk = 0;
       #(CLK_PERIOD / 2.0);
       clk = 1;
       #(CLK_PERIOD / 2.0);
   end

   task reset_dut;
   begin
       n_rst = 0;
       @(posedge clk);
       @(posedge clk);
       @(negedge clk);
       n_rst = 1;
       @(negedge clk);
       @(negedge clk);
   end
   endtask


   logic hsel;
   logic [3:0] haddr;
   logic [2:0] hsize;
   logic [2:0] hburst;
   logic [1:0] htrans;
   logic hwrite;
   logic [31:0] hwdata;
   logic [31:0] hrdata;
   logic hresp;
   logic hready;
   string test_name;


   //bus model connections
   ahb_model_updated #(
       .ADDR_WIDTH(4),
       .DATA_WIDTH(4)
   ) BFM (
       .clk(clk),
       .hsel(hsel),
       .haddr(haddr),
       .hsize(hsize),
       .htrans(htrans),
       .hburst(hburst),
       .hwrite(hwrite),
       .hwdata(hwdata),
       .hrdata(hrdata),
       .hresp(hresp),
       .hready(hready)
   );


   // Supporting Tasks
   task reset_model;
       BFM.reset_model();
   endtask


   // Read from a register without checking the value
   task enqueue_read(input logic [3:0] addr, input logic [1:0] size, input logic [31:0] exp_read);
       logic [31:0] data [];
   begin
       data = new [1];
       data[0] = exp_read;
       BFM.enqueue_transaction(1'b1, 1'b0, addr, data, 1'b0, {1'b0, size}, BURST_SINGLE, 1'b1);
   end
   endtask


   task enqueue_write(input logic [3:0] addr, input logic [1:0] size, input logic [31:0] wdata);
       logic [31:0] data [];
   begin
       data = new [1];
       data[0] = wdata;
       BFM.enqueue_transaction(1'b1, 1'b1, addr, data, 1'b0, {1'b0, size}, BURST_SINGLE, 1'b0);
   end
   endtask


   task execute_transactions(input int num_transactions);
       BFM.run_transactions(num_transactions);
   endtask


   task finish_transactions();
       BFM.wait_done();
   endtask


   logic [2:0] rx_packet;
   logic rx_data_ready;
   logic rx_transfer_active;
   logic rx_error;
   logic [7:0] rx_data;
   logic get_rx_data;
   logic [6:0] buffer_occupancy;
   logic store_tx_data;
   logic [7:0] tx_data;
   logic clear;
   logic [2:0] tx_packet;
   logic tx_transfer_active;
   logic tx_error;
   logic d_mode;


   logic [7:0] fifo_mem [0:63];
   integer i;


   ahb_subordinate_usb DUT (
       .clk(clk),
       .n_rst(n_rst),
       .hsel(hsel),
       .haddr(haddr),
       .hsize(hsize),
       .hburst(hburst),
       .htrans(htrans),
       .hwrite(hwrite),
       .hwdata(hwdata),
       .hrdata(hrdata),
       .hresp(hresp),
       .hready(hready),
       .rx_packet(rx_packet),
       .rx_data_ready(rx_data_ready),
       .rx_transfer_active(rx_transfer_active),
       .rx_error(rx_error),
       .rx_data(rx_data),
       .get_rx_data(get_rx_data),
       .buffer_occupancy(buffer_occupancy),
       .store_tx_data(store_tx_data),
       .tx_data(tx_data),
       .clear(clear),
       .tx_packet(tx_packet),
       .tx_transfer_active(tx_transfer_active),
       .tx_error(tx_error),
       .d_mode(d_mode)
   );


   always_ff @(posedge clk or negedge n_rst) begin
       if (!n_rst) begin
           buffer_occupancy <= 7'd0;
           rx_data <= 8'h00;
           for (i = 0; i < 64; i = i + 1)
               fifo_mem[i] <= 8'h00;
       end else begin
           if (clear) begin
               buffer_occupancy <= 7'd0;
               rx_data <= 8'h00;
           end else begin
               if (store_tx_data) begin
                   fifo_mem[buffer_occupancy] <= tx_data;
                   buffer_occupancy <= buffer_occupancy + 7'd1;
               end
               if (get_rx_data && (buffer_occupancy != 7'd0)) begin
                   for (i = 0; i < 63; i = i + 1)
                       fifo_mem[i] <= fifo_mem[i+1];
                   buffer_occupancy <= buffer_occupancy - 7'd1;
               end
               if (buffer_occupancy != 7'd0)
                   rx_data <= fifo_mem[0];
               else
                   rx_data <= 8'h00;
           end
       end
   end


   initial begin
       n_rst = 1'b1;
       rx_packet = 3'd7;
       rx_data_ready = 1'b0;
       rx_transfer_active = 1'b0;
       rx_error = 1'b0;
       tx_transfer_active = 1'b0;
       tx_error = 1'b0;


       reset_model();
       reset_dut();


       test_name = "TX Control";
       enqueue_write(4'hC, 2'd0, 32'h0000_0003);
       enqueue_read (4'hC, 2'd0, 32'h0000_0003);
       execute_transactions(2);
       finish_transactions();


       test_name = "Buffer Write";
       enqueue_write(4'h0, 2'd2, 32'h4433_2211);
       execute_transactions(1);
       finish_transactions();


       test_name = "Buffer Occupancy";
       enqueue_read(4'h8, 2'd0, 32'h0000_0004);
       execute_transactions(1);
       finish_transactions();


       test_name = "Buffer Read";
       enqueue_read(4'h0, 2'd2, 32'h4433_2211);
       execute_transactions(1);
       finish_transactions();


       test_name = "Status";
       rx_packet = 3'd2;
       rx_data_ready = 1'b1;
       @(posedge clk);
       rx_data_ready = 1'b0;
       enqueue_read(4'h4, 2'd1, 32'h0000_0011);
       execute_transactions(1);
       finish_transactions();


       test_name = "Error";
       rx_error = 1'b1;
       @(posedge clk);
       rx_error = 1'b0;
       enqueue_read(4'h6, 2'd1, 32'h0000_0001);
       execute_transactions(1);
       finish_transactions();


       $finish;
   end
endmodule
/* verilator coverage_on */




