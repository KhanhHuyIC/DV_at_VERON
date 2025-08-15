class base_test extends uvm_test; 
  
    `uvm_component_utils(base_test) 
    virtual apb_if vif;
    apb_m_env env;

    base_seq rst_seq; 

    function new (string name = "base_test", uvm_component parent);
    
        super.new(name, parent);
        `uvm_info(get_type_name(), "Constructor", UVM_MEDIUM);
    
    endfunction
  

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = apb_m_env::type_id::create("env", this);
        if(!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("No Interface", "Can't get interface at test");
        end
        uvm_config_db #(virtual apb_if)::set(this, "env", "vif", vif);
        
    endfunction

    virtual function void end_of_elaboration();
        `uvm_info(get_type_name(), "elab phase", UVM_MEDIUM);
        print();
    endfunction


    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "run phase", UVM_MEDIUM);

        phase.raise_objection(this, "Starting reset sequence");
        
        rst_seq = base_seq::type_id::create("rst_seq");
        
        rst_seq.start(env.agent.sequencer);
        
        
        phase.drop_objection(this, "Reset sequence completed");
        
        `uvm_info(get_type_name(), "Test completed", UVM_MEDIUM);
    endtask

endclass

