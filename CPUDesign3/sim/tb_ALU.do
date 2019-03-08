vlib work

vcom -2008 "../ALU.vhd"
vcom -2008 "tb_ALU.vhd"

vsim tb_ALU

add wave *
add wave -divider
add wave /ALU_inst/*
add wave -divider

run -all
