import apb_pkg::*;

class apb_master_agent;
	virtual apb_if.MASTER vif;

	apb_gen gen;
	apb_drv drv;
	apb_mon mon;

	//mailbox to connect blocks
	mailbox #(apb_trans) gen2drv;
	mailbox #(apb_trans) mon2score;

	//Constructor
	function new(virtual apb_if.MASTER vif, mailbox #(apb_trans) mon2score, int num_transaction = 20);
		this.vif	= vif;
		this.mon2score	= mon2score;
		this.gen2drv	= new();
		this.gen	= new(this.gen2drv, num_transaction);
		this.drv	= new(this.vif, this.gen2drv);
		this.mon	= new(this.vif, this.mon2score);
	endfunction

	task run(string mode = "random");
		fork
			if (mode == "random") gen.run_random();
			else if (mode == "directed") gen.run_directed();
			else if (mode == "corner") gen.run_corner();
			drv.run();
			mon.run();
		join_none
	endtask
endclass

