onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider System
add wave -noupdate /tb_usb_rx/clk
add wave -noupdate /tb_usb_rx/n_rst
add wave -noupdate -divider Inputs
add wave -noupdate -color Gold /tb_usb_rx/dp_in
add wave -noupdate -color Gold /tb_usb_rx/dm_in
add wave -noupdate -color Gold -radix unsigned /tb_usb_rx/buffer_occupancy
add wave -noupdate -divider Outputs
add wave -noupdate -color Magenta /tb_usb_rx/rx_data_ready
add wave -noupdate -color Magenta /tb_usb_rx/rx_transfer_active
add wave -noupdate -color Magenta /tb_usb_rx/rx_error
add wave -noupdate -color Magenta /tb_usb_rx/flush
add wave -noupdate -color Magenta /tb_usb_rx/store_rx_packet_data
add wave -noupdate -color Magenta /tb_usb_rx/rx_packet
add wave -noupdate -color Magenta -radix binary /tb_usb_rx/rx_packet_data
add wave -noupdate -divider {Test Cases}
add wave -noupdate /tb_usb_rx/test_name
add wave -noupdate -divider Internal
add wave -noupdate /tb_usb_rx/DUT/CFSM/state
add wave -noupdate -radix binary /tb_usb_rx/DUT/parallel_out
add wave -noupdate /tb_usb_rx/DUT/CFSM/pid_error
add wave -noupdate /tb_usb_rx/DUT/CFSM/data_err
add wave -noupdate /tb_usb_rx/DUT/CFSM/token_err
add wave -noupdate /tb_usb_rx/DUT/CFSM/sync_err
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {355000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 180
configure wave -valuecolwidth 233
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
WaveRestoreZoom {0 ps} {1465218 ps}
