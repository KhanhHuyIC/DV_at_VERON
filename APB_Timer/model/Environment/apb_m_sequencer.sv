class apb_m_sequencer extends uvm_sequencer #(apb_transaction);
    `uvm_component_utils(apb_m_sequencer)

    // Constructor
    function new(string name = "apb_m_sequencer", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Constructor", UVM_MEDIUM);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM);
    endfunction

endclass