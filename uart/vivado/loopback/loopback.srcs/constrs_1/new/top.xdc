 # Clock signal
 set_property PACKAGE_PIN W5 [get_ports clk]
 	set_property IOSTANDARD LVCMOS33 [get_ports clk]
 	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
 
 #Buttons
 set_property PACKAGE_PIN U18 [get_ports reset]
 	set_property IOSTANDARD LVCMOS33 [get_ports reset]
 
 #USB-RS232 Interface
 set_property PACKAGE_PIN B18 [get_ports rx]
 	set_property IOSTANDARD LVCMOS33 [get_ports rx]
 set_property PACKAGE_PIN A18 [get_ports tx]
 	set_property IOSTANDARD LVCMOS33 [get_ports tx]
 
 ## Configuration options, can be used for all designs
 set_property CONFIG_VOLTAGE 3.3 [current_design]
 set_property CFGBVS VCCO [current_design]
