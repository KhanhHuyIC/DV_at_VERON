module	apb_checker #(
	parameter int ADDR_WIDTH = 8,
	parameter int DATA_WIDTH = 32,
	parameter logic [ADDR_WIDTH - 1:0] MAX_ADDR = 'h1C
	)(
		apb_if.mon vif
	);

	wire	clk	= vif.PCLK;
	wire	rstn	= vif.PRESETn; 
	wire	setup	= vif.PSEL && !vif.PENABLE;
	wire	acc	= vif.PSEL && vif.PENABLE;
	wire	done	= acc && vif.PREADY;

	localparam int LSB_ALIGN = (DATA_WIDTH/8 == 4) ? 2:
				(DATA_WIDTH/8 ==2) ? 1 : 0;

	wire	addr_aligned	= (LSB_ALIGN==0) ? 1'b1 : (vif.PADDR[LSB_ALIGN-1:0] == '0);
	wire	addr_inrng	= (vif.PADDR <= MAX_ADDR);

	int unsigned wait_cnt;
	always @(posedge clk or negedge rstn) begin
		if (!rstn)	wait_cnt <= 0;
		else if (setup)	wait_cnt <= 0;
		else if (acc && !vif.PREADY) wait_cnt <= wait_cnt + 1;
	end

	//A1: 2-phase: setup --> access
	property p_two_phase;
		@(posedge clk) disable iff (!rstn)
		setup |-> ##1 acc;
	endproperty

	A1_two_phase: assert property (p_two_phase)
		else	$error ("[APBCHK] Two-phase sequence violated");
	//A2: Control stable
	property p_ctrl_stable;
		@(posedge clk) disable iff(!rstn)
		setup |-> ($stable (vif.PADDR) throughout (vif.PSEL)) &&
			($stable(vif.PWRITE) throughout (vif.PSEL)) &&
			($stable(vif.PSEL) throughout (vif.PSEL));
	endproperty

	A2_ctrl_stable: assert property (p_ctrl_stable)
		else $error ("[APBCHK] Control changed mid-transfer");

	//A3: WDATA stable
	property p_wdata_stable;
		@(posedge clk) disable iff (!rst)
		(setup && vif.PWRITE) |-> ($stable(vif.PWDATA) throughout acc);
	endproperty

	A3_wdata_stable: assert property (p_wdata_stable)
		else $error("[APBCHK] PWDATA changed during access");
	
	//A4: PENABLE
	property p_enable_needs_sel;
		@(posedge clk) disable iff (!rstn)
		vif.PENABLE |-> vif.PSEL;
	endproperty

	A4_enable_needs_sel: assert property (p_enable_needs_sel)
		else $error("APBCHK] PENABLE without PSEL");

	logic	cov_wr;
	logic	[ADDR_WIDTH-1:0] cov_addr;
	int	unsigned cov_waits;

	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			cov_wr		<= 0;
			cov_addr	<= '0;
			cov_waits	<= 0;
		end else begin
		if (setup) begin
			cov_wr		<= vif.PWRITE;
			cov_addr	<= vif.PADDR;
		end
		if (done) begin
			cov_waits	<= wait_cnt;
		end
		end
	end

	covergroup cg_apb @(posedge clk);
		option.per_instance = 1;\

		//Type of transaction
		cp_type: coverpoint cov_wr iff (done)
		{
			bins READ = {0};
			bins WRITE = {1};
		}

		//Wait-states
		//
