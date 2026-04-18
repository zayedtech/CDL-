onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider input
add wave -noupdate -label clk -radix binary /tb_ahb_subordinate_usb/DUT/clk
add wave -noupdate -label rst -radix binary /tb_ahb_subordinate_usb/DUT/n_rst
add wave -noupdate -label hsel -radix binary /tb_ahb_subordinate_usb/DUT/hsel
add wave -noupdate -label hwrite -radix hexadecimal /tb_ahb_subordinate_usb/DUT/hwrite
add wave -noupdate -label haddr -radix binary /tb_ahb_subordinate_usb/DUT/haddr
add wave -noupdate -label hsize -radix binary /tb_ahb_subordinate_usb/DUT/hsize
add wave -noupdate -label hburst -radix binary /tb_ahb_subordinate_usb/DUT/hburst
add wave -noupdate -label htrans -radix binary /tb_ahb_subordinate_usb/DUT/htrans
add wave -noupdate -label rx_packet -radix binary /tb_ahb_subordinate_usb/DUT/rx_packet
add wave -noupdate -label rx_data_ready -radix binary /tb_ahb_subordinate_usb/DUT/rx_data_ready
add wave -noupdate -label rx_transfer_active -radix binary /tb_ahb_subordinate_usb/DUT/rx_transfer_active
add wave -noupdate -label rx_error -radix binary /tb_ahb_subordinate_usb/DUT/rx_error
add wave -noupdate -label rx_data -radix binary /tb_ahb_subordinate_usb/DUT/rx_data
add wave -noupdate -label buffer_occupancy -radix binary /tb_ahb_subordinate_usb/DUT/buffer_occupancy
add wave -noupdate -label tx_transfer_active -radix binary /tb_ahb_subordinate_usb/DUT/tx_transfer_active
add wave -noupdate -label tx_error -radix binary /tb_ahb_subordinate_usb/DUT/tx_error
add wave -noupdate -label hwdata -radix hexadecimal /tb_ahb_subordinate_usb/DUT/hwdata
add wave -noupdate -divider output
add wave -noupdate -label hrdata -radix hexadecimal /tb_ahb_subordinate_usb/DUT/hrdata
add wave -noupdate -label hresp -radix binary /tb_ahb_subordinate_usb/DUT/hresp
add wave -noupdate -label hready -radix binary /tb_ahb_subordinate_usb/DUT/hready
add wave -noupdate -label get_rx_data -radix binary /tb_ahb_subordinate_usb/DUT/get_rx_data
add wave -noupdate -label store_tx_data -radix binary /tb_ahb_subordinate_usb/DUT/store_tx_data
add wave -noupdate -label tx_data -radix binary /tb_ahb_subordinate_usb/DUT/tx_data
add wave -noupdate -label tx_packet -radix binary /tb_ahb_subordinate_usb/DUT/tx_packet
add wave -noupdate -label d_mode -radix binary /tb_ahb_subordinate_usb/DUT/d_mode
add wave -noupdate -label clear -radix binary /tb_ahb_subordinate_usb/DUT/clear
add wave -noupdate -label {test name} -radix symbolic /tb_ahb_subordinate_usb/test_name
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {348049 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 366
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {12360 ps}
