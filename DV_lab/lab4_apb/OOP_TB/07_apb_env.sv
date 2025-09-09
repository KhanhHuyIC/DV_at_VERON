// 07_apb_env.sv

import apb_pkg::*;

class apb_env;
	//Virtual interface
	virtual apb_if.MASTER vif;

	//Elements
	apb_master_agent agent;
	apb_score	 score;

	//Mailbox push the transaction to scoreboard
	mailbox #(apb_trans) mon2score;

	//Constructor
	function new(virtual apb_if.MASTER vif, int num_transaction = 20);
		this.vif	= vif;
		this.mon2score	= new();
		this.agent	= new(this.vif, this.mon2score, num_transaction);
		this.score	= new(this.mon2score);
	endfunction

	//run agent and scoreboard
	task run(string mode = "random");
		fork
			agent.run(mode);
			score.run();
		join_none
	endtask

endclass
