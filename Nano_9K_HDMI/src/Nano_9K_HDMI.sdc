create_clock -name CLK -period 37.03 [get_ports {inclk}]
set_false_path -to [get_ports {tmds*}]
