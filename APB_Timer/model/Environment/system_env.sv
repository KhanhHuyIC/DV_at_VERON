class apb_m_env extends uvm_env;
    `uvm_component_utils(apb_m_env)

    virtual apb_if vif;
    apb_m_agent agent;
    apb_scoreboard scb;


    function new(string name = "apb_m_env", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Constructor", UVM_MEDIUM);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM);
        
        // Create the agent
        agent = apb_m_agent::type_id::create("agent", this);
        if (!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("No Interface", "Can't get interface at env");
        end

        uvm_config_db #(virtual apb_if)::set(this, "agent", "vif", vif);
        scb = apb_scoreboard::type_id::create("scb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "Connect phase", UVM_MEDIUM);
        
        // Connect the agent's sequencer and driver
        agent.monitor.collected_port.connect(scb.analysis_port);
        
    endfunction
endclass