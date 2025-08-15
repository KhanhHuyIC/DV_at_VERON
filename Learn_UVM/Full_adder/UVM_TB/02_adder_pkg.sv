package	adder_pkg;
	import	uvm_pkg::*;
	`include `"uvm_macros.svh"

//======---Transaction (sequence_item)
	class adder_item extends uvm_sequence_item;
		rand bit [15:0] a, b;
		rand bit	cin;

	//--- Data to monitor
	bit	[15:0]	sum;
	bit		cout;

	//--- Randomize constraint
	constraint c_any{}

	`uvm_object_utils_begin(adder_item)
		`uvm_field_int(a,	UVM_ALL_ON)
		`uvm_field_int(b,	UVM_ALL_ON)
		`uvm_field_int(cin,	UVM_ALL_ON)
		`uvm_field_int(sum,	UVM_NOPACK)
		`uvm_field_int(cout,	UVM_NOPACK)
	`uvm_object_utils_end

		function new(string name="adder_item");
			super.new(name);
		endfunction

	endclass

//=====---Sequence: Basic randomize
	class adder_rand_seq extends uvm_sequence #(adder_item);
		`uvm_object_untils(adder_rand_seq)
		
		function new(string name="adder_rand_seq");
			super.new(name);
		endfunction

		rand int unsigned n_trans=100;
		constraint c_n {n_trans inside {[50:500]};}

		virtual task body();
			adder_item tr;
			repeat (n_trans) begin
				`uvm_do_with(tr, {})
			end
			endtask
	endclass

//=====---Sequence: directed corner
	class adder_directed_seq extends uvm_sequence #(adder_item);
		`uvm_object_utils(adder_directed_seq)
		
		function new(string name="adder_directed_seq");
			super.new(name);
		endfunction

			//(1) all zeros
			`uvm_create(tr) tr.a=16'h0000; tr.b=16'h0000; tr.cin=0; `uvm_send(tr)
			//(2) carry ripple
			`uvm_create(tr) tr.a=16'hFFFF; tr.b=16'h0001; tr.cin=0; `uvm_send(tr)
			//(3) max+max+cin
			`uvm_create(tr) tr.a=16'hFFFF; tr.b=16'hFFFF; tr.cin=0; `uvm_sent(tr0
			//(4) randomize corner case
			foreach (int'(int i=0; i<10; i++)) begin
				`uvm_do_with(tr, {a inside {[0:65535]}; cin inside {0,1};})
			end
		endtask
	endclass

//=====--- Sequencer
	class adder_sequencer extends uvm_sequencer #(adder_item);
		`uvm_component_utils(adder_sequencer)
		function new(string name, uvm_component parent); supper.new(name, parent);
		endfunction
	endclass

//=====--- Driver
	class adder_driver extends uvm_driver #(adder_item);
		`uvm_component_utils(adder_driver)
		virtual adder_if.drv_mp vif;

		function new(string name, uvm_component parent);
			super.new(name, parent);
		endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual adder_if.drv_mp)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF", "adder_driver haven't receive the virtual interface")
		endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		adder_item tr;
		forever begin
			seq_item_port.get_next_item(tr);

			//Drive 1 state
			@(posedge vif.clk);
			if(!vif.rst_n) begin
				@(posedge vif.clk);
			end
			vif.a	<=	tr.a;
			vif.b	<=	tr.b;
			vif.cin	<=	tr.cin;

			@(posedge vif.clk);

			seq_item_port.item_done();
		end
	endtask
endclass

//=====---Monitor
class adder_monitor extends uvm_component;
	`uvm_component_utils(adder_monitor)
	virtual adder_if.mon_mp vif;
	uvm_analysis_port #(adder_item) ap;

	//Basic coverage
	covergroup cg @(posedge vif.clk);
		coverpoint vif.cin;
		coverpoint vif.a[3:0];
		coverpoint vif.b[3:0];
		coverpoint vif.cout;
		//small corss to scatch the carry
		cross cin, cout;
	endgroup

	function new(string name, uvm_component parent);
		super.new(name, parent);
		ap = new("ap", this);
		cg = new();
	endfunction

	virtual function void build_phase(uvm_phase phase);
		if (!uvm_config_db#(virtual adder_if.mon_mp)::get(this, "", "vif", vif));
		`uvm_fatal("NOVIF", "adder_monitor no receive the virtual interface")
	endfunction

	virtual task run_phase(uvm_phase phase);
		adder_item tr;
		forever begin
			@(posedge vif.clk);
			if (vif.rst_n) begin
				tr	= adder_item::type_id::create("tr_obs);
				tr.a	= vif.a;
				tr.b	= vif.b;
				tr.cin	= vif.cin;
				tr.sum	= vif.sum;
				tr.cout	= vif.cout;

