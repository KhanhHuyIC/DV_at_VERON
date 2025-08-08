import apb_pkg::*;

class apb_score;
	//Call mailbox to receive transaction from monitor
	mailbox #(apb_trans) mon2score;

	//Expected model
	apb_data_t regfile [REG_NUM];

	//Constructor
	function new(mailbox #(apb_trans) mon2score);
		this.mon2score = mon2score;
		
		//Create the expected model (all zero)
		foreach (regfile[i]) regfile[i] = '0;
	endfunction

	//Scoreboard main task
	task run();
		apb_trans tr;
		int error_cnt = 0;
		int pass_cnt = 0;
		forever begin
			mon2score.get(tr);

			//Check the valid address
			bit addr_valid = (tr.addr % 4 == 0) && (tr.addr >> 2 < REG_NUM);

			//Check the transaction
			if (tr.op == APB_WRITE) begin
				if (addr_valid && !tr.err) begin
				regfile[tr.addr >> 2] = tr.data;
				$display("[SCORE][WRITE] Addr: 0x%0h Data: 0x%0h => EXPECT: OK", tr.addr, tr.err);
				pass_cnt++;

			end else if (!addr_valid && tr.err) begin
				$display("[SCORE][WRITE] Addr:0x%0h OUTOF RANGE => PSLVERR =1 : OK", tr.addr);
				pass_cnt++;
			end else begin
				$display("[SCORE][WRITE][FAIL] Addr: 0x%0h ERR?%0b", tr.addr, tr.err;
				error_cnt++;
			end

			end else if (tr.op == APB_READ) begin
			if (addr_valid && !tr.err) begin
				if(tr.rdata === regfile[tr.addr >> 2]) begin
					$display("[SCORE][READ] Addr: 0x%0h Data: 0x%0h => EXPECT: 0x%0h PASS", tr.addr, tr.rdata, regfile[tr.addr >> 2]);
					pass_cnt++;
				end else begin
					$display("[SCORE][READ][FAIL] Addr: 0x%0h Data: 0x%0h != EXPECT: 0x%0h", tr.addr, tr.rdata, regfile[tr.addr >> 2]);
					error_cnt++;
				end
			end else if (!addr_valid && tr.err) begin
				$display("[SCORE][READ] Addr:0x%0h OUT-OF-RANGE => PSLVERR=1: OK", tr.addr);
				pass_cnt++;
			end else begin
				$display("[SCORE][READ][FAIL] Addr: 0x%0h ERR?%0b", tr.addr, tr.err);
				error_cnt++;
			end
			end
		end
	endtask
endclass
