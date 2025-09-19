package	apb_tb_pkg;

//=====Transaction=====
class apb_txn;
	rand	bit	write;
	rand	bit	[11:0]	addr;
	rand	bit	[31:0]	wdata;
	rand	bit	[3:0]	strb;

	bit	[31:0]	rdata;
	bit		slverr;

	constraint c_align {addr[1:0] == 2'b00;}
	function string	sprint();
		return	$sformatf("APB %s @0x%0h W=0x%0h STRB=%0h", write?"WR":"RD", addr, wdata, strb);
	endfunction

endclass

endpackage
