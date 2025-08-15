class apb_m_agent extends uvm_agent;
    `uvm_component_utils(apb_m_agent)

    virtual apb_if vif;
    agent_config cfg;
    // Components
    apb_m_sequencer sequencer;
    apb_m_driver driver;
    apb_m_monitor monitor;

    // Constructor
    function new(string name = "apb_m_agent", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Constructor", UVM_MEDIUM);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cfg = agent_config::type_id::create("cfg",this);
        monitor = apb_m_monitor::type_id::create("monitor", this);
        if(cfg.is_active == UVM_ACTIVE)begin
        driver = apb_m_driver::type_id::create("driver", this);
        sequencer = apb_m_sequencer::type_id::create("sequencer", this);
        end
        if(!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("No Interface", "Can't get interface at agent");
        end
        uvm_config_db #(virtual apb_if)::set(this, "*", "vif", vif);
        `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(cfg.is_active == UVM_ACTIVE)begin
        driver.seq_item_port.connect(sequencer.seq_item_export);
        `uvm_info(get_type_name(), "Connect phase", UVM_MEDIUM);
        end
    endfunction
endclass
