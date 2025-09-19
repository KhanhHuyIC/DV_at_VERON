import	apb_pkg::*;

class	apb_agent;
	//Components
	apb_generator	gen;
	apb_driver	drv;
	apb_monitor	mon;

	//Interface
	virtual	apb_if.drv vif_drv;
	virtual	apb_if.mon vif_mon;

	//Mailboxes
	mailbox	#(apb_txn) gen2drv;
	mailbox #(apb_txn) mon2drv;

	function new(virtual apb_if.drv vd, virtual apb_if.mon vm, mailbox #(apb_txn) m2s);
		vif_drv = vd;
		vif_mon = vm;
		mon2sb	= m2s;
		gen2drv	= new();
		gen	= new(gen2drv);
		drv	= new(vif_drv, gen2drv);
		mon	= new(vif_mon, mon2sb);
	endfunction

	task run();
		fork
			drv.drive_reset();
			drv.run();
			mon.run();
			gen.run();
		join_none
	endtask
endclass
