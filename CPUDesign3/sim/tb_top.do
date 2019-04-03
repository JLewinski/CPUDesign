vlib work

vcom -2008 "../Register16.vhd"
vcom -2008 "../InstructionMemory.vhd"
vcom -2008 "../Control.vhd"
vcom -2008 "../Mux_2_To_1.vhd"
vcom -2008 "../RegisterMemory.vhd"
vcom -2008 "../ALU.vhd"
vcom -2008 "../top.vhd"
vcom -2008 "tb_top.vhd"

vsim tb_top

add wave *
add wave -divider
add wave /top_inst/*
add wave -divider

run -all
