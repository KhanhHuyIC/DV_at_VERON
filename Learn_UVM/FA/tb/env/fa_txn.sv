class	fa_txn	extends uvm_sequence_item;
	
	rand bit [3:0] a, b;
	rand bit	cin;

	bit	[3:0] sum;
	bit	cout;

	//Register with factory
	`uvm_object_utils_begin (fa_txn)
		`uvm_field_int	(a, UVM_ALL_ON)
		`uvm_field_int	(b. UVM_ALL_ON)
		`uvm_field_int	(cin, UVM_ALL_ON)
		`uvm_field_int	(sum, UVM_NOPACK)
		`uvm_field_int	(cout, UVM_NOPACK)
	`uvm_object_utils_end

	//Constraint
	constraint	c_default {}

	function new (string name = "fa_txn");
		super.new(name);
	endfunction

endclass
