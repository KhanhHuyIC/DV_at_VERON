class agent_config extends uvm_object;
    `uvm_object_utils(agent_config)
    
function new(string name = "agent_config");
    super.new(name);
endfunction

uvm_active_passive_enum is_active = UVM_ACTIVE;

endclass

