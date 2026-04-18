`timescale 1ns / 10ps

typedef enum logic [4:0]{
  IDLE=0, CLEAR=1, START=2, DATA1=3, DATA0=4, OUT=5, IN=6, ACK=7, EOP_START=8, EOP_0=9, WAIT_1=10, EOP_1=11, WAIT_2=12, IDLE_VAL=13, ERROR=14, DONE=15, FL_DATA1=16, FL_DATA0=17
} state_t;


module control_fsm (input logic clk, n_rst, new_pack, pid_error, data_1, data_0, out_token, in_token, ack, strobes_16, cycles_8, dm, dp, data_done,
output logic clear_err, en_timer, rx_data_ready, transfer_active, flush_and_start, eop_err, pack_done, timer_16, timer_8, output logic [2:0] rx_packet);

state_t state, nextstate;

//logic [2:0] packet_type;

always_comb begin : nextStateLogic
    casez ({state, new_pack, pid_error, data_1, data_0, out_token, in_token, ack, strobes_16, cycles_8, dm, dp, data_done})
        {IDLE, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = CLEAR;
        {CLEAR, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = START;
        {START, 1'b?, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = IDLE;
        {START, 1'b?, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = FL_DATA1;
        {START, 1'b?, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = FL_DATA0;
        {START, 1'b?, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = OUT;
        {START, 1'b?, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = IN;
        {START, 1'b?, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = ACK;
        {OUT, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = EOP_START;
        {IN, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = EOP_START;
        {EOP_START, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = EOP_0;
        {EOP_0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b0, 1'b0, 1'b?}: nextstate = WAIT_1;
        {EOP_0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?}: nextstate = ERROR;
        {WAIT_1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?, 1'b?, 1'b?}: nextstate = EOP_1;
        {EOP_1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b0, 1'b0, 1'b?}: nextstate = WAIT_2;
        {EOP_1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?}: nextstate = ERROR;
        {WAIT_2, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?, 1'b?, 1'b?}: nextstate = IDLE_VAL;
        {IDLE_VAL, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b0, 1'b1, 1'b?}: nextstate = DONE;
        {IDLE_VAL, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b0, 1'b?}: nextstate = ERROR;
        {DONE, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = IDLE;
        {ERROR, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = IDLE;
        {DATA0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1}: nextstate = EOP_START;    
        {DATA1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1}: nextstate = EOP_START;
        {ACK, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = EOP_START;    
        {FL_DATA1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = DATA1;    
        {FL_DATA0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: nextstate = DATA0;    
        

        default: nextstate = state;
    endcase
end

always_ff @(posedge clk, negedge n_rst) begin : stateFF
    if (n_rst == 0) begin
        state <= IDLE;
    end
    else begin
        state <= nextstate;
    end
end

always_comb begin : outputLogic
    case(state)
        IDLE: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b0;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        CLEAR: begin
            clear_err = 1'b1;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        START: begin
            clear_err = 1'b0;
            en_timer = 1'b1;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        FL_DATA1: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b010;
            flush_and_start = 1'b1;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        DATA1: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        FL_DATA0: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b001;
            flush_and_start = 1'b1;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        DATA0: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        OUT: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b110;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b1;
            timer_8 = 1'b0;
        end
        IN: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b111;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b1;
            timer_8 = 1'b0;
        end
        ACK: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b011;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        EOP_START: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        EOP_0: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        WAIT_1: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b1;
        end
        EOP_1: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        ERROR: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b1;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        WAIT_2: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b1;
        end
        IDLE_VAL: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        DONE: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b1;
            transfer_active = 1'b1; //maybe off
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
        default: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b0;
            rx_packet = 3'b000;
            flush_and_start = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            timer_16 = 1'b0;
            timer_8 = 1'b0;
        end
    endcase
end

endmodule

