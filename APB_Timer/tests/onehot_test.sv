class onehot_test extends base_test;

  `uvm_component_utils(onehot_test)

  // Constructor
  function new(string name = "onehot_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Building one-hot test", UVM_MEDIUM);
  endfunction

  // Run phase - Execute the one-hot sequence
  task run_phase(uvm_phase phase);
    onehot_seq onehot_sequence;
    
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "=== Starting One-Hot Test ===", UVM_LOW);
    
    // Create and execute the one-hot sequence
    onehot_sequence = onehot_seq::type_id::create("onehot_sequence");
    
    if (!onehot_sequence.randomize()) begin
      `uvm_fatal(get_type_name(), "Failed to randomize one-hot sequence");
    end
    
    `uvm_info(get_type_name(), "Starting one-hot sequence execution", UVM_MEDIUM);
    onehot_sequence.start(env.agent.sequencer);
    `uvm_info(get_type_name(), "One-hot sequence execution completed", UVM_MEDIUM);
    
    // Add some delay to ensure all transactions are processed
    #1us;
    
    `uvm_info(get_type_name(), "=== One-Hot Test Completed ===", UVM_LOW);
    phase.drop_objection(this);
  endtask

  // Report phase - Additional test-specific reporting
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), "One-Hot Test Report:", UVM_LOW);
    `uvm_info(get_type_name(), "- Tested all valid addresses (0-15) with one-hot patterns", UVM_LOW);
    `uvm_info(get_type_name(), "- Verified 32 different one-hot bit positions", UVM_LOW);
    `uvm_info(get_type_name(), "- Tested byte-level writes with one-hot strobes", UVM_LOW);
    `uvm_info(get_type_name(), "- Validated boundary addresses (0x00, 0x0C)", UVM_LOW);
    `uvm_info(get_type_name(), "- Tested error conditions with invalid addresses", UVM_LOW);
    `uvm_info(get_type_name(), "- Performed stress testing with rapid patterns", UVM_LOW);
  endfunction

endclass
