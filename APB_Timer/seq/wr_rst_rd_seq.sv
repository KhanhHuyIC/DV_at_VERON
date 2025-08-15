class wr_rst_rd_seq extends base_seq;

    `uvm_object_utils(wr_rst_rd_seq)

    function new(string name="wr_rst_rd_seq");

        super.new(name);

    endfunction

    task body();
        bit [31:0] read_data;
        bit [31:0] write_data;
        bit [3:0]  write_strb;
        `uvm_info(get_type_name(), "Starting Write Reset Read Sequence", UVM_LOW)

        rst_dut();

        for(int addr = 0; addr<=15; addr+=4) begin
            write_data = $urandom;
            write_strb = $urandom;
            `uvm_info(get_type_name(), $sformatf("Writing data into address: %0h", addr), UVM_LOW)
            write_seq(addr, write_data, write_strb);
            read_seq(addr, read_data);
            
        end

        rst_dut();

        for(int addr = 0; addr<=15; addr+=4) begin
            `uvm_info(get_type_name(), $sformatf("Writing data into address: %0h", addr), UVM_LOW)
            read_seq(addr, read_data);
        end


    endtask


endclass
