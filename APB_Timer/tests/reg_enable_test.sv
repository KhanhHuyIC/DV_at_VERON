class reg_enable_test extends base_test;
  `uvm_component_utils(reg_enable_test)

  function new(string name = "reg_enable_test", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(), "Constructor", UVM_HIGH)
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Build phase", UVM_HIGH)
  endfunction


  virtual task run_phase(uvm_phase phase);
    register_enable_coverage_seq enable_seq;
    
    `uvm_info(get_type_name(), "=============================================", UVM_LOW)
    `uvm_info(get_type_name(), "  REGISTER ENABLE COVERAGE TEST STARTED   ", UVM_LOW)
    `uvm_info(get_type_name(), "=============================================", UVM_LOW)
    
    phase.raise_objection(this, "Starting register enable coverage test");
    
    // Create and run the register enable coverage sequence
    enable_seq = register_enable_coverage_seq::type_id::create("enable_seq");
    
    // Start the sequence on the sequencer
    enable_seq.start(env.agent.sequencer);
    
    // Add some delay to ensure all transactions complete and settle
    #3000ns;
    
    `uvm_info(get_type_name(), "=============================================", UVM_LOW)
    `uvm_info(get_type_name(), "  REGISTER ENABLE COVERAGE TEST FINISHED  ", UVM_LOW)
    `uvm_info(get_type_name(), "=============================================", UVM_LOW)
    
    phase.drop_objection(this, "Register enable coverage test completed");
  endtask

endclass
