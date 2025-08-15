class base_seq extends uvm_sequence #(apb_transaction);

    `uvm_object_utils(base_seq)


    function new(string name = "base_seq");
        super.new(name);
    endfunction

    task rst_dut();
        apb_transaction rst_tr;
        rst_tr = apb_transaction::type_id::create("rst_tr");
        rst_tr.PRESETn = 1'b0;          // Reset signal
        rst_tr.PADDR = 32'h0000_0000; // Reset address
        rst_tr.PWRITE = 1'b0;         // Read operation
        rst_tr.PWDATA = 32'h0000_0000; // No data for reset

        `uvm_info(get_type_name(), "Sending reset transaction", UVM_MEDIUM);
        start_item(rst_tr);
        finish_item(rst_tr);
        `uvm_info(get_type_name(), "Reset transaction sent", UVM_MEDIUM);
    endtask

    task write_seq(bit [31:0] addr, bit [31:0] data, bit [3:0] strb = 4'hF);
        apb_transaction wr_tr;
        wr_tr = apb_transaction::type_id::create("wr_tr");
        wr_tr.PRESETn = 1'b1;                 // Not reset
        wr_tr.PADDR = addr;                  // Address to write
        wr_tr.PWRITE = 1'b1;                 // Write operation
        wr_tr.PWDATA = data;                 // Data to write
        wr_tr.PSTRB = strb;                  // Byte enable strobe
        
        // Calculate parity fields
        wr_tr.PADDRCHK = wr_tr.calc_addr_parity();   // Calculate address parity
        wr_tr.PWDATACHK = wr_tr.calc_wdata_parity(); // Calculate write data parity
        wr_tr.PSTRBCHK = wr_tr.calc_strb_parity();   // Calculate strobe parity
        
        `uvm_info(get_type_name(), $sformatf("Sending write transaction - ADDR: 0x%h, DATA: 0x%h, STRB: 0x%h", addr, data, strb), UVM_MEDIUM);
        
        start_item(wr_tr);
        finish_item(wr_tr);

    endtask

    task read_seq(bit [31:0] addr, output bit [31:0] expected_data);
        apb_transaction rd_tr;
        rd_tr = apb_transaction::type_id::create("rd_tr");
        rd_tr.PRESETn = 1'b1;                 // Not reset
        rd_tr.PADDR = addr;                  // Address to read
        rd_tr.PWRITE = 1'b0;                 // Read operation
        rd_tr.PWDATA = 32'h0000_0000;        // No data for read
        
        // Calculate parity fields for read transaction
        rd_tr.PADDRCHK = rd_tr.calc_addr_parity(); // Calculate address parity
        rd_tr.PWDATACHK = rd_tr.calc_wdata_parity(); // Calculate write data parity (0's)
        rd_tr.PSTRBCHK = rd_tr.calc_strb_parity();   // Calculate strobe parity (default 0's)
        
        start_item(rd_tr);
        finish_item(rd_tr);
    
    endtask
    bit [31:0] read_data;

    // Task to test parity error scenarios
    task parity_error_test();
        apb_transaction err_tr;
        
        `uvm_info(get_type_name(), "Starting parity error injection test with valid addresses", UVM_MEDIUM);
        
        // Test with valid address within 0-15 range
        err_tr = apb_transaction::type_id::create("addr_parity_err_tr");
        err_tr.PRESETn = 1'b1;
        err_tr.PADDR = 32'h0000_0008; // Valid address: 8 (within 0-15 range)
        err_tr.PWRITE = 1'b1;
        err_tr.PWDATA = 32'hDEAD_BEEF;
        err_tr.PSTRB = 4'hF;  // Set strobe for full word write
        
        // Calculate correct parity
        err_tr.PADDRCHK = err_tr.calc_addr_parity();
        err_tr.PWDATACHK = err_tr.calc_wdata_parity();
        err_tr.PSTRBCHK = err_tr.calc_strb_parity();
        
        `uvm_info(get_type_name(), $sformatf("Testing valid address 0x%h with parity pattern", err_tr.PADDR), UVM_MEDIUM);
        
        start_item(err_tr);
        finish_item(err_tr);
        
        `uvm_info(get_type_name(), "Parity error test completed", UVM_MEDIUM);
    endtask

    bit [31:0] rdata;

    virtual task body();
        rst_dut();
        
        // Test normal transactions with full strobe (all bytes enabled)
        write_seq(32'h0000_0004, 32'hDEAD_BEEF, 4'hF); 
        read_seq(32'h0000_0004, read_data); 
        
        // Test partial byte writes using strobe
        write_seq(32'h0000_0008, 32'h5555_AAAA, 4'h3); // Only lower 2 bytes
        write_seq(32'h0000_0008, 32'hFFFF_0000, 4'hC); // Only upper 2 bytes (should merge)
        read_seq(32'h0000_0008, read_data);
        
        // Test single byte writes
        write_seq(32'h0000_000C, 32'h1234_5678, 4'h1); // Only byte 0
        write_seq(32'h0000_000C, 32'h1234_5678, 4'h2); // Only byte 1
        write_seq(32'h0000_000C, 32'h1234_5678, 4'h4); // Only byte 2
        write_seq(32'h0000_000C, 32'h1234_5678, 4'h8); // Only byte 3
        read_seq(32'h0000_000C, read_data);
        
        // Test edge addresses with strobe
        write_seq(32'h0000_0000, 32'h9ABC_DEF0, 4'h5); // Bytes 0 and 2
        read_seq(32'h0000_0000, read_data);
        
        // Test parity error scenarios with strobe
        parity_error_test();
    endtask
    
endclass

