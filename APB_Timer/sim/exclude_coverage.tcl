# =========================================================
# Coverage Exclusion Rules for APB Verification
# =========================================================

# Exclude all testbench and verification environment files
coverage exclude -srcfile "../env/*"
coverage exclude -srcfile "../seq/*" 
coverage exclude -srcfile "../tests/*"
coverage exclude -srcfile "../model/*"

# Exclude testbench top level
coverage exclude -srcfile "../env/testbench.sv"

# Exclude interface files (keep only DUT coverage)
coverage exclude -srcfile "../env/apb_m_interface.sv"

# Exclude package files
coverage exclude -srcfile "../env/apb_m_pkg.sv"

# Exclude transaction and sequence files
coverage exclude -srcfile "../seq/transaction.sv"
coverage exclude -srcfile "../seq/base_seq.sv"
coverage exclude -srcfile "../seq/inc_seq.sv"
coverage exclude -srcfile "../seq/onehot_seq.sv"
coverage exclude -srcfile "../seq/paritychk_seq.sv"
coverage exclude -srcfile "../seq/pslverr_seq.sv"
coverage exclude -srcfile "../seq/register_enable_coverage_seq.sv"
coverage exclude -srcfile "../seq/wr_rst_rd_seq.sv"

# Exclude all UVM components
coverage exclude -srcfile "../model/Environment/apb_m_agent.sv"
coverage exclude -srcfile "../model/Environment/apb_m_driver.sv"
coverage exclude -srcfile "../model/Environment/apb_m_monitor.sv"
coverage exclude -srcfile "../model/Environment/apb_m_sequencer.sv"
coverage exclude -srcfile "../model/Environment/scoreboard.sv"
coverage exclude -srcfile "../model/Environment/system_env.sv"

# Exclude test files
coverage exclude -srcfile "../tests/base_test.sv"
coverage exclude -srcfile "../tests/inc_tests.sv"
coverage exclude -srcfile "../tests/onehot_test.sv"
coverage exclude -srcfile "../tests/paritychk_test.sv"
coverage exclude -srcfile "../tests/wr_rst_rd_test.sv"
coverage exclude -srcfile "../tests/pslverr_test.sv"
coverage exclude -srcfile "../tests/reg_enable_test.sv"

# =========================================================
# Macro and UVM Exclusions
# Note: ModelSim doesn't support regex patterns, so we exclude
# scopes and design units that contain macro-heavy code
# =========================================================

# Exclude UVM library code (these are typically compiled separately)
# coverage exclude -du uvm_pkg
# coverage exclude -scope /*uvm*

# Exclude any packages that contain macros
# coverage exclude -du apb_m_pkg

# =========================================================  
# Alternative: Use pragma exclusions in source files
# Add // pragma coverage off/on around macro definitions
# =========================================================

# Note: To exclude specific macros in your RTL files, add:
# // pragma coverage off
# `define YOUR_MACRO ...
# // pragma coverage on
