import apb_pkg::*;

class apb_score;
  // Mailbox: receive transactions from monitor
  mailbox #(apb_trans) mon2score;

  // Expected model
  apb_data_t regfile [REG_NUM];

  // Constructor
  function new(mailbox #(apb_trans) mon2score);
    this.mon2score = mon2score;

    // Initialize expected model (all zeros)
    foreach (regfile[i]) regfile[i] = '0;
  endfunction

  // Scoreboard main task
  task automatic run();
    apb_trans tr;
    int error_cnt = 0;
    int pass_cnt  = 0;

    bit addr_valid, aligned;
    apb_reg_addr_t idx;

    forever begin
      mon2score.get(tr);

      // Derive register index from byte address (word-aligned by DATA_WIDTH)
      idx = apb_reg_addr_t'(tr.addr >> ADDR_LSB);

      // Address validity: aligned and within range
      if (ADDR_LSB == 0)
        aligned = 1'b1;
      else
        aligned = (tr.addr[ADDR_LSB-1:0] == '0);

      addr_valid = aligned && (idx < REG_NUM);

      // Check the transaction
      if (tr.op == APB_WRITE) begin
        if (addr_valid && !tr.err) begin
          regfile[idx] = tr.wdata;
          $display("[SCORE][WRITE] Addr: 0x%0h Data: 0x%0h wait=%0d => EXPECT: OK",
                    tr.addr, tr.wdata, tr.wait_cycles);
          pass_cnt++;
        end
        else if (!addr_valid && tr.err) begin
          $display("[SCORE][WRITE] Addr: 0x%0h OUT-OF-RANGE => PSLVERR=1 : OK (wait=%0d)",
                    tr.addr, tr.wait_cycles);
          pass_cnt++;
        end
        else begin
          $display("[SCORE][WRITE][FAIL] Addr: 0x%0h Data: 0x%0h ERR?%0b wait=%0d",
                    tr.addr, tr.wdata, tr.err, tr.wait_cycles);
          error_cnt++;
        end
      end
      else if (tr.op == APB_READ) begin
        if (addr_valid && !tr.err) begin
          if (tr.rdata === regfile[idx]) begin
            $display("[SCORE][READ] Addr: 0x%0h Data: 0x%0h => EXPECT: 0x%0h PASS (wait=%0d)",
                      tr.addr, tr.rdata, regfile[idx], tr.wait_cycles);
            pass_cnt++;
          end else begin
            $display("[SCORE][READ][FAIL] Addr: 0x%0h Data: 0x%0h != EXPECT: 0x%0h (wait=%0d)",
                      tr.addr, tr.rdata, regfile[idx], tr.wait_cycles);
            error_cnt++;
          end
        end
        else if (!addr_valid && tr.err) begin
          $display("[SCORE][READ] Addr: 0x%0h OUT-OF-RANGE => PSLVERR=1 : OK (wait=%0d)",
                    tr.addr, tr.wait_cycles);
          pass_cnt++;
        end
        else begin
          $display("[SCORE][READ][FAIL] Addr: 0x%0h ERR?%0b (wait=%0d)",
                    tr.addr, tr.err, tr.wait_cycles);
          error_cnt++;
        end
      end
    end
  endtask
endclass
