class	fa_env	extends	uvm_env;
	//Register with facotory
	`uvm_component_utils(fa_env)
	fa_agent	agent;
	fa_scoreboard	scb;

	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		agent = fa_agent	::type_id::create("agent", this);
		scb = fa_scoreboard	::type_id::create("scb", this);
	endfunction

	function void connect_phase(uvm_phase phase);
		agent.ap.connect(scb.imp);
	endfunction
endclass
