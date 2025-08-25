vlib work
vlog UART_RX.sv uart_rx_fsm.sv
vlog uart_rx_fsm.sv
vlog start_check.sv
vlog stop_check.sv
vlog parity_check.sv
vlog data_sampling.sv
vlog deserializer.sv
vlog edge_bit_counter.sv
vlog UART_RX_TB.sv

vsim -voptargs=+acc work.uart_rx_tb
add wave *
run -all
#quit -sim