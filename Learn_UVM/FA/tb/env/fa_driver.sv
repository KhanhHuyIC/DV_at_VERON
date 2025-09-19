class fa_driver extends uvm_driver #(fa_txn);

	//Register with factory
	`uvm_component_utils (fa_driver)
	virtual fa_if.DRV vif;

	//Constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase (uvm_phase phase)
		super.build_phase (phase);
		if (!uvm_config_db#(virtual fa_if.DRV)::get(this,"", "vif", vif))
		`uvm_fatal("NOVIF", "fa_if not set for driver");
	endfunction

	task	run_phase (uvm_phase phase);
		fa_txn	tr;
		forever	begin
			seq_item_port.get_next_item(tr);
			//drive on next posedge
			@(vif.drv_cb);
			vif.drv_cb.a	<=	tr.a;
			vif.drv_cb.b	<=	tr.b;
			vif.drv_cb.cin	<=	tr.cin;
			seq_item_port.item_done();
		end
	endtask

endclass
