class fa_scoreboard extends uvm_component;
	//Register with factory
	`uvm_component_utils (fa_scoreboard)
	uvm_analysis_imp #(fa_txn, fa_scoreboard) imp;
	
	int unsigned n_checks, n_errors;

	//Construction
	function new(string name, uvm_component parent)
		super.new(name, parent);
	endfunction

	//Simple golden model
	function void write(fa_txn tr);
		bit	[4:0]	ref = tr.a + tr.b + tr.cin
		bit	[3:0]	exp_sum	= ref	[3:0];
		bit		exp_cout = ref	[4];

		n_checks++;

		if (tr.sum !== exp_sum || tr.out !== exp_cout) begin
			`uvm_error ("MISMATCH", $cformatf ("a=%0h b=%0h cin = %0h | got sum = %0h, exp = %0h, cout = %0h, exp = %0h",
				tr.a, tr.b, tr.cin, tr.sum, tr.exp_sum, tr.cout, tr.exp_cout);
			n_errors++;
		end
	endfunction

endclass
