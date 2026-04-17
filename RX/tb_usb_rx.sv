`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_usb_rx ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst, dp_in, dm_in, rx_data_ready, rx_transfer_active, rx_error, flush, store_rx_packet_data;
    logic [6:0] buffer_occupancy;
    logic [2:0] rx_packet;
    logic [7:0] rx_packet_data; 
    string test_name;
    usb_rx DUT(.clk(clk), .n_rst(n_rst), .dp_in(dp_in), .dm_in(dm_in), .buffer_occupancy(buffer_occupancy), .rx_data_ready(rx_data_ready), .rx_transfer_active(rx_transfer_active), .rx_error(rx_error), .flush(flush), .store_rx_packet_data(store_rx_packet_data), .rx_packet(rx_packet), .rx_packet_data(rx_packet_data));

    // clockgen
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
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
    end
    endtask
    
    task sync_byte;
    begin
        dp_in = 0;
        dm_in = 1;
        #(83.3333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.3333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.3333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.3333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.3333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.3333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.3333ns);
        #(83.3333ns);
    end
    endtask

    task ack_pid;
    begin
        #(83.3333ns);
        #(83.3333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.3333ns);
        #(83.3333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.3333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.3333ns);
        #(83.3333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.3333ns);
    end
    endtask
    
    task eop;
    begin
        dp_in = 0;
        dm_in = 0;
        #(83.3333ns);
        #(83.3333ns);
        dp_in = 1;
        #(83.3333ns);
    end
    endtask

    initial begin
        n_rst = 1;
        test_name = "";
        dp_in = 1;
        dm_in = 0;

        test_name = "reset";
        reset_dut;

        #(83.3333ns);
        test_name = "correct sync byte";
        buffer_occupancy = 0;
        sync_byte();
        ack_pid();
        eop();
        #(83.3333ns);

        $finish;
    end
endmodule

/* verilator coverage_on */

