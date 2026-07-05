# =====================================================================
# SDC: correction_top
#
# Single 50 MHz synchronous clock domain. Unlike sar_adc_logic.sdc,
# there is no valid_clk / eoc_clk equivalent here -- every register in
# gain_correction, offset_correction, and correction_top itself is
# clocked directly by `clk`. adc_valid_i is just a data-domain strobe
# (sampled synchronously by clk), not a separate clock, so it gets a
# normal input delay below rather than a create_clock.
# =====================================================================

# 1. Base clock
create_clock -name clk -period 20.0 [get_ports clk]

# 2. Input delays
# rst_n is a SYNCHRONOUS active-low reset -- every always_ff checks
# `if (!rst_n)` on posedge clk, it is never asserted asynchronously --
# so it's timed as an ordinary synchronous input, not given the
# set_ideal_network / custom-tree treatment sar_adc_logic.sdc used for
# its manually-instantiated rst_root/rst_n_tree. There is no equivalent
# custom reset distribution network inside this design.
set_input_delay -clock clk 5.0 [get_ports {rst_n}]
set_input_delay -clock clk 5.0 [get_ports {calib_en_i}]
set_input_delay -clock clk 5.0 [get_ports {adc_valid_i}]
set_input_delay -clock clk 5.0 [get_ports {adc0_i[*]}]
set_input_delay -clock clk 5.0 [get_ports {adc1_i[*]}]

# 3. Output delays
# All outputs (including the debug/monitor ports) are registered on
# clk, so they all share the same single output clock -- no separate
# generated-clock constraint is needed the way sar_adc_logic needed
# eoc_clk for dout[*].
set_output_delay -clock clk 5.0 [get_ports {out_valid_o}]
set_output_delay -clock clk 5.0 [get_ports {sample_o[*]}]
set_output_delay -clock clk 5.0 [get_ports {sample_ch_o}]
set_output_delay -clock clk 5.0 [get_ports {fifo_overflow_o}]
set_output_delay -clock clk 5.0 [get_ports {gain_coeff_o[*]}]
set_output_delay -clock clk 5.0 [get_ports {gain_freeze_flag_o}]
set_output_delay -clock clk 5.0 [get_ports {offset_reg_o[*]}]

# 4. Design rules
# Same PDK / same 3.3V gf180mcu standard-cell library as sar_adc_logic,
# so the same relaxed transition/fanout targets apply here too.
set_load 0.010 [all_outputs]
set_max_transition 2.5 [current_design]
set_max_fanout 32 [current_design]

# No set_false_path / set_ideal_network entries:
#   - correction_top has no analog ports (no out_p/out_n equivalent).
#   - It has no manually-instantiated clock or reset tree to protect
#     from the resizer -- if a shared reset distribution network is
#     built at the top level across sar_adc_logic and correction_top,
#     add the equivalent set_ideal_network constraint THERE, not here.
