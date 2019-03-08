vlib work

vcom -2008 "../Register16.vhd"
vcom -2008 "tb_Register16.vhd"

vsim tb_Register16

add wave *
add wave -divider
add wave /Register16_inst/*
add wave -divider

run -all
