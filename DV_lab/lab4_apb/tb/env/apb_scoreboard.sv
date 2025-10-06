import	apb_pkg::*;

class	apb_scoreboard;
	virtual	apb_if.mon vif;
	int	goal_txn = 200;
	int	seen_txn = 0;
	bit	done_flag = 0;
	mailbox	#(apb_txn) q;

	bit [31:0] ref_mem [bit [11:0]];

	function new(mailbox #(apb_txn) q, virtual apb_if.mon v);
		this.q = q;
		this.vif = v;
	endfunction

	//Merge bit follow the strobe signal
	function void apply_strb_write(inout bit [31:0] dst, bit [31:0] src, bit [3:0] strb);
		for (int b = 0; b < 4; b++)
			if (strb[b]) dst[8*b +: 8] = src[8*b +: 8];
	endfunction

	task run();
		apb_txn	tr;
		bit	[11:0] idx;
		bit	[11:0] key;
		forever begin
			q.get(tr);
			seen_txn++;

			idx = {tr.addr[11:2], 2'b00};
			key = tr.addr [11:2];

			if (!tr.slverr) begin
				if (tr.write) begin
					if (!ref_mem.exists(key))
						ref_mem[key] = '0;
					apply_strb_write (ref_mem[key], tr.wdata, tr.strb);
				end else begin
					if (ref_mem.exists(key)) begin
					bit [31:0] exp = ref_mem[key];
					if(tr.rdata !== exp)
							$error ("SB mismatch @0x%0h, exp = 0x%0h, got = 0x%08x", tr.addr, exp, tr.rdata);
					end
				end

				if(seen_txn >= goal_txn) begin
					done_flag = 1;
				end
			end
		end
	endtask
endclass
