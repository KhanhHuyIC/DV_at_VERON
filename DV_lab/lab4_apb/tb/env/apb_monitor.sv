import	apb_pkg::*;
`include "apb_cov.sv"

class	apb_monitor;
	virtual	apb_if.mon vif;
	apb_cov cov;
	mailbox	#(apb_txn) mon2sb;
	bit	verbose	= 0;
	integer	mon_log;

	function new(virtual apb_if.mon v, mailbox #(apb_txn) q);
		vif	=	v;
		mon2sb	= 	q;
		cov	=	new(vif);
		if ($test$plusargs("VERBOSE")) verbose = 1;
		if (verbose)
			mon_log = $fopen("monitor.log","w");
	endfunction

	task run();
		apb_txn	tr;
		forever begin
			@(posedge vif.PCLK);
			cov.sample();
			if (vif.PSEL && vif.PENABLE && vif.PREADY) begin
				tr		= new();
				tr.write	= vif.PWRITE;
				tr.addr		= vif.PADDR;
				tr.wdata	= vif.PWDATA;
				tr.strb		= vif.PSTRB;
				tr.rdata	= vif.PRDATA;
				tr.slverr	= vif.PSLVERR;
				mon2sb.put(tr);
				
				if (verbose) begin
					$display("[MON] [%0t] %s addr = 0x%03h, wdata = 0x%08x, rdata = 0x%08x, strb = %0h, err = %0b",
						$time, (tr.write?"WR":"RD"), tr.addr, tr.wdata, tr.rdata, tr.strb, tr.slverr);
				end
			end
		end
	endtask
endclass
