vlib work

vcom -2008 "../Mux_2_To_1.vhd"
vcom -2008 "tb_Mux_2_To_1.vhd"

vsim tb_Mux_2_To_1

add wave *
add wave -divider
add wave /Mux_2_To_1_inst/*
add wave -divider

run -all
