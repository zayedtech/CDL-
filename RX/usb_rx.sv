`timescale 1ns / 10ps

module usb_rx (input logic clk, n_rst, dp_in, dm_in, input logic [6:0] buffer_occupancy, output logic rx_data_ready, rx_transfer_active, rx_error, flush, store_rx_packet_data, output logic [2:0] rx_packet, output logic [7:0] rx_packet_data);

logic dp, dm, dpshift_strobe, unusedbit, end_packet, serial_in, new_pack, pid_error, data_1, data_0, out_token, in_token, ack, strobes_16, cycles_8, data_done, data_done_ffin, pidsyncshift_strobe, unusedbit2, unusedbit3, maybe_ffin, maybe_ffout;
logic clear_err, en_timer, transfer_active, eop_err, pack_done, timer_16, timer_8, unused1, syncpid_end, serial_ff, data_error, flush_and_start, data_strobe, data_end, sync_error;
logic [1:0] unused, twobits;
logic [13:0] cycles; 
logic [3:0] unused2;
logic [15:0] unused3, parallel_out;
logic [23:0] unused4, par_out;

sync #(.RST_VAL(1)) syncdp(.clk(clk), .n_rst(n_rst), .async_in(dp_in), .sync_out(dp));
sync syncdm(.clk(clk), .n_rst(n_rst), .async_in(dm_in), .sync_out(dm));

flex_sr #(.SIZE(2), .MSB_FIRST(0)) dpsr(.clk(clk), .n_rst(n_rst), .shift_enable(dpshift_strobe), .load_enable(1'b0), .serial_in(dp), .parallel_in(unused), .serial_out(unusedbit), .parallel_out(twobits));

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
    if(twobits[0] == twobits[1]) begin
        serial_ff = 1;
    end
    else begin
        serial_ff = 0;
    end
end

always_ff @(posedge clk, negedge n_rst) begin : serialInFF
    if(n_rst == 0) begin
        serial_in <= 1;
    end
    else begin
        serial_in <= serial_ff;
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

control_fsm CFSM(.clk(clk), .n_rst(n_rst), .new_pack(new_pack), .pid_error(pid_error), .data_1(data_1), .data_0(data_0), .out_token(out_token), .in_token(in_token), .ack(ack), .strobes_16(strobes_16), .cycles_8(cycles_8), .dm(dm), .dp(dp), .data_done(data_done),
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

timer timerpidsync(.clk(clk), .n_rst(n_rst), .enable_timer(en_timer), .data_size(5'b10000), .bit_period(14'b00000000001000),  .shift_strobe(pidsyncshift_strobe), .packet_done(syncpid_end));

flex_sr #(.SIZE(16), .MSB_FIRST(0)) syncpidsr(.clk(clk), .n_rst(n_rst), .shift_enable(pidsyncshift_strobe), .load_enable(1'b0), .serial_in(serial_in), .parallel_in(unused3), .serial_out(unusedbit2), .parallel_out(parallel_out));

always_comb begin : decodeSyncPid

    if(syncpid_end) begin
        if(parallel_out[7:0] != 8'b00000001) begin
            sync_error = 1;
            in_token = 0;
            out_token = 0;
            ack = 0;
            data_0 = 0;
            data_1 = 0;
            pid_error = 0;
        end
        else if(parallel_out[15:8] == 8'b01101001) begin
            sync_error = 0;
            in_token = 1;
            out_token = 0;
            ack = 0;
            data_0 = 0;
            data_1 = 0;
            pid_error = 0;
        end
        else if(parallel_out[15:8] == 8'b11100001) begin
            sync_error = 0;
            in_token = 0;
            out_token = 1;
            ack = 0;
            data_0 = 0;
            data_1 = 0;
            pid_error = 0;
        end
        else if(parallel_out[15:8] == 8'b11010010) begin
            sync_error = 0;
            in_token = 0;
            out_token = 0;
            ack = 1;
            data_0 = 0;
            data_1 = 0;
            pid_error = 0;
        end
        else if(parallel_out[15:8] == 8'b11000011) begin
            sync_error = 0;
            in_token = 0;
            out_token = 0;
            ack = 0;
            data_0 = 1;
            data_1 = 0;
            pid_error = 0;
        end
        else if(parallel_out[15:8] == 8'b01001011) begin
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

timer timerdata(.clk(clk), .n_rst(n_rst), .enable_timer(flush_and_start), .data_size(5'b01000), .bit_period(14'b00000000001000),  .shift_strobe(data_strobe), .packet_done(data_end));

flex_sr #(.SIZE(24), .MSB_FIRST(0)) datasr(.clk(clk), .n_rst(n_rst), .shift_enable(data_strobe), .load_enable(1'b0), .serial_in(serial_in), .parallel_in(unused4), .serial_out(unusedbit3), .parallel_out(par_out));

always_comb begin : dataChecker

    if(data_end) begin
        if(par_out[23:16] == par_out[7:0]) begin
            if(maybe_ffout) begin
                data_done_ffin = 1;
                maybe_ffin = 0;
            end
            else begin
                data_done_ffin = 0;
                maybe_ffin = 1;
            end
        end
        else begin
            maybe_ffin = maybe_ffout;
            data_done_ffin = data_done;
        end

        if(buffer_occupancy == 64) begin
            data_error = 1;
        end
        else begin
            data_error = 0;
        end
    end
    else begin
        maybe_ffin = maybe_ffout;
        data_done_ffin = data_done;
        data_error = 0;
    end
end

always_ff @(posedge clk, negedge n_rst) begin
    if(n_rst == 0) begin
        maybe_ffout <= 0;
        data_done <= 0;
    end
    else begin
        maybe_ffout <= maybe_ffin;
        data_done <= data_done_ffin;
    end
end

assign flush = flush_and_start;
assign store_rx_packet_data = data_end;
assign rx_packet_data = par_out[7:0];
assign rx_transfer_active = transfer_active;

endmodule

