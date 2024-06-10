# VHDL Sources
DATATYPES = small_pSquare_data_types.vhd
SOURCES = AddModMersenne.vhd small_pSquare_ENC+DEC.vhd SquModMersenne.vhd SubModMersenne.vhd

# VHDL Testbenches
TESTBENCH = TB_small_pSquare
TESTBENCHPATH = Testbenches/${TESTBENCH}.vhd

# General Flags
WORKDIR = work
GHDL_FLAGS = --workdir=$(WORKDIR)

# Flags for simulation
GHDL_SIM_FLAGS = --stop-time=10ms --ieee-asserts=disable-at-0

all: clean make sim

clean:
	@rm -rf $(WORKDIR)
	@ghdl --clean
	
make:
	@mkdir -p $(WORKDIR)
	@ghdl -a $(GHDL_FLAGS) $(DATATYPES)
	@ghdl -a $(GHDL_FLAGS) $(SOURCES)
	@ghdl -a $(GHDL_FLAGS) $(TESTBENCHPATH)
	@ghdl -e $(GHDL_FLAGS) $(TESTBENCH)

sim:
	@ghdl -r $(GHDL_FLAGS) $(TESTBENCH) $(GHDL_SIM_FLAGS)