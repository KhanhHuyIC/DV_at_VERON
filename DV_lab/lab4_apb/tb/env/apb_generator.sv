import	apb_pkg::*;

class	apb_generator;
	mailbox #(apb_txn) gen2drv;
	int	n_txn	 = 200;
	int	wr_ratio = 50;
	bit	[11:0]	addr_lo = 12'h000;
	bit	[11:0]	addr_hi	= 12'h3FF;

	function new(mailbox #(apb_txn) m);
		gen2drv	= m;
	endfunction

	//Choose the ratio of writing
	function automatic bit pick_write (int ratio_percent);
		int	p = $urandom % 100;
		return	(p < ratio_percent);
	endfunction

	//Choose the strobe: 70% full workd, 30% divide into 0x1/0x3/0xC
	function automatic [3:0] pick_strb();
		int	p = $urandom %100;
		if	(p < 70) begin
			return 4'hF;
		end else begin
			case ($urandom %3)
				0: return 4'h1;
				1: return 4'h3;
				default: return 4'hC;
			endcase
		end
	endfunction

	//Generate the word-aligned address in [addr_lo ... addr_hi]
	function automatic [11:0] pick_addr ();
		int	unsigned	lo_w	= addr_lo >> 2;
		int	unsigned	hi_w	= addr_hi >> 2;
		int	unsigned	wa;
		logic	[9:0]		wa10;
		
		if (hi_w >= lo_w) wa = $urandom_range (hi_w, lo_w);
		else		 wa = lo_w;

		wa10 = wa [9:0];
		return	{wa10, 2'b00};
	endfunction

	task run();
		repeat (n_txn) begin
			apb_txn	t = new();

			t.write	 = pick_write (wr_ratio);
			t.addr	 = pick_addr();
			t.wdata	 = $urandom;
			t.strb	 = pick_strb();

			gen2drv.put(t);
		end
	endtask
endclass
