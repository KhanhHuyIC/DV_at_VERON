class fa_agent extends uvm_agent;
	`uvm_component_utils (fa_agent)
	fa_sequencer	sqr;
	fa_driver	drv;
	fa_monitor	mon;

	uvm_analysis_port #(fa_txn) ap;

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		sqr = fa_sequencer	::type_id::create("sqr", this);
		drv = fa_driver		::type_id::create("drv", this);
		mon = fa_monitor	::type_id::create("mon", this);
	endfunction

	function void connect_phase(uvm_phase phase)
		super.connect_phase(phase);
		mon.ap.connect(ap);
		drv.seq_item_port.connect(sqr.seq_item_export);
	endfunction

endclass
