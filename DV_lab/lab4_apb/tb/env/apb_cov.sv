import	apb_pkg::*;

class	apb_cov;
	virtual	apb_if.mon vif;
	int	ws_cnt;

	covergroup cg_apb @(posedge vif.PCLK);
		option.per_instance = 1;

		//Type of transaction
		cp_dir: coverpoint vif.PWRITE
		iff (vif.PSEL && vif.PENABLE && vif.PREADY) {
			bins	READ	= {0};
			bins	WRITE	= {1};
			}

		//The number of wait-states
		cp_wait	: coverpoint ws_cnt {
			bins	zero = {0};
			bins	one  = {1};
			bins	two  = {2};
			bins	many = {[3:15]};
			}
		cp_addr: coverpoint vif.PADDR[7:2]
		iff (vif.PSEL && vif.PENABLE && vif.PREADY){
			bins	low	= {[0:15]};
			bins	mid	= {[16:31]};
			bins	high	= {[31:63]};
			bins	other	= default;
			}
		//Error response
		cp_err:	coverpoint vif.PSLVERR
		iff (vif.PSEL && vif.PENABLE && vif.PREADY);

		//Basic cross
		x_dir_wait	: cross	cp_dir, cp_wait;
		x_dir_err	: cross cp_dir, cp_err;

	endgroup

	function new (virtual apb_if.mon vif);
		this.vif = vif;
		cg_apb	 = new();
	endfunction

	task sample ();
		static	int	cnt=0;
		if (vif.PSEL && vif.PENABLE && !vif.PREADY) cnt++;
		if (vif.PSEL && vif.PENABLE && vif.PREADY) begin
			ws_cnt = cnt; cg_apb.sample(); cnt = 0;
		end
		
		if (!vif.PSEL || !vif.PENABLE) cnt = 0;
	endtask

endclass
