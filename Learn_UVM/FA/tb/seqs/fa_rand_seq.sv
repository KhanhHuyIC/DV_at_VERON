class	fa_rand_seq extends fa_base_seq;
	`uvm_object_utils(fa_rand_seq)
	int unsigned num_items = 200;

	function new(string name = "fa_rand_seq");
		super.new(name);
	endfunction

	task body();
		repeat (num_items) begin
			fa_txn	tr = fa_txn::type_id::create("tr");
			assert(tr.randomize());
			start_item(tr);
			finish_item(tr);
		end
	endtask

endclass
