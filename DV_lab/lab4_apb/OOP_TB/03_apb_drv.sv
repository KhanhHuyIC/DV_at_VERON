import apb_pkg::*;

class apb_drv;

	//virutal interface to drive the bus
	virtual apb_if.MASTER vif;

	//Call mailbox to get transaction from the generator
	mailbox #(apb_trans) gen2drv;

	//Constructor
	function new(virtual apb_if.MASTER vif, mailbox #(apb_trans) gen2drv);
		this.vif	= vif;
		this.gen2drv	= gen2drv;

	endfunction


	task run();
		apb_trans tr;
		forever begin
			gen2drv.get(tr);
			drive_transaction(tr);
		end
	endtask

	//Task drive transaction
	task drive_transaction(apb_trans tr);
		//local variables
		logic [ADDR_WIDTH-1:0] addr = tr.addr;
		logic [DATA_WIDTH-1:0] wdata = tr.wdata;

		//APB protocol: setup phase
		vif.PADDR	<= addr;
		vif.PWDATA	<= wdata;
		vif.PWRITE	<= (tr.op == APB_WRITE);
		vif.PSEL	<= 1'b1;
		vif.PENABLE	<= 1'b0;
		@(posedge vif.PCLK);

		//Acess phase
		vif.PENABLE <= 1'b1;

		//wait for ready form DUT
		do @(posedge vif.PCLK); while (!vif.PREADY);

		//READ --> receive from the prdata
		if (tr.op == APB_READ) begin
			tr.rdata = vif.PRDATA;
		end

		//Error flag
		tr.err = vif.PSLVERR;

		//End transfer: reset contol signals
		vif.PSEL	<= 1'b0;
		vif.PENABLE	<= 1'b0;
		vif.PWRITE	<= 1'b0;
		vif.PADDR	<= '0;
		vif.PWDATA	<= '0;

		@(posedge vif.PCLK);
	endtask

endclass
