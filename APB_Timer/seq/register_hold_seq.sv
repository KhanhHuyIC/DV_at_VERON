class register_hold_seq extends base_seq;

  `uvm_object_utils(register_hold_seq)

  function new(string name = "register_hold_seq");
    super.new(name);
  endfunction

  virtual task body();
    apb_transaction req;
    
    `uvm_info(get_type_name(), "Starting comprehensive register coverage sequence", UVM_MEDIUM)
    
    // Scenario 1: Test during reset release
    `uvm_info(get_type_name(), "Testing reset release scenarios", UVM_MEDIUM)
    #50ns; // Wait after reset release
    
    // Scenario 2: Test access timing error conditions
    // This should exercise the access_timing_hold_reg in different states
    `uvm_info(get_type_name(), "Testing access timing scenarios", UVM_MEDIUM)
    
    // Create transactions that might cause timing errors
    repeat(3) begin
      req = apb_transaction::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        PADDR == 32'h0000; // Valid address
        PWRITE == 1'b1;
      });
      finish_item(req);
      #20ns; // Short delay that might cause timing issues
    end
    
    // Scenario 3: Address error conditions
    `uvm_info(get_type_name(), "Testing address error scenarios", UVM_MEDIUM)
    repeat(3) begin
      req = apb_transaction::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        PADDR >= 32'h40; // Address beyond DEPTH (16 * 4 = 64 = 0x40)
        PWRITE == 1'b1;
      });
      finish_item(req);
      #100ns;
    end
    
    // Scenario 4: Mixed read/write with various timing
    `uvm_info(get_type_name(), "Testing mixed operations", UVM_MEDIUM)
    repeat(5) begin
      // Write operation
      req = apb_transaction::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        PADDR inside {32'h0000, 32'h0004, 32'h0008, 32'h000C};
        PWRITE == 1'b1;
      });
      finish_item(req);
      
      #75ns; // Delay between operations
      
      // Read operation
      req = apb_transaction::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        PADDR inside {32'h0000, 32'h0004, 32'h0008, 32'h000C};
        PWRITE == 1'b0;
      });
      finish_item(req);
      
      #75ns;
    end
    
    // Scenario 5: Boundary conditions for wait states
    `uvm_info(get_type_name(), "Testing wait state boundaries", UVM_MEDIUM)
    repeat(10) begin
      req = apb_transaction::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        PADDR == 32'h0000;
        PWRITE == 1'b0; // Read to exercise wait states
      });
      finish_item(req);
      #10ns; // Very short delay to stress timing
    end
    
    // Scenario 6: Extended idle periods
    `uvm_info(get_type_name(), "Testing extended idle periods", UVM_MEDIUM)
    #500ns; // Long idle period
    
    // Scenario 7: Rapid succession transactions
    `uvm_info(get_type_name(), "Testing rapid transactions", UVM_MEDIUM)
    repeat(20) begin
      req = apb_transaction::type_id::create("req");
      start_item(req);
      assert(req.randomize()); // Fully random
      finish_item(req);
      // Minimal delay
      #5ns;
    end
    
    // Final idle period
    #200ns;
    
    `uvm_info(get_type_name(), "Comprehensive register coverage sequence completed", UVM_MEDIUM)
  endtask

endclass
