##########################################
# SDC Constraints for RTL Design
# Technology: Nangate 45nm
# Tool: OpenROAD
# Clock: PCLK = 0.5ns (~2.0GHz)
##########################################

# 1. Create the main clock
set clk_name PCLK
set clk_port_name PCLK
set clk_period 0.5 ;# unit: ns (nanoseconds)

set clk_port [get_ports $clk_port_name]
create_clock -name $clk_name -period $clk_period $clk_port
# → This is the primary clock used for timing reference.

# 2. Set input and output delays
# Assumption: IO delay is 10% of clock period = 0.0454ns
set clk_io_pct 0.1
set input_delay_val  [expr $clk_period * $clk_io_pct]
set output_delay_val [expr $clk_period * $clk_io_pct]

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]
set_input_delay  $input_delay_val  -clock $clk_name $non_clock_inputs
set_output_delay $output_delay_val -clock $clk_name [all_outputs]
# → This assumes external logic contributes a small and consistent delay.

# 3. Set input transition (slew) instead of defining a driving cell
# Assume external inputs have 50ps rise/fall transition time
set_input_transition 0.05 $non_clock_inputs
# → This avoids dependency on specific library cells and gives reasonable transition estimates.

# 4. Define output load for output ports
set_load 0.05 [all_outputs]
# → 50fF is a typical load value for general-purpose IOs. Adjust if needed.

# 5. Set clock uncertainty (to model jitter, skew, and PVT variations)
set_clock_uncertainty 0.03 [get_clocks $clk_name]
# → 30ps is a common and safe margin for 45nm technology.

# 6. Ignore asynchronous reset paths in timing analysis
# Uncomment if reset_n is async and not clocked by PCLK:
set_false_path -from [get_ports {PRESETn}]
# → Prevents incorrect timing violations on asynchronous control signals.
