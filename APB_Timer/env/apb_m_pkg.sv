
package apb_m_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "transaction.sv"
 // `include "interface.sv"
  `include "inc_seq.sv"

  // === Master agent ===
  `include "agent_config.sv"
  `include "apb_m_monitor.sv"
  `include "apb_m_driver.sv"
  `include "apb_m_sequencer.sv"
  `include "apb_m_agent.sv"

  `include "scoreboard.sv"
  `include "system_env.sv"
  `include "inc_tests.sv"

endpackage
