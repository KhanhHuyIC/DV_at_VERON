class apb_m_driver extends uvm_driver #(apb_transaction);
    `uvm_component_utils(apb_m_driver)

    virtual apb_if vif;

    // Constructor
    function new(string name = "apb_m_driver", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Constructor", UVM_MEDIUM);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("No Interface", "Can't get interface at driver");
        end
        `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM);
    endfunction

    extern task drive_logic(apb_transaction tr);
    // Run phase
    apb_transaction tr;
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "Run phase", UVM_MEDIUM);
        forever begin 
            $display("Waiting for transaction...");
            tr = apb_transaction::type_id::create("tr");
            
            seq_item_port.get_next_item(tr);
            // `uvm_info(get_type_name(), $sformatf("Received transaction %0d", tr.PRESETn), UVM_MEDIUM);
            drive_logic(tr);
            seq_item_port.item_done();
        end
        
    endtask
endclass

task apb_m_driver::drive_logic(apb_transaction tr);
    if(!tr.PRESETn) begin
        // Reset transaction
        $display("Starting reset transaction...");
        vif.PRESETn = 1'b0;
        @(posedge vif.PCLK); // Wait one clock cycle
        vif.cb_drv.PADDR <= 32'h0000_0000;
        vif.cb_drv.PWRITE <= 1'b0;
        vif.cb_drv.PWDATA <= 32'h0000_0000;
        vif.cb_drv.PSTRB <= 4'b0000;  // Reset strobe
        vif.cb_drv.PSEL <= 1'b0;
        vif.cb_drv.PENABLE <= 1'b0;
        vif.cb_drv.PADDRCHK <= 0;
        vif.cb_drv.PWDATACHK <= 0;
        vif.cb_drv.PSTRBCHK <= 0;  // Reset strobe parity check
        $display("Driving reset transaction - PRESETn = 0");
        repeat(2) @(posedge vif.PCLK);
        // vif.PRESETn = 1'b1; // Release reset
        $display("Reset released - PRESETn = 1");
        `uvm_info(get_type_name(), "Reset transaction driven", UVM_MEDIUM);
    end else begin
        // For now, just acknowledge non-reset transactions
        // $display("Non-reset transaction received - doing nothing for now");
        vif.PRESETn = 1'b1; // Ensure reset is deasserted
        vif.cb_drv.PADDR <= tr.PADDR;
        vif.cb_drv.PWRITE <= tr.PWRITE;
        vif.cb_drv.PWDATA <= tr.PWDATA;
        vif.cb_drv.PSTRB <= tr.PSTRB;  // Drive byte enable strobe
        vif.cb_drv.PSEL <= 1'b1; // Select the slave
        vif.cb_drv.PADDRCHK <= tr.PADDRCHK;
        vif.cb_drv.PWDATACHK <= tr.PWDATACHK;
        vif.cb_drv.PSTRBCHK <= tr.PSTRBCHK;  // Drive strobe parity check
        @(posedge vif.PCLK); // Wait one clock cycle

        vif.cb_drv.PENABLE <= 1'b1; // Enable the transaction
        
        // Wait for slave to be ready using clocking block
        do begin
            @(vif.cb_drv);
        end while (!vif.cb_drv.PREADY);
        if (!tr.PWRITE) begin
            tr.PRDATA = vif.cb_drv.PRDATA; // Read data from slave
            tr.PRDATACHK = vif.cb_drv.PRDATACHK; // Read data parity check
            // `uvm_info(get_type_name(), $sformatf("Read data: %0h", tr.PRDATA), UVM_MEDIUM);
        end else begin
            // `uvm_info(get_type_name(), "Write transaction completed successfully", UVM_MEDIUM);
        end
        vif.cb_drv.PENABLE <= 1'b0; // Disable the transaction
        vif.cb_drv.PSEL <= 1'b0; // Deselect the slave
        vif.cb_drv.PWRITE <= 1'b0;
        @(posedge vif.PCLK); // Wait one clock cycle
    end
endtask