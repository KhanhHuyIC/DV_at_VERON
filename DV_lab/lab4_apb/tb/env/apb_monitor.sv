import	apb_pkg::*;

class	apb_monitor;
	virtual	apb_if.mon	vif;
	apb_cov cov;
	mailbox	#(apb_txn) mon2cb;

	function new(virtual apb_if.mon v, mailbox #(apb_txn) q);
		vif	=	v;
		mon2sb	= 	q;
		cov	=	new(vif);
	endfunction

	task run();
		apb_txn	tr;
		forever begin
			@(posedge vif.PCLK);
			cov.sample();
			if (vif.PSEL && vif.PENABLE && vif.PREADY) begin
				tr = new();
				tr.write = vif.PWRITE;
				tr.addr	 = vif.PADDR;
				tr.wdata = vif.PWDATA;
				tr.strb	 = vif.PSTRB;
				tr.rdata = vif.PRDATA;
				tr.slverr = vif.PSLVERR;
				mob2sb.put(tr);
			end
		end
	endtask
endclass
