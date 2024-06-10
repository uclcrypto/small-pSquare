# VHDL Sources
DATATYPES = small_pSquare_data_types.vhd
SOURCES = AddModMersenne.vhd FF.vhd MatrixMult_RC.vhd MatrixMult.vhd MulAddAddModMersenne.vhd MulAddModMersenne.vhd MulSubAddModMersenne.vhd MulSubModMersenne.vhd MulSubSubModMersenne.vhd small_pSquare_2SHARES.vhd small_pSquare_3SHARES.vhd small_pSquare_4SHARES.vhd SQ_2SHARE.vhd SQ_3SHARE.vhd SQ_4SHARE.vhd SquSubModMersenne.vhd SubModMersenne.vhd

# VHDL Testbenches
TESTBENCH = TB_small_pSquare
TESTBENCHPATH = Testbenches/${TESTBENCH}

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
	@ghdl -a $(GHDL_FLAGS) $(TESTBENCHPATH)_2SHARES.vhd
	@ghdl -a $(GHDL_FLAGS) $(TESTBENCHPATH)_3SHARES.vhd
	@ghdl -a $(GHDL_FLAGS) $(TESTBENCHPATH)_4SHARES.vhd
	@ghdl -e $(GHDL_FLAGS) $(TESTBENCH)_2SHARES
	@ghdl -e $(GHDL_FLAGS) $(TESTBENCH)_3SHARES
	@ghdl -e $(GHDL_FLAGS) $(TESTBENCH)_4SHARES

sim:
	@ghdl -r $(GHDL_FLAGS) $(TESTBENCH)_2SHARES $(GHDL_SIM_FLAGS)
	@ghdl -r $(GHDL_FLAGS) $(TESTBENCH)_3SHARES $(GHDL_SIM_FLAGS)
	@ghdl -r $(GHDL_FLAGS) $(TESTBENCH)_4SHARES $(GHDL_SIM_FLAGS)