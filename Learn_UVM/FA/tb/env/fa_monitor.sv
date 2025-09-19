class fa_monitor extends uvm_component;
	`uvm_component_utils (fa_monitor)
	virtual fa_if.MON vif;
	uvm_analysis_port	#(fa_txn) ap;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual fa_if MON)::get(this,"","vif", vif))
			`uvm_fatal("NOVIF","fa_if not set for monitor");
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
			@(vif.mon_cb);
			fa_txn	tr = new();
			tr.a	=	vif.mon_cb.a;
			tr.b	=	vif.mon_cb.b;
			tr.cin	=	vif.mon_cb.cin;
			tr.sum	=	vif.mon_cb.sum;
			tr.cout	=	vif.mon_cb.cout;
			ap.write (tr);
		end
	endtask

endclass
