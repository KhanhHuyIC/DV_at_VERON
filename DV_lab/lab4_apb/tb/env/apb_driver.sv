import	apb_pkg::*;

class	apb_driver;
	virtual	apb_if.drv	vif;
	mailbox	#(apb_txn)	gen2drv;

	function new(virtual apb_if.drv v, mailbox #(apb_txn) m);
		vif = v;
		gen2drv = m;
	endfunction

	task drive_reset();
		vif.cb.PSEL	<= 0;
		vif.cb.PENABLE	<= 0;
		vif.cb.PWRITE	<= 0;
		vif.cb.PADDR	<= 0;
		vif.cb.PWDATA	<= '0;
		vif.cb.PSTRB	<= '0;
		vif.cb.PPROT	<= '0;
		@(vif.cb);
	endtask

	task run();
		apb_txn	tr;
		forever begin
			gen2drv.get(tr);
			//SETUP
			@(vif.cb);
			vif.cb.PSEL	<= 1;
			vif.cb.PENABLE	<= 0;
			vif.cb.PWRITE	<= tr.write;
			vif.cb.PADDR	<= tr.addr;
			vif.cb.PWDATA	<= tr.wdata;
			vif.cb.PSTRB	<= tr.strb;

			//ACCESS
			vif.cb.PENABLE	<= 1;
			//wait for PREADY = 1
			do @(vif.cb); while (!vif.PREADY);

			//TEARDOWN
			@(vif.cb);
			vif.cb.PSEL	<= 0;
			vif.cb.PENABLE	<= 0;
		end
	endtask
endclass
