class apb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(apb_scoreboard)

    uvm_analysis_imp #(apb_transaction, apb_scoreboard) analysis_port;

    // Memory model to store expected data (limited to addresses 0-15)
    bit [7:0] memory [0:15]; // Byte-addressable memory for strobe support
    int write_count, read_count, parity_error_count, address_error_count;
    int data_mismatch_count, slave_error_count; // New error counters
    int pslverr_correct_count, pslverr_missing_count, pslverr_unexpected_count; // PSLVERR behavior tracking

    // Constructor
    function new(string name = "apb_scoreboard", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
        write_count = 0;
        read_count = 0;
        parity_error_count = 0;
        address_error_count = 0;
        data_mismatch_count = 0;  // Initialize new counters
        slave_error_count = 0;
        pslverr_correct_count = 0;     // PSLVERR correctly asserted for invalid addresses
        pslverr_missing_count = 0;     // PSLVERR missing for invalid addresses (ERROR)
        pslverr_unexpected_count = 0;  // PSLVERR asserted for valid addresses (ERROR)
        
        // Initialize memory to known values
        for (int i = 0; i < 16; i++) begin
            memory[i] = 8'h00;
        end
        
        `uvm_info(get_type_name(), "Constructor", UVM_MEDIUM);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM);
    endfunction

    function void write(apb_transaction tr);
        // Local variable declarations must come first
        bit [31:0] word_addr;
        
        // Skip reset transactions
        if (!tr.PRESETn) begin
            `uvm_info(get_type_name(), "Reset transaction received - clearing memory model", UVM_MEDIUM);
            // Clear memory to reset state
            for (int i = 0; i < 16; i++) begin
                memory[i] = 8'h00;
            end
        end else if(tr.PWRITE) begin
            // Write transaction
            write_count++;
            `uvm_info(get_type_name(), $sformatf("Write #%0d: addr=0x%h, data=0x%h, strb=0x%h", 
                     write_count, tr.PADDR, tr.PWDATA, tr.PSTRB), UVM_MEDIUM);

            // Check address bounds (must be 0-15)
            if (tr.PADDR > 15) begin
                address_error_count++;
                `uvm_error(get_type_name(), $sformatf("Address out of bounds! Address: 0x%h (must be 0-15)", tr.PADDR));
            end else begin
                // Store expected data using byte enables (PSTRB)
                store_strb_data(tr);
            end
            
            // Check parity regardless of address bounds
            check_write_parity(tr);
            
        end else begin
            // Read transaction
            read_count++;
            `uvm_info(get_type_name(), $sformatf("Read #%0d: addr=0x%h, data=0x%h", 
                     read_count, tr.PADDR, tr.PRDATA), UVM_MEDIUM);
            
            // Check address bounds first
            if (tr.PADDR > 15) begin
                address_error_count++;
                `uvm_error(get_type_name(), $sformatf("Address out of bounds! Address: 0x%h (must be 0-15)", tr.PADDR));
            end else begin
                // Check data integrity only if address is valid
                check_read_data(tr);
            end
            
            // Check parity regardless of address bounds
            check_read_parity(tr);
        end
        
        // Check for slave error (PSLVERR) assertion behavior
        if (tr.PSLVERR) begin
            // Check if PSLVERR is asserted for valid addresses (should NOT happen - ERROR)
            if (tr.PADDR <= 15) begin
                pslverr_unexpected_count++;
                slave_error_count++; // This is an actual error
                `uvm_error(get_type_name(), $sformatf("PSLVERR ERROR: Unexpected assertion for valid address! %s transaction at addr=0x%h (valid range: 0-15)", 
                          tr.PWRITE ? "WRITE" : "READ", tr.PADDR));
            end else begin
                // PSLVERR is correctly asserted for out-of-bounds addresses (CORRECT behavior - NOT an error)
                pslverr_correct_count++;
                `uvm_info(get_type_name(), $sformatf("PSLVERR PASS: Correctly asserted for out-of-bounds address: %s transaction at addr=0x%h", 
                         tr.PWRITE ? "WRITE" : "READ", tr.PADDR), UVM_MEDIUM);
            end
        end else begin
            // Check if PSLVERR should have been asserted for invalid addresses (MUST assert - ERROR if missing)
            if (tr.PADDR > 15) begin
                pslverr_missing_count++;
                slave_error_count++; // This is an actual error
                `uvm_error(get_type_name(), $sformatf("PSLVERR ERROR: Missing assertion for out-of-bounds address! %s transaction at addr=0x%h (valid range: 0-15)", 
                          tr.PWRITE ? "WRITE" : "READ", tr.PADDR));
            end
            // For valid addresses (0-15), PSLVERR should be 0 (correct behavior - no message needed)
        end
    endfunction
    
    // Function to store data using byte enables (PSTRB)
    function void store_strb_data(apb_transaction tr);
        bit [31:0] base_addr;
        
        // Get word-aligned base address
        base_addr = {tr.PADDR[31:2], 2'b00};
        
        // Store bytes based on strobe signals
        for (int i = 0; i < 4; i++) begin
            if (tr.PSTRB[i] && (base_addr + i) <= 15) begin
                memory[base_addr + i] = tr.PWDATA[i*8 +: 8];
                `uvm_info(get_type_name(), $sformatf("Stored byte 0x%h at address 0x%h (strb[%0d]=1)", 
                         tr.PWDATA[i*8 +: 8], base_addr + i, i), UVM_HIGH);
            end else if (tr.PSTRB[i]) begin
                `uvm_warning(get_type_name(), $sformatf("Strobe enabled for out-of-bounds byte address 0x%h", base_addr + i));
            end
        end
    endfunction
    
    // Function to check write transaction parity
    function void check_write_parity(apb_transaction tr);
        bit [3:0] expected_addr_parity, expected_data_parity, expected_strb_parity;
        
        // Calculate expected parity (even parity per byte)
        expected_addr_parity = tr.calc_addr_parity();
        expected_data_parity = tr.calc_wdata_parity();
        expected_strb_parity = tr.calc_strb_parity();
        
        // Check address parity
        if (tr.PADDRCHK !== expected_addr_parity) begin
            parity_error_count++;
            `uvm_error(get_type_name(), $sformatf("Write address parity error! Expected: 0x%h, Got: 0x%h", 
                      expected_addr_parity, tr.PADDRCHK));
        end else begin
            `uvm_info(get_type_name(), "Write address parity check passed", UVM_HIGH);
        end
        
        // Check write data parity
        if (tr.PWDATACHK !== expected_data_parity) begin
            parity_error_count++;
            `uvm_error(get_type_name(), $sformatf("Write data parity error! Expected: 0x%h, Got: 0x%h", 
                      expected_data_parity, tr.PWDATACHK));
        end else begin
            `uvm_info(get_type_name(), "Write data parity check passed", UVM_HIGH);
        end
        
        // Check strobe parity
        if (tr.PSTRBCHK !== expected_strb_parity) begin
            parity_error_count++;
            `uvm_error(get_type_name(), $sformatf("Write strobe parity error! Expected: 0x%h, Got: 0x%h", 
                      expected_strb_parity, tr.PSTRBCHK));
        end else begin
            `uvm_info(get_type_name(), "Write strobe parity check passed", UVM_HIGH);
        end
    endfunction
    
    // Function to check read data integrity
    function void check_read_data(apb_transaction tr);
        // Local variable declarations must come first
        bit [31:0] word_addr;
        bit [31:0] expected_data;
        
        // Word-align address within 0-15 range
        word_addr = {28'h0, tr.PADDR[3:2], 2'b00}; 
        
        // Reconstruct expected word from byte memory
        expected_data = {memory[word_addr + 3], memory[word_addr + 2], 
                        memory[word_addr + 1], memory[word_addr]};
        
        if (tr.PRDATA !== expected_data) begin
            data_mismatch_count++;  // Increment error counter
            `uvm_error(get_type_name(), $sformatf("Read data mismatch at addr 0x%h! Expected: 0x%h, Got: 0x%h", 
                      tr.PADDR, expected_data, tr.PRDATA));
            // Show byte-by-byte comparison for debugging
            for (int i = 0; i < 4; i++) begin
                if (memory[word_addr + i] !== tr.PRDATA[i*8 +: 8]) begin
                    `uvm_error(get_type_name(), $sformatf("  Byte[%0d] mismatch: Expected: 0x%h, Got: 0x%h", 
                              i, memory[word_addr + i], tr.PRDATA[i*8 +: 8]));
                end
            end
        end else begin
            `uvm_info(get_type_name(), $sformatf("Read data match at addr 0x%h: 0x%h", 
                     tr.PADDR, tr.PRDATA), UVM_MEDIUM);
        end
    endfunction
    
    // Function to check read transaction parity
    function void check_read_parity(apb_transaction tr);
        bit [3:0] expected_addr_parity, expected_rdata_parity;
        
        // Calculate expected parity
        expected_addr_parity = tr.calc_addr_parity();
        expected_rdata_parity = tr.calc_rdata_parity();
        
        // Check address parity
        if (tr.PADDRCHK !== expected_addr_parity) begin
            parity_error_count++;
            `uvm_error(get_type_name(), $sformatf("Read address parity error! Expected: 0x%h, Got: 0x%h", 
                      expected_addr_parity, tr.PADDRCHK));
        end else begin
            `uvm_info(get_type_name(), "Read address parity check passed", UVM_HIGH);
        end
        
        // Check read data parity
        if (tr.PRDATACHK !== expected_rdata_parity) begin
            parity_error_count++;
            `uvm_error(get_type_name(), $sformatf("Read data parity error! Expected: 0x%h, Got: 0x%h", 
                      expected_rdata_parity, tr.PRDATACHK));
        end else begin
            `uvm_info(get_type_name(), "Read data parity check passed", UVM_HIGH);
        end
    endfunction
    
    // Report function for end of test
    function void report_phase(uvm_phase phase);
        // Local variable declarations must come first
        int total_errors;
        
        super.report_phase(phase);
        `uvm_info(get_type_name(), "=== SCOREBOARD SUMMARY ===", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("Total Writes: %0d", write_count), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("Total Reads: %0d", read_count), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("Parity Errors: %0d", parity_error_count), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("Address Errors: %0d", address_error_count), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("Data Mismatch Errors: %0d", data_mismatch_count), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("Slave Errors (PSLVERR): %0d", slave_error_count), UVM_LOW);
        
        // PSLVERR behavior breakdown
        `uvm_info(get_type_name(), "=== PSLVERR BEHAVIOR ANALYSIS ===", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("PSLVERR Correctly Asserted (PASS): %0d", pslverr_correct_count), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("PSLVERR Missing (ERROR): %0d", pslverr_missing_count), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("PSLVERR Unexpected (ERROR): %0d", pslverr_unexpected_count), UVM_LOW);
        
        // Calculate total error count (slave_error_count now only counts actual errors)
        total_errors = parity_error_count + address_error_count + data_mismatch_count + slave_error_count;
        
        if (total_errors == 0) begin
            `uvm_info(get_type_name(), "*** ALL CHECKS PASSED ***", UVM_LOW);
        end else begin
            `uvm_error(get_type_name(), $sformatf("*** TOTAL ERRORS DETECTED: %0d ***", total_errors));
            if (parity_error_count > 0) begin
                `uvm_error(get_type_name(), $sformatf("  - %0d PARITY ERRORS", parity_error_count));
            end
            if (address_error_count > 0) begin
                `uvm_error(get_type_name(), $sformatf("  - %0d ADDRESS ERRORS", address_error_count));
            end
            if (data_mismatch_count > 0) begin
                `uvm_error(get_type_name(), $sformatf("  - %0d DATA MISMATCH ERRORS", data_mismatch_count));
            end
            if (slave_error_count > 0) begin
                `uvm_error(get_type_name(), $sformatf("  - %0d SLAVE ERRORS (PSLVERR)", slave_error_count));
                if (pslverr_missing_count > 0) begin
                    `uvm_error(get_type_name(), $sformatf("    * %0d Missing PSLVERR for invalid addresses", pslverr_missing_count));
                end
                if (pslverr_unexpected_count > 0) begin
                    `uvm_error(get_type_name(), $sformatf("    * %0d Unexpected PSLVERR for valid addresses", pslverr_unexpected_count));
                end
            end
        end
        
        // Display final memory contents
        `uvm_info(get_type_name(), "=== FINAL MEMORY CONTENTS ===", UVM_LOW);
        for (int i = 0; i < 16; i += 4) begin
            `uvm_info(get_type_name(), $sformatf("Addr[%2d-%2d]: 0x%h%h%h%h", 
                     i+3, i, memory[i+3], memory[i+2], memory[i+1], memory[i]), UVM_LOW);
        end
    endfunction
endclass



