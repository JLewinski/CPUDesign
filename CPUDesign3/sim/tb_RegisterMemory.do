vlib work

vcom -2008 "../RegisterMemory.vhd"
vcom -2008 "tb_RegisterMemory.vhd"

vsim tb_RegisterMemory

add wave *
add wave -divider
add wave /RegisterMemory_inst/*
add wave -divider

run -all
