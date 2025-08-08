import apb_pkg::*;

class apb_gen;

	//Mailbox transaction to generator
	mailbox #(apb_trans) gen2drv;
	
	//The number of transaction
	int num_transactions;

	//Constructor
	function new(mailbox #(apb_trans) gen2drv, int num_transactions = 20);
		this.gen2drv = gen2drv;
		this.num_transactions = num_transactions;
	endfunction

	//Generate random transaction
	task run_random();
		foreach (int i = 0; i < num_transactions; i) begin
			apb_trans tr = new();
			assert(tr.randomize());
			gen2drv.put(tr);
		end
	endtask

	//Generate directed transaction
	task run_directed();
		apb_trans tr;

		//step 1: write 0x12345678 to reg 3
		tr = new(APB_WRITE, 3 << 2, 32'h12345678);
		gen2drv.put(tr);

		//step 2: Read reg 3
		tr = new(APB_READ, 3 <<2);
		gen2drv.put(tr);

		//step 3: Access the unvalid address to check PSLVERR
		tr = new(APB_READ, (REG_NUM+1) << 2);
		gen2drv.put(tr);
	endtask

	//Generate corner-case transaction
	task run_corner();
		apb_trans tr;
		
		//case 1: write into the lowest address
		tr = new(APB_WRITE, 0 << 2, 32'hDEADADDD);
		gen2drv.put(tr);

		//case 2: write into the highest address
		tr = new(APB_WRITE, (REG_NUM-1)<<2, 32'hFEADADDD);
		gen2drv.put(tr);

		//case 3: read from the lowest address
		tr = new(APB_READ, 0 << 2);
		gen2drv.put(tr);

		//case 4: read from the highest address
		tr = new(APB_READ, (REG_NUM-1)<<2);
		gen2drv.put(tr);

		//case 5: write/read corner data: all 0s
		tr = new(APB_WRITE, 1 << 2, 32'h00000000);
		gen2drv.put(tr);
		tr = new(APB_READ, 1 << 2);
		gen2drv.put(tr);
	endtask

endclass
