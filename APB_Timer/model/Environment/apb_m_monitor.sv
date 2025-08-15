class apb_m_monitor extends uvm_monitor;
    `uvm_component_utils(apb_m_monitor)
    virtual apb_if vif;
    uvm_analysis_port #(apb_transaction) collected_port;

    

    // Constructor
    function new(string name = "apb_m_monitor", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Constructor", UVM_MEDIUM);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("No Interface", "Can't get interface at monitor");
        end
        `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM);
        collected_port = new("collected_port", this);
    endfunction

    extern task run_phase(uvm_phase phase);
endclass

task apb_m_monitor::run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), "Run phase", UVM_MEDIUM);
    
    forever begin
        apb_transaction tr;
        tr = apb_transaction::type_id::create("tr");
        
        // Monitor reset transactions
        if (!vif.PRESETn) begin
            tr.PRESETn = 1'b0;
            `uvm_info(get_type_name(), "Reset transaction detected", UVM_MEDIUM);
            collected_port.write(tr);
            @(posedge vif.PRESETn); // Wait for reset to be released
            continue;
        end
        
        // Monitor normal APB transactions
        @(posedge vif.PCLK);
        
        // Detect APB transaction completion (PREADY && PSEL && PENABLE)
        if (vif.cb_mon.PREADY && vif.cb_mon.PSEL && vif.cb_mon.PENABLE) begin
            // Capture all transaction signals
            tr.PRESETn = vif.PRESETn;
            tr.PADDR = vif.cb_mon.PADDR;
            tr.PWRITE = vif.cb_mon.PWRITE;
            tr.PWDATA = vif.cb_mon.PWDATA;
            tr.PSTRB = vif.cb_mon.PSTRB;  // Capture byte enable strobe
            tr.PRDATA = vif.cb_mon.PRDATA;
            tr.PREADY = vif.cb_mon.PREADY;
            tr.PSLVERR = vif.cb_mon.PSLVERR;
            
            // Capture parity check results from slave
            tr.PADDRCHK = vif.cb_mon.PADDRCHK;
            tr.PWDATACHK = vif.cb_mon.PWDATACHK;
            tr.PSTRBCHK = vif.cb_mon.PSTRBCHK;  // Capture strobe parity check
            tr.PRDATACHK = vif.cb_mon.PRDATACHK;
            
            // Log the transaction
            if (tr.PWRITE) begin
                `uvm_info(get_type_name(), $sformatf("Write transaction captured: addr=0x%h, data=0x%h, strb=0x%h", 
                         tr.PADDR, tr.PWDATA, tr.PSTRB), UVM_MEDIUM);
            end else begin
                `uvm_info(get_type_name(), $sformatf("Read transaction captured: addr=0x%h, data=0x%h", 
                         tr.PADDR, tr.PRDATA), UVM_MEDIUM);
            end
            
            // Check for slave error
            if (tr.PSLVERR) begin
                `uvm_warning(get_type_name(), "Slave error detected during transaction");
            end
            
            // Send transaction to scoreboard
            collected_port.write(tr);
        end
    end
endtask