#set_property PACKAGE_PIN D16 [get_ports led_1]
#set_property IOSTANDARD LVCMOS33 [get_ports led_1]
set_property PACKAGE_PIN M2 [get_ports led_2]
set_property IOSTANDARD LVCMOS33 [get_ports led_2]
set_property PACKAGE_PIN J5 [get_ports led_3]
set_property IOSTANDARD LVCMOS33 [get_ports led_3]
#set_property PACKAGE_PIN J6 [get_ports led_4]
#set_property IOSTANDARD LVCMOS33 [get_ports led_4]
set_property PACKAGE_PIN L2 [get_ports led_5]
set_property IOSTANDARD LVCMOS33 [get_ports led_5]
set_property PACKAGE_PIN K2 [get_ports led_6]
set_property IOSTANDARD LVCMOS33 [get_ports led_6]

set_property PACKAGE_PIN R2 [get_ports clk_50MHz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_50MHz]

#SW5
set_property PACKAGE_PIN D16 [get_ports rst_btn]
set_property IOSTANDARD LVCMOS33 [get_ports rst_btn]

#SW1
set_property PACKAGE_PIN J4 [get_ports freq_up_btn]
set_property IOSTANDARD LVCMOS33 [get_ports freq_up_btn]

#SW2
set_property PACKAGE_PIN K6 [get_ports freq_down_btn]
set_property IOSTANDARD LVCMOS33 [get_ports freq_down_btn]

#SW3
set_property PACKAGE_PIN L3 [get_ports shift_up_btn]
set_property IOSTANDARD LVCMOS33 [get_ports shift_up_btn]

#SW4
set_property PACKAGE_PIN K1 [get_ports shift_down_btn]
set_property IOSTANDARD LVCMOS33 [get_ports shift_down_btn]

set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[13]}]

set_property IOSTANDARD LVCMOS33 [get_ports dac_clk]


set_property PACKAGE_PIN G17 [get_ports {dac_data[0]}]
set_property PACKAGE_PIN F18 [get_ports {dac_data[1]}]
set_property PACKAGE_PIN F17 [get_ports {dac_data[2]}]
set_property PACKAGE_PIN E18 [get_ports {dac_data[3]}]
set_property PACKAGE_PIN E17 [get_ports {dac_data[4]}]
set_property PACKAGE_PIN D18 [get_ports {dac_data[5]}]
set_property PACKAGE_PIN C18 [get_ports {dac_data[6]}]
set_property PACKAGE_PIN C17 [get_ports {dac_data[7]}]
set_property PACKAGE_PIN H16 [get_ports {dac_data[8]}]
set_property PACKAGE_PIN G15 [get_ports {dac_data[9]}]
set_property PACKAGE_PIN G16 [get_ports {dac_data[10]}]
set_property PACKAGE_PIN F15 [get_ports {dac_data[11]}]
set_property PACKAGE_PIN E15 [get_ports {dac_data[12]}]
set_property PACKAGE_PIN E16 [get_ports {dac_data[13]}]

set_property PACKAGE_PIN D15 [get_ports dac_clk]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]


#set_property PULLTYPE PULLDOWN [get_ports led_1]
set_property PULLTYPE PULLDOWN [get_ports led_2]
set_property PULLTYPE PULLDOWN [get_ports led_3]
#set_property PULLTYPE PULLDOWN [get_ports led_4]
set_property PULLTYPE PULLDOWN [get_ports led_5]
set_property PULLTYPE PULLDOWN [get_ports led_6]
set_property PULLTYPE PULLDOWN [get_ports rst_btn]
set_property PULLTYPE PULLDOWN [get_ports shift_down_btn]
set_property PULLTYPE PULLDOWN [get_ports shift_up_btn]
set_property PULLTYPE PULLDOWN [get_ports freq_down_btn]
set_property PULLTYPE PULLDOWN [get_ports freq_up_btn]
