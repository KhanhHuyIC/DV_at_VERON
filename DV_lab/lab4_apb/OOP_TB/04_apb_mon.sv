import apb_pkg::*;

class apb_mon;
	//Virtual interface to connect with DUT
	virtual apb_if.MASTER vif;

	//Mailbox to trans the transaction to scoreboard
	mailbox #(apb_trans) mon2score;

	//Constructor
	function new(virtual apb_if.MASTER vif, mailbox #(apb_trans) mon2score);
		this.vif	= vif;
		this.mon2score	= mon2score;
	endfunction

	//Monitor task
	task run();
		apb_trans tr;
		forever begin
			@(posedge vif.PCLK);
			if (vif.PSEL && vif.PENABLE && vif.PREADY) begin
				tr = new();

				//monitor the transaction
				tr.op	= vif.PWRITE ? APB_WRITE : APB_READ;
				tr.addr	= vif.PADDR;
				tr.wdata = vif.PWDATA;
				tr.err = vif.PSLVERR;

				//Read --> monitor the read data
				if (tr.op == APB_READ)
					tr.rdata = vif.PRDATA;

				//put the transaction to mailbox
				mon2score.put(tr);
			end
		end
	endtask

endclass

