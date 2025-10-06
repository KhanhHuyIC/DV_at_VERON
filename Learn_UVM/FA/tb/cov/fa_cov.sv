class fa_cov extends uvm_subscriber #(fa_txn);
	`uvm_component_utils (fa_cov)

	covergroup cg;
		coverpoint t.a {bins low = {0}; bins high = {15}; bins mid[] = {[1:14]}; }
		coverpoint t.b {bins low = {0}; bins high = {15}; bins mid[] = {[1:14]}; }
		coverpoint t.cin {bins c0 = {0}; bins c1 = {1}; }
		cross a, b, cin;
	endgroup

	fa_txn t;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		cg = new();
	endfunction

	function void write (fa_txn tr);
		t = tr;
		cg.sample();
	endfunction

endclass
