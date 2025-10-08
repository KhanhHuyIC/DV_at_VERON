module	apb_protocol_sva (apb_if.mon vif);
	//Control
	property ctrl_stable_p;
		@(posedge vif.PCLK) disable iff(!vif.PRESETn)
		(vif.PSEL && vif.PENABLE && !vif.PREADY) |-> $stable({vif.PADDR, vif.PWRITE, vif.PPROT});
	endproperty

	assert property (ctrl_stable_p) else $error ("APB controls changed during ACCESS");

	//ACCESS must after SETUP
	property setup_then_access_p;
		@(posedge vif.PCLK) disable iff(!vif.PRESETn)
		(vif.PSEL && !vif.PENABLE) |-> ##1 (vif.PSEL && vif.PENABLE);
	endproperty
	assert property (setup_then_access_p);

	//PREADY is only policy in ACCESS
	property ready_in_access_p;
		@(posedge vif.PCLK) disable iff(!vif.PRESETn)
		vif.PREADY |-> (vif.PSEL && vif.PENABLE);
	endproperty

	assert property (ready_in_access_p);

	endmodule
