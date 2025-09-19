class	fa_sequencer	extends	uvm_sequencer #(fa_txn);
	//Register with factory
	`uvm_component_utils	(fa_sequencer)
	function	new	(sttring name, uvm_component parent);
		super.new(name, parent);
	endfunction

endclass
