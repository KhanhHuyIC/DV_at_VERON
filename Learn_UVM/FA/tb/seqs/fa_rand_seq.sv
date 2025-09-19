class	fa_rand_seq extends fa_base_seq;
	`uvm_object_utils(fa_rand_seq)
	int unsigned num_items = 200;

	function new(string name = "fa_rand_seq");
		super.new(name);
	endfunction

