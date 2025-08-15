class pslverr_test extends base_test;
  `uvm_component_utils(pslverr_test)
  int total_pslverr_errors;

  function new(string name = "pslverr_test", uvm_component parent );
    super.new(name, parent);
    `uvm_info(get_type_name(), "Constructor", UVM_HIGH)
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Build phase", UVM_HIGH)
  endfunction

  task run_phase(uvm_phase phase);
    pslverr_seq error_seq; 

    `uvm_info(get_type_name(), "==========================================", UVM_LOW)
    `uvm_info(get_type_name(), "  APB SLAVE PSLVERR ERROR TEST STARTED  ", UVM_LOW)
    `uvm_info(get_type_name(), "==========================================", UVM_LOW)

    phase.raise_objection(this, "Starting PSLVERR error test");

    // Create and run the PSLVERR error sequence
    error_seq = pslverr_seq::type_id::create("error_seq");

    // Start the sequence on the sequencer
    error_seq.start(env.agent.sequencer);

    // Add some delay to ensure all transactions complete
    #2000ns;

    `uvm_info(get_type_name(), "==========================================", UVM_LOW)
    `uvm_info(get_type_name(), "  APB SLAVE PSLVERR ERROR TEST FINISHED ", UVM_LOW)
    `uvm_info(get_type_name(), "==========================================", UVM_LOW)

    phase.drop_objection(this, "PSLVERR error test completed");
  endtask

  virtual function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    `uvm_info(get_type_name(), "Extract phase", UVM_HIGH)
  endfunction

endclass
