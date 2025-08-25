vlib work
vlog -sv UART_RX.v uart_rx_fsm.v
vlog -sv uart_rx_fsm.v
vlog -sv start_check.v
vlog -sv stop_check.v
vlog -sv parity_check.v
vlog -sv data_sampling.v
vlog -sv deserializer.v
vlog -sv edge_bit_counter.v
vlog -sv UART_RX_TB.v

vsim -voptargs=+acc work.uart_rx_tb
add wave *
run -all
#quit -sim