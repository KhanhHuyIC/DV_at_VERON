import apb_pkg::*;

class apb_gen;

  // Mailbox transaction to generator
  mailbox #(apb_trans) gen2drv;

  // The number of transactions
  int num_transactions;

  // Max random wait cycles (simple knob for random runs)
  int unsigned max_wait_cycles;

  // Constructor
  function new(mailbox #(apb_trans) gen2drv,
               int num_transactions = 20,
               int unsigned max_wait_cycles = 5);
    this.gen2drv         = gen2drv;
    this.num_transactions = num_transactions;
    this.max_wait_cycles  = max_wait_cycles;
  endfunction

  // Generate random transactions
  task run_random();
    for (int i = 0; i < num_transactions; i++) begin
      apb_trans tr = new();
      assert(tr.randomize());
      // Randomize wait cycles for each transfer in [0 .. max_wait_cycles]
      tr.wait_cycles = apb_wait_t'($urandom_range(0, max_wait_cycles));
      gen2drv.put(tr);
    end
  endtask

  // Generate directed transactions
  task run_directed();
    apb_trans tr;

    // step 1: write 0x12345678 to reg 3 (zero-wait)
    tr = new(APB_WRITE, apb_addr_t'(3 << ADDR_LSB), 32'h12345678, apb_wait_t'(0));
    gen2drv.put(tr);

    // step 2: read reg 3 (3 wait cycles)
    tr = new(APB_READ, apb_addr_t'(3 << ADDR_LSB), '0, apb_wait_t'(3));
    gen2drv.put(tr);

    // step 3: access an invalid address to check PSLVERR (2 wait cycles)
    tr = new(APB_READ, apb_addr_t'((REG_NUM+1) << ADDR_LSB), '0, apb_wait_t'(2));
    gen2drv.put(tr);
  endtask

  // Generate corner-case transactions
  task run_corner();
    apb_trans tr;

    // case 1: write into the lowest address (zero-wait)
    tr = new(APB_WRITE, apb_addr_t'(0 << ADDR_LSB), 32'hDEADADDD, apb_wait_t'(0));
    gen2drv.put(tr);

    // case 2: write into the highest valid address (max wait)
    tr = new(APB_WRITE, apb_addr_t'((REG_NUM-1) << ADDR_LSB), 32'hFEADADDD,
             apb_wait_t'(max_wait_cycles));
    gen2drv.put(tr);

    // case 3: read from the lowest address (1 wait)
    tr = new(APB_READ, apb_addr_t'(0 << ADDR_LSB), '0, apb_wait_t'(1));
    gen2drv.put(tr);

    // case 4: read from the highest address (zero-wait)
    tr = new(APB_READ, apb_addr_t'((REG_NUM-1) << ADDR_LSB), '0, apb_wait_t'(0));
    gen2drv.put(tr);

    // case 5: write/read corner data: all 0s (2 waits then 0 wait)
    tr = new(APB_WRITE, apb_addr_t'(1 << ADDR_LSB), 32'h00000000, apb_wait_t'(2));
    gen2drv.put(tr);
    tr = new(APB_READ , apb_addr_t'(1 << ADDR_LSB), '0, apb_wait_t'(0));
    gen2drv.put(tr);
  endtask

endclass

