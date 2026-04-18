`timescale 1ns / 10ps

module usb_rx (input logic clk, n_rst, dp_in, dm_in, input logic [6:0] buffer_occupancy, output logic rx_data_ready, rx_transfer_active, rx_error, flush, store_rx_packet_data, output logic [2:0] rx_packet, output logic [7:0] rx_packet_data);

logic dp, dm, dpshift_strobe, unusedbit, unusedbit4, end_packet, serial_in, new_pack, pid_error, data_1, data_0, out_token, in_token, ack, strobes_16, cycles_8, data_done, data_done_ffin, pidsyncshift_strobe, unusedbit2, unusedbit3, data_en;
logic clear_err, en_timer, transfer_active, eop_err, pack_done, timer_16, timer_8, unused1, syncpid_end, serial_ff, data_error, flush_and_start, data_strobe, data_end, sync_error, syncpid_end_ffout, store_ffin, store_ffout, data_end_ffout;
logic [1:0] unused, twobits, unused5, twobitsm, count_ffin, count_ffout;
logic [13:0] cycles; 
logic [3:0] unused2;
logic [23:0] unused3, parallel_out;
logic [23:0] unused4, par_out;
logic [7:0] data_ffin, data_ffout;

flex_sr #(.SIZE(2), .MSB_FIRST(0)) dpsr(.clk(clk), .n_rst(n_rst), .shift_enable(dpshift_strobe), .load_enable(1'b0), .serial_in(dp_in), .parallel_in(unused), .serial_out(unusedbit), .parallel_out(twobits));
flex_sr #(.SIZE(2), .MSB_FIRST(0)) dmsr(.clk(clk), .n_rst(n_rst), .shift_enable(dpshift_strobe), .load_enable(1'b0), .serial_in(dm_in), .parallel_in(unused5), .serial_out(unusedbit4), .parallel_out(twobitsm));


timer timerdp(.clk(clk), .n_rst(n_rst), .enable_timer(1'b1), .data_size(5'b00011), .bit_period(cycles),  .shift_strobe(dpshift_strobe), .packet_done(end_packet));

always_comb begin : eightEightNine
    if(end_packet) begin
        cycles = 9;
    end
    else begin
        cycles = 8;
    end
end

always_comb begin : checkChange
    if((twobits[0] == twobits[1])) begin
        serial_in = 1;
    end
    else begin
        serial_in = 0;
    end
end

always_comb begin : startBitDetector

    if(!transfer_active & !serial_in) begin
        new_pack = 1;
    end
    else begin
        new_pack = 0;
    end
end

control_fsm CFSM(.clk(clk), .n_rst(n_rst), .new_pack(new_pack), .pid_error(pid_error), .data_1(data_1), .data_0(data_0), .out_token(out_token), .in_token(in_token), .ack(ack), .strobes_16(strobes_16), .cycles_8(cycles_8), .dm(twobitsm[0]), .dp(twobits[0]), .data_done(data_done),
.clear_err(clear_err), .en_timer(en_timer), .rx_data_ready(rx_data_ready), .transfer_active(transfer_active), .flush_and_start(flush_and_start), .eop_err(eop_err), .pack_done(pack_done), .timer_16(timer_16), .timer_8(timer_8), .rx_packet(rx_packet));

timer timerfsm16(.clk(clk), .n_rst(n_rst), .enable_timer(timer_16), .data_size(5'b10000), .bit_period(14'b00000000001000),  .shift_strobe(unused1), .packet_done(strobes_16));

flex_counter #(.SIZE(4)) counter8 (
        .clk(clk),
        .n_rst(n_rst),
        .clear(~timer_8),  
        .count_enable(timer_8),
        .rollover_val(4'b1000),
        .count_out(unused2),
        .rollover_flag(cycles_8));

timer timerpidsync(.clk(clk), .n_rst(n_rst), .enable_timer(en_timer), .data_size(5'b01111), .bit_period(cycles),  .shift_strobe(pidsyncshift_strobe), .packet_done(syncpid_end));

flex_sr #(.SIZE(24), .MSB_FIRST(0)) syncpidsr(.clk(clk), .n_rst(n_rst), .shift_enable(dpshift_strobe), .load_enable(1'b0), .serial_in(serial_in), .parallel_in(unused3), .serial_out(unusedbit2), .parallel_out(parallel_out));

always_ff @(posedge clk, negedge n_rst) begin : syncPidEnd
    if(n_rst == 0) begin
        syncpid_end_ffout <= 0;
    end
    else begin
        syncpid_end_ffout <= syncpid_end;
    end
end

always_comb begin : decodeSyncPid

    if(syncpid_end & !syncpid_end_ffout) begin
        if(parallel_out[15:8] != 8'b10000000) begin
            sync_error = 1;
            in_token = 0;
            out_token = 0;
            ack = 0;
            data_0 = 0;
            data_1 = 0;
            pid_error = 0;
        end
        else if(parallel_out[23:16] == 8'b01101001) begin
            sync_error = 0;
            in_token = 1;
            out_token = 0;
            ack = 0;
            data_0 = 0;
            data_1 = 0;
            pid_error = 0;
        end
        else if(parallel_out[23:16] == 8'b11100001) begin
            sync_error = 0;
            in_token = 0;
            out_token = 1;
            ack = 0;
            data_0 = 0;
            data_1 = 0;
            pid_error = 0;
        end
        else if(parallel_out[23:16] == 8'b11010010) begin
            sync_error = 0;
            in_token = 0;
            out_token = 0;
            ack = 1;
            data_0 = 0;
            data_1 = 0;
            pid_error = 0;
        end
        else if(parallel_out[23:16] == 8'b11000011) begin
            sync_error = 0;
            in_token = 0;
            out_token = 0;
            ack = 0;
            data_0 = 1;
            data_1 = 0;
            pid_error = 0;
        end
        else if(parallel_out[23:16] == 8'b01001011) begin
            sync_error = 0;
            in_token = 0;
            out_token = 0;
            ack = 0;
            data_0 = 0;
            data_1 = 1;
            pid_error = 0;
        end
        else begin
            sync_error = 0;
            in_token = 0;
            out_token = 0;
            ack = 0;
            data_0 = 0;
            data_1 = 0;
            pid_error = 1;
        end
    end
    else begin
        sync_error = 0;
        in_token = 0;
        out_token = 0;
        ack = 0;
        data_0 = 0;
        data_1 = 0;
        pid_error = 0;
    end
end

always_comb begin : errorChecker
    if(clear_err) begin
        rx_error = 0;
    end
    else if(eop_err || sync_error || pid_error || data_error) begin
        rx_error = 1;
    end
    else begin
        rx_error = 0;
    end
end

timer timerdata(.clk(clk), .n_rst(n_rst), .enable_timer(data_en || flush_and_start), .data_size(5'b00111), .bit_period(cycles),  .shift_strobe(data_strobe), .packet_done(data_end));

always_ff @(posedge clk, negedge n_rst) begin : dataEnd
    if(n_rst == 0) begin
        data_end_ffout <= 0;
    end
    else begin
        data_end_ffout <= data_end;
    end
end

always_ff @(posedge clk, negedge n_rst) begin : dataEnable
    if(n_rst == 0) begin
        data_en <= 0; 
    end
    else if (flush_and_start) begin
        data_en <= 1;
    end
    else if (!transfer_active) begin
        data_en <= 0;
    end
end

always_comb begin : dataChecker

    if(buffer_occupancy == 64) begin
        data_error = 1;
    end
    else begin
        data_error = 0;
    end

    if(data_end & !data_end_ffout) begin

        if(count_ffout == 2) begin // 3rd holds new

            if(parallel_out[23:16] == parallel_out[15:8]) begin
                
                data_ffin = parallel_out[7:0];
                store_ffin = 1;

                if(parallel_out[23:16] == 8'b00000001) begin // we are done
                    data_done_ffin = 1;
                end
                else begin //false alarm
                    data_done_ffin = 0;
                end
            end

            else begin // keep going
                data_done_ffin = 0;
                data_ffin = parallel_out[7:0];
                store_ffin = 1;
            end

            count_ffin = count_ffout;
        end

        else begin //still first two pushes

            count_ffin = count_ffout + 1;
            store_ffin = 0;
            data_ffin = data_ffout;
            data_done_ffin = 0;
        end
    end

    else begin
        count_ffin = count_ffout;
        data_done_ffin = data_done;
        store_ffin = 0; // maybe change
        data_ffin = data_ffout;
    end

end

always_ff @(posedge clk, negedge n_rst) begin
    if(n_rst == 0) begin
        data_done <= 0;
        store_ffout <= 0;
        data_ffout <= 0;
        count_ffout <= 0;
    end
    else begin
        data_done <= data_done_ffin;
        store_ffout <= store_ffin;
        data_ffout <= data_ffin;
        count_ffout <= count_ffin;
    end
end

assign flush = flush_and_start;
assign store_rx_packet_data = store_ffout;
assign rx_packet_data = data_ffout;
assign rx_transfer_active = transfer_active;

endmodule

