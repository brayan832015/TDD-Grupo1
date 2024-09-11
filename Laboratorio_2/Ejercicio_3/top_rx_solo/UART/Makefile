#Simulación con DSim
test_rx: 
	dsim uart_rx.sv tb_uart_rx.sv +acc+b -waves waves.mxd
        
test_tx: 
	dsim uart_tx.sv tb_uart_tx.sv +acc+b -waves waves.mxd

test_uart:
	dsim  +acc+b -waves waves.mxd

clean:
	rm -f *.log
	rm -rf xsim.dir/
	rm -f *.pb
	rm -f *.jou
	rm -f *.mxd
	rm -f *.db
	rm -f *.env
	rm -f *.json
	rm -rf dsim_work
	rm -f *.fs
