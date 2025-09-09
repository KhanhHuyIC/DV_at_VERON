//00_apb_pkg.sv
package apb_pgk;

	//PARAMETERs
	parameter int	ADDR_WIDTH	= 16;
	parameter int	DATA_WIDTH	= 32;
	parameter int	REG_NUM		= 8;

	//TYPEDEF
	typedef logic [ADDR_WIDTH-1:0]		apb_addr_t;
	typedef logic [DATA_WIDTH-1:0]		apb_data_t;
	typedef logic [$clog2(REG_NUM)-1:0]	apb_reg_addr_t;

	//ENUM
	typedef enum logic{
		APB_READ,
		APB_WRITE
		} apb_op_t;

	//CLASS
	class apb_trans;
		//Fields
		rand 	apb_op_t	op;	//READ/WRITE
		rand 	apb_addr_t	addr;	//Address of transaction
		rand 	apb_data_t	wdata;	//The write data
			apb_data_t	rdata;	//The read data
			bit		err;	//Error flag
		//Constructor
		function new(apb_op_t op = APB_WRITE, apb_addr_t addr = 0, apb_data_t wdata = 0);
			this.op		= op;
			this.addr	= addr;
			this.wdata	= wdata;
			this.rdata	= '0;
			this.err	= 0;
		endfunction

		//Randomization constraints:
		constraint addr_valid {addr < REG_NUM << 2; }
	endclass
endpackage
