onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_data_buffer/clk
add wave -noupdate /tb_data_buffer/n_rst
add wave -noupdate -divider Input
add wave -noupdate -color magenta -height 30 /tb_data_buffer/flush
add wave -noupdate -color gold -height 30 /tb_data_buffer/get_rx_data
add wave -noupdate -color magenta -height 30 /tb_data_buffer/store_tx_data
add wave -noupdate -color gold -height 30 /tb_data_buffer/clear
add wave -noupdate -color magenta -height 30 /tb_data_buffer/get_tx_packet_data
add wave -noupdate -color gold -height 30 /tb_data_buffer/rx_packet_data
add wave -noupdate -color magenta -height 30 /tb_data_buffer/store_rx_packet_data
add wave -noupdate -color gold -height 30 /tb_data_buffer/tx_data
add wave -noupdate -divider Output
add wave -noupdate -color cyan -height 30 /tb_data_buffer/rx_data
add wave -noupdate -height 30 /tb_data_buffer/tx_packet_data
add wave -noupdate -color cyan -height 30 -radix decimal /tb_data_buffer/buffer_occupancy
add wave -noupdate -height 30 /tb_data_buffer/testname
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {829705 ps} 0}
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
WaveRestoreZoom {713323 ps} {843614 ps}
