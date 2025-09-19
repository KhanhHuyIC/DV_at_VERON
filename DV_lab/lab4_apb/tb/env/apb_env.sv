import	apb_pkg::*;

class	apb_env;
	apb_agent	agent;
	apb_scoreboard	sb;

	mailbox	#(apb_txn) mon2sb;

	function new(virtual apb_if.drv vd, virtual apb_if.mon vm, int n_txn);
		mon2sb	= new();
		agent	= new(vd, vm, mon2sb);
		sb	= new(mon2sb, vm);

		agent.gen.n_txn	= n_txn;
		sb.goal_txn	= n_txn;
	endfunction

	task run();
		fork
			agent.run();
			sb.run();
		join_none
	endtask

endclass
