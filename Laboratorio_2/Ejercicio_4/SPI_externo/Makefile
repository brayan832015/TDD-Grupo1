BOARD  = tangnano9k
FAMILY = GW1N-9C
DEVICE = GW1NR-LV9QN88PC6/I5

#Nombre del proyecto
PROYECT = SPI_lcd

#Fuentes de diseno
SOURCES := $(wildcard src/*.v src/*.sv) #Todas las fuentes .v o .sv que estan en src

# Constraints para el proyecto
#aca va el archivo de constraints del proyecto
CONSTRAINTS = cst/tangnano9k.cst

#el top se indica sin la extension .v, esto hace referencia al nombre que le pusieron al módulo y no al archivo en si.
TOP_DESIGN = top


all: synth pnr bitstream 

# Synthesis
synth: ${SOURCES}
	echo "Ejecutando la sintesis..."
	yosys -p "read_verilog -sv ${SOURCES}; synth_gowin -top ${TOP_DESIGN} -json ${PROYECT}.json" > synthesis_${BOARD}.log 2>&1 
	echo "COMPLETADO"

# Place and Route
pnr: ${PROYECT}.json
	echo "Ejecutando el pnr..."
	nextpnr-gowin --json ${PROYECT}.json --write ${PROYECT}_pnr.json --freq 27 --device ${DEVICE} --family ${FAMILY} --cst ${CONSTRAINTS} > pnr_${BOARD}.log 2>&1 
	echo "COMPLETADO"

# Generar el Bitstream
bitstream: ${PROYECT}_pnr.json
	echo "Generando ${PROYECT}_${BOARD}.fs"
	gowin_pack -d ${FAMILY} -o ${PROYECT}_${BOARD}.fs ${PROYECT}_pnr.json
	echo "COMPLETADO"
		
#Simulación con DSim
test: 
	dsim src/clock_divider.sv src/FSM.sv src/spi.sv src/top.sv src/uart_rx.sv sim/tb.sv +acc+b -waves waves.mxd
        
# Cargar el bitstream en la FPGA
load: ${PROYECT}_${BOARD}.fs
	openFPGALoader -b ${BOARD} ${PROYECT}_${BOARD}.fs 

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
	

.PHONY: load  wv
.INTERMEDIATE: ${PROYECT}_pnr.json ${PROYECT}.json