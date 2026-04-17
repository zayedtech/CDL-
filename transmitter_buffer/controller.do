onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 35 /tb_controller/clk
add wave -noupdate -height 35 /tb_controller/bit_tick
add wave -noupdate -height 35 /tb_controller/n_rst
add wave -noupdate -color Magenta -height 35 /tb_controller/tx_packet
add wave -noupdate -color gold -height 35 /tb_controller/buffer_occupancy
add wave -noupdate -color Magenta -height 35 /tb_controller/TX_Packet_Data
add wave -noupdate -divider Outputs
add wave -noupdate -color gold -height 35 /tb_controller/load_byte
add wave -noupdate -color Magenta -height 35 /tb_controller/load_new_byte
add wave -noupdate -color gold -height 35 /tb_controller/get_tx_packet_data
add wave -noupdate -color Magenta -height 35 /tb_controller/tx_transfer_active
add wave -noupdate -color gold -height 35 /tb_controller/tx_error
add wave -noupdate -color Magenta -height 35 /tb_controller/eop_active
add wave -noupdate -color gold -height 35 /tb_controller/testname
add wave -noupdate -height 35 /tb_controller/DUT/state
add wave -noupdate -height 35 /tb_controller/DUT/next_state
add wave -noupdate /tb_controller/DUT/bit_counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {40901 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {206420 ps}
