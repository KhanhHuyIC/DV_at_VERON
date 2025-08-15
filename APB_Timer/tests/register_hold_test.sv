class register_hold_test extends base_test;

  `uvm_component_utils(register_hold_test)

  function new(string name = "register_hold_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Building register hold test", UVM_MEDIUM)
  endfunction

  virtual task run_phase(uvm_phase phase);
    register_hold_seq hold_seq;
    
    `uvm_info(get_type_name(), "==============================================", UVM_LOW)
    `uvm_info(get_type_name(), "    REGISTER HOLD COVERAGE TEST STARTED    ", UVM_LOW)
    `uvm_info(get_type_name(), "==============================================", UVM_LOW)
    
    phase.raise_objection(this, "Starting register hold test");
    
    // Create and run the register hold sequence
    hold_seq = register_hold_seq::type_id::create("hold_seq");
    hold_seq.start(env.agent.sequencer);
    
    // Allow time for all transactions to complete
    #1000ns;
    
    `uvm_info(get_type_name(), "==============================================", UVM_LOW)
    `uvm_info(get_type_name(), "    REGISTER HOLD COVERAGE TEST FINISHED   ", UVM_LOW)
    `uvm_info(get_type_name(), "==============================================", UVM_LOW)
    
    phase.drop_objection(this, "Register hold test completed");
  endtask

endclass
