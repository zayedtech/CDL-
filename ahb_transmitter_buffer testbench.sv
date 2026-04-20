`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_ahb_usb ();

    localparam CLK_PERIOD = 10ns;
    localparam TIMEOUT    = 1000;

    localparam BURST_SINGLE = 3'd0;

    initial begin
        $dumpfile("waveform.fst");
        $dumpvars;
    end

    logic clk, n_rst;

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

    logic        hsel;
    logic [3:0]  haddr;
    logic [2:0]  hsize;
    logic [2:0]  hburst;
    logic [1:0]  htrans;
    logic        hwrite;
    logic [31:0] hwdata;
    logic [31:0] hrdata;
    logic        hresp;
    logic        hready;
    logic        dp_in;
    logic        dm_in;
    logic        dp_out;
    logic        dm_out;
    logic        d_mode;

    string testname;

    assign dp_in = 1'b1;
    assign dm_in = 1'b0;

    ahb_model_updated #(
        .ADDR_WIDTH(4),
        .DATA_WIDTH(4)
    ) BFM (
        .clk    (clk),
        .hsel   (hsel),
        .haddr  (haddr),
        .hsize  (hsize),
        .htrans (htrans),
        .hburst (hburst),
        .hwrite (hwrite),
        .hwdata (hwdata),
        .hrdata (hrdata),
        .hresp  (hresp),
        .hready (hready)
    );

    ahb_usb DUT (
        .clk    (clk),
        .n_rst  (n_rst),
        .hsel   (hsel),
        .haddr  (haddr),
        .hsize  (hsize),
        .hburst (hburst),
        .htrans (htrans),
        .hwrite (hwrite),
        .hwdata (hwdata),
        .hrdata (hrdata),
        .hresp  (hresp),
        .hready (hready),
        .dp_in  (dp_in),
        .dm_in  (dm_in),
        .dp_out (dp_out),
        .dm_out (dm_out),
        .d_mode (d_mode)
    );

    task reset_model;
        BFM.reset_model();
    endtask

    task enqueue_poll (
        input logic [3:0] addr,
        input logic [1:0] size
    );
        logic [31:0] data [];
    begin
        data    = new [1];
        data[0] = 32'hXXXXXXXX;
        BFM.enqueue_transaction(1'b1, 1'b0, addr, data, 1'b0, {1'b0, size}, 3'b0, 1'b0);
    end
    endtask

    task enqueue_write (
        input logic [3:0]  addr,
        input logic [1:0]  size,
        input logic [31:0] wdata
    );
        logic [31:0] data [];
    begin
        data    = new [1];
        data[0] = wdata;
        BFM.enqueue_transaction(1'b1, 1'b1, addr, data, 1'b0, {1'b0, size}, 3'b0, 1'b0);
    end
    endtask

    task execute_transactions (input int num_transactions);
        BFM.run_transactions(num_transactions);
    endtask

    task finish_transactions;
        BFM.wait_done();
    endtask

    task wait_bit_period;
    begin
        repeat(15) @(posedge clk);
    end
    endtask

    task wait_n_bits;
        input integer n;
        integer i;
    begin
        for (i = 0; i < n; i++)
            wait_bit_period();
    end
    endtask

    task wait_handshake_packet;
    begin
        wait_n_bits(30);
    end
    endtask

    task do_reset;
    begin
        reset_model();
        reset_dut();
        // flush buffer after every reset
        enqueue_write(4'hD, 2'd0, 32'h00000001);
        execute_transactions(1);
        finish_transactions();
        repeat(10) @(posedge clk);
    end
    endtask

    initial begin
        n_rst = 1;
        reset_model();
        reset_dut();

        // ─────────────────────────────────────────
        // TEST 1: write one byte — check occupancy
        // ─────────────────────────────────────────
        testname = "test_write_one_byte_occupancy";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AB);
        execute_transactions(1);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=1 in waveform

        // ─────────────────────────────────────────
        // TEST 2: write 4 bytes — check occupancy
        // ─────────────────────────────────────────
        testname = "test_write_multiple_bytes_occupancy";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AA);
        enqueue_write(4'h0, 2'd0, 32'h000000BB);
        enqueue_write(4'h0, 2'd0, 32'h000000CC);
        enqueue_write(4'h0, 2'd0, 32'h000000DD);
        execute_transactions(4);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=4 in waveform

        // ─────────────────────────────────────────
        // TEST 3: write then read back — FIFO order
        // ─────────────────────────────────────────
        testname = "test_write_read_fifo_order";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AA);
        enqueue_write(4'h0, 2'd0, 32'h000000BB);
        enqueue_write(4'h0, 2'd0, 32'h000000CC);
        execute_transactions(3);
        finish_transactions();
        enqueue_poll(4'h0, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0xAA
        enqueue_poll(4'h0, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0xBB
        enqueue_poll(4'h0, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0xCC

        // ─────────────────────────────────────────
        // TEST 4: occupancy decrements after reads
        // ─────────────────────────────────────────
        testname = "test_occupancy_after_reads";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AA);
        enqueue_write(4'h0, 2'd0, 32'h000000BB);
        enqueue_write(4'h0, 2'd0, 32'h000000CC);
        enqueue_write(4'h0, 2'd0, 32'h000000DD);
        enqueue_write(4'h0, 2'd0, 32'h000000EE);
        execute_transactions(5);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=5
        enqueue_poll(4'h0, 2'd0);
        enqueue_poll(4'h0, 2'd0);
        execute_transactions(2);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=3

        // ─────────────────────────────────────────
        // TEST 5: flush buffer via 0xD
        // ─────────────────────────────────────────
        testname = "test_flush_buffer";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AA);
        enqueue_write(4'h0, 2'd0, 32'h000000BB);
        enqueue_write(4'h0, 2'd0, 32'h000000CC);
        execute_transactions(3);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=3
        enqueue_write(4'hD, 2'd0, 32'h00000001);
        execute_transactions(1);
        finish_transactions();
        repeat(10) @(posedge clk);
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0

        // ─────────────────────────────────────────
        // TEST 6: hsize byte write — occupancy +1
        // ─────────────────────────────────────────
        testname = "test_hsize_byte_write";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AB);
        execute_transactions(1);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=1

        // ─────────────────────────────────────────
        // TEST 7: hsize halfword write — occupancy +2
        // ─────────────────────────────────────────
        testname = "test_hsize_halfword_write";
        do_reset();
        enqueue_write(4'h0, 2'd1, 32'h0000AABB);
        execute_transactions(1);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=2

        // ─────────────────────────────────────────
        // TEST 8: hsize word write — occupancy +4
        // ─────────────────────────────────────────
        testname = "test_hsize_word_write";
        do_reset();
        enqueue_write(4'h0, 2'd2, 32'hAABBCCDD);
        execute_transactions(1);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=4

        // ─────────────────────────────────────────
        // TEST 9: send ACK
        // ─────────────────────────────────────────
        testname = "test_send_ack";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000003);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        // observe tx_transfer_active=1 and d_mode=1 in waveform
        wait_handshake_packet();
        // observe tx_transfer_active=0 and d_mode=0
        enqueue_poll(4'hC, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0 — control register cleared

        // ─────────────────────────────────────────
        // TEST 10: send NAK
        // ─────────────────────────────────────────
        testname = "test_send_nak";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000004);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        wait_handshake_packet();
        enqueue_poll(4'hC, 2'd0);
        execute_transactions(1);
        finish_transactions();

        // ─────────────────────────────────────────
        // TEST 11: send STALL
        // ─────────────────────────────────────────
        testname = "test_send_stall";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000005);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        wait_handshake_packet();
        enqueue_poll(4'hC, 2'd0);
        execute_transactions(1);
        finish_transactions();

        // ─────────────────────────────────────────
        // TEST 12: send DATA0 with 3 bytes
        // ─────────────────────────────────────────
        testname = "test_send_data0";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AA);
        enqueue_write(4'h0, 2'd0, 32'h000000BB);
        enqueue_write(4'h0, 2'd0, 32'h000000CC);
        execute_transactions(3);
        finish_transactions();
        enqueue_write(4'hC, 2'd0, 32'h00000001);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        wait_n_bits(50);
        enqueue_poll(4'hC, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0

        // ─────────────────────────────────────────
        // TEST 13: send DATA1 with 2 bytes
        // ─────────────────────────────────────────
        testname = "test_send_data1";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000DD);
        enqueue_write(4'h0, 2'd0, 32'h000000EE);
        execute_transactions(2);
        finish_transactions();
        enqueue_write(4'hC, 2'd0, 32'h00000002);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        wait_n_bits(45);
        enqueue_poll(4'hC, 2'd0);
        execute_transactions(1);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();

        // ─────────────────────────────────────────
        // TEST 14: status register in idle
        // ─────────────────────────────────────────
        testname = "test_status_register_idle";
        do_reset();
        enqueue_poll(4'h4, 2'd1);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata bits — all should be 0 in idle

        // ─────────────────────────────────────────
        // TEST 15: status register tx_transfer_active bit
        // ─────────────────────────────────────────
        testname = "test_status_tx_transfer_active";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000003);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        enqueue_poll(4'h4, 2'd1);
        execute_transactions(1);
        finish_transactions();
        // observe bit 9 high in hrdata
        wait_handshake_packet();
        enqueue_poll(4'h4, 2'd1);
        execute_transactions(1);
        finish_transactions();
        // observe bit 9 low in hrdata

        // ─────────────────────────────────────────
        // TEST 16: error register in idle
        // ─────────────────────────────────────────
        testname = "test_error_register_idle";
        do_reset();
        enqueue_poll(4'h6, 2'd1);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0

        // ─────────────────────────────────────────
        // TEST 17: TX packet invalid value — no transmission
        // ─────────────────────────────────────────
        testname = "test_tx_packet_invalid";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000006);
        execute_transactions(1);
        finish_transactions();
        repeat(50) @(posedge clk);
        // observe tx_transfer_active stays 0 in waveform

        // ─────────────────────────────────────────
        // TEST 18: buffer full protection
        // ─────────────────────────────────────────
        testname = "test_buffer_full_protection";
        do_reset();
        begin
            int i;
            for (i = 0; i < 64; i++) begin
                enqueue_write(4'h0, 2'd0, 32'h000000AA);
                execute_transactions(1);
                finish_transactions();
            end
        end
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=64
        enqueue_write(4'h0, 2'd0, 32'h000000FF);
        execute_transactions(1);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata still 64

        // ─────────────────────────────────────────
        // TEST 19: d_mode follows tx_transfer_active
        // ─────────────────────────────────────────
        testname = "test_d_mode_follows_tx_transfer_active";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000003);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        // observe d_mode=1 in waveform
        wait_handshake_packet();
        repeat(20) @(posedge clk);
        // observe d_mode=0 in waveform

        // ─────────────────────────────────────────
        // TEST 20: TX control register clears after send
        // ─────────────────────────────────────────
        testname = "test_tx_control_clears_after_send";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000003);
        execute_transactions(1);
        finish_transactions();
        wait_handshake_packet();
        repeat(20) @(posedge clk);
        enqueue_poll(4'hC, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0

        $display("ALL TESTS DONE");
        $finish;
    end

endmodule
/* verilator coverage_on */
