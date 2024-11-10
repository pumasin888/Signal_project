transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/New_Asgard/vs_code/signal_project/fir8bit/db {D:/New_Asgard/vs_code/signal_project/fir8bit/db/pll_altpll.v}
vcom -93 -work work {D:/New_Asgard/vs_code/signal_project/fir8bit/i2s_transceiver.vhd}
vcom -93 -work work {D:/New_Asgard/vs_code/signal_project/fir8bit/uart_transmitter.vhd}
vcom -93 -work work {D:/New_Asgard/vs_code/signal_project/fir8bit/top.vhd}
vcom -93 -work work {D:/New_Asgard/vs_code/signal_project/fir8bit/baudrate_generator.vhd}
vcom -93 -work work {D:/New_Asgard/vs_code/signal_project/fir8bit/pll.vhd}
vcom -93 -work work {D:/New_Asgard/vs_code/signal_project/fir8bit/signal_i2s.vhd}

vcom -93 -work work {D:/New_Asgard/vs_code/signal_project/fir8bit/tb_top.vhd}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_top

add wave *
view structure
view signals
run -all
