class wr_rst_rd_test extends base_test;

    `uvm_component_utils(wr_rst_rd_test)

    function new(string name ="wr_rst_rd_test", uvm_component parent);
        super.new(name, parent);

    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Building write reset read test", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        wr_rst_rd_seq seq;
        phase.raise_objection(this);

        `uvm_info(get_type_name(), "==== Starting Write reset read Test", UVM_LOW)
        seq = wr_rst_rd_seq::type_id::create("wr_rst_rd_seq");
        seq.start(env.agent.sequencer);
        `uvm_info(get_type_name(), "=== Write reset read Test Completed ===", UVM_LOW);
        phase.drop_objection(this);
    endtask

endclass
