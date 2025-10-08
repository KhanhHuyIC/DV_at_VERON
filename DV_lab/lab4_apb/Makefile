all:
	@echo APB testing
	vlog -sv -f sim/run.f
	vsim -c	-coverage work.top_tb +VERBOSE -do "run -all; \
		coverage report -cvg -assert -stdout; \
		quit -f"
