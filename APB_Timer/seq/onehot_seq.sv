class onehot_seq extends base_seq;

  `uvm_object_utils(onehot_seq)

  // Constructor
  function new(string name = "onehot_seq");
    super.new(name);
  endfunction

  // One-hot sequence to test all addresses with one-hot patterns
  task body();
    bit [31:0] onehot_data;
    bit [31:0] read_data;
    
    `uvm_info(get_type_name(), "=== Starting One-Hot Sequence Test ===", UVM_LOW);
    
    // Reset the DUT first
    rst_dut();
    
    // Test 1: Write one-hot patterns to all valid addresses (0-15)
    `uvm_info(get_type_name(), "Phase 1: Writing one-hot patterns to all valid addresses", UVM_MEDIUM);
    
    for (int addr = 0; addr <= 15; addr += 4) begin // Word-aligned addresses
      for (int bit_pos = 0; bit_pos < 32; bit_pos++) begin
        // Create one-hot pattern
        onehot_data = 32'h00000001 << bit_pos;
        
        `uvm_info(get_type_name(), $sformatf("Writing one-hot pattern 0x%08h (bit %0d) to address 0x%02h", 
                 onehot_data, bit_pos, addr), UVM_HIGH);
        
        // Write one-hot pattern with full strobe
        write_seq(addr, onehot_data, 4'hF);
        
        // Read back and verify
        read_seq(addr, read_data);
        
        // Small delay between patterns
        #10ns;
      end
    end
    
    // Test 2: Test individual byte writes with one-hot strobe patterns
    `uvm_info(get_type_name(), "Phase 2: Testing one-hot strobe patterns", UVM_MEDIUM);
    
    for (int addr = 0; addr <= 12; addr += 4) begin // Word-aligned addresses
      for (int strb_bit = 0; strb_bit < 4; strb_bit++) begin
        bit [3:0] onehot_strb = 4'b0001 << strb_bit; // One-hot strobe
        
        `uvm_info(get_type_name(), $sformatf("Writing to address 0x%02h with one-hot strobe 0x%h (byte %0d)", 
                 addr, onehot_strb, strb_bit), UVM_HIGH);
        
        // Write data with one-hot strobe pattern
        write_seq(addr, 32'hA5A5A5A5, onehot_strb);
        
        // Read back to verify byte-level writing
        read_seq(addr, read_data);
        
        #10ns;
      end
    end
    
    // Test 3: Test boundary addresses with one-hot patterns
    `uvm_info(get_type_name(), "Phase 3: Testing boundary addresses", UVM_MEDIUM);
    
    // Test address 0 (lower boundary)
    write_seq(32'h00000000, 32'h80000001, 4'hF); // MSB and LSB set
    read_seq(32'h00000000, read_data);
    
    // Test address 12 (upper boundary for word access)
    write_seq(32'h0000000C, 32'h40000002, 4'hF); // Bit 30 and bit 1 set
    read_seq(32'h0000000C, read_data);
    
    // Test 4: Test invalid addresses (should trigger PSLVERR)
    `uvm_info(get_type_name(), "Phase 4: Testing invalid addresses (expecting PSLVERR)", UVM_MEDIUM);
    
    // Test out-of-bounds addresses
    write_seq(32'h00000010, 32'h00000001, 4'hF); // Address 16 (invalid)
    write_seq(32'h00000020, 32'h00000001, 4'hF); // Address 32 (invalid)
    write_seq(32'h000000FF, 32'h00000001, 4'hF); // Address 255 (invalid)
    
    // Test 5: Stress test with rapid one-hot patterns
    `uvm_info(get_type_name(), "Phase 5: Stress test with rapid one-hot patterns", UVM_MEDIUM);
    
    for (int cycle = 0; cycle < 8; cycle++) begin
      bit [31:0] stress_addr = (cycle % 4) * 4; // Cycle through addresses 0, 4, 8, 12
      bit [31:0] stress_data = 32'h00000001 << (cycle * 4); // Shift pattern
      
      write_seq(stress_addr, stress_data, 4'hF);
      read_seq(stress_addr, read_data);
    end
    
    `uvm_info(get_type_name(), "=== One-Hot Sequence Test Completed ===", UVM_LOW);
  endtask

endclass