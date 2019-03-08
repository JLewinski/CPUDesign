vlib work

vcom -2008 "../Control.vhd"
vcom -2008 "tb_Control.vhd"

vsim tb_Control

add wave *
add wave -divider
add wave /Control_inst/*
add wave -divider

run -all
