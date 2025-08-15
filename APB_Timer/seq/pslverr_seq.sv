class pslverr_seq extends base_seq;

    `uvm_object_utils(pslverr_seq)

    function new(string name="pslverr_seq");
        super.new(name);
    endfunction
    bit [31:0] read_data;
    bit [31:0] write_data;
    bit [3:0]  write_strb;

    task body();
        `uvm_info(get_type_name(), "Starting PSL Error Sequence", UVM_LOW)
        // Implement PSL error sequence logic here
        rst_dut();

        for(int i = 0; i < 32; i++) begin
            write_data = $urandom;
            write_strb = $urandom;

            `uvm_info(get_type_name(), $sformatf("Writing data into address: %0h", i * 4), UVM_LOW)
            write_seq(1 << i, write_data, write_strb);
            read_seq(1 << i, read_data);
        end
    endtask

endclass