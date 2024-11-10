transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/tthan/Desktop/digitalquartus/24to8/db {C:/Users/tthan/Desktop/digitalquartus/24to8/db/pll_altpll.v}
vcom -93 -work work {C:/Users/tthan/Desktop/digitalquartus/24to8/i2s_transceiver.vhd}
vcom -93 -work work {C:/Users/tthan/Desktop/digitalquartus/24to8/pll.vhd}
vcom -93 -work work {C:/Users/tthan/Desktop/digitalquartus/24to8/signal_i2s.vhd}

vcom -93 -work work {C:/Users/tthan/Desktop/digitalquartus/24to8/signal_i2s_tb.vhd}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  signal_i2s_tb

add wave *
view structure
view signals
run 200 ms
