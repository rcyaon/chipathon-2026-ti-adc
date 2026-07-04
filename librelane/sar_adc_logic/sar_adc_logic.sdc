create_clock -name clk_i -period 40.0 [get_ports clk_i]

create_clock -name valid_clk -period 5.0 [get_pins valid_clk_xor/Z]

set_clock_groups -asynchronous -group {clk_i} -group {valid_clk}

set_input_delay -clock clk_i 5.0 [get_ports {rst_n}]

set_false_path -from [get_ports {out_p out_n}]

set_output_delay -clock clk_i 5.0 [get_ports {dac_ctrl[*] dout[*] clk_o clk_o_n}]

set_load 0.010 [all_outputs]
set_max_transition 1 [current_design]
set_max_fanout 16 [current_design]