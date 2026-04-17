onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 35 /tb_transmitter/clk
add wave -noupdate -height 35 /tb_transmitter/n_rst
add wave -noupdate -color magenta -height 35 /tb_transmitter/TX_Packet_Data
add wave -noupdate -color gold -height 35 /tb_transmitter/buffer_occupancy
add wave -noupdate -color magenta -height 35 /tb_transmitter/tx_packet
add wave -noupdate -divider Outputs
add wave -noupdate -color gold -height 35 /tb_transmitter/get_tx_packet_data
add wave -noupdate -color magenta -height 35 /tb_transmitter/tx_transfer_active
add wave -noupdate -color gold -height 35 /tb_transmitter/tx_error
add wave -noupdate -color magenta -height 35 /tb_transmitter/dp_out
add wave -noupdate -color gold -height 35 /tb_transmitter/dm_out
add wave -noupdate -color magenta -height 35 /tb_transmitter/testname
add wave -noupdate -height 35 /tb_transmitter/DUT/controller_inst/state
add wave -noupdate -height 35 /tb_transmitter/DUT/controller_inst/bit_counter
add wave -noupdate -height 35 /tb_transmitter/DUT/bit_tick
add wave -noupdate -height 35 /tb_transmitter/DUT/eop_active
add wave -noupdate -height 35 /tb_transmitter/DUT/current_bit
add wave -noupdate -height 35 /tb_transmitter/DUT/load_new_byte
add wave -noupdate -height 35 /tb_transmitter/DUT/load_byte
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {49501005750 ps}
