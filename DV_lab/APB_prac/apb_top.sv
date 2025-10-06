// APB_top.sv
`timescale 1ns/1ps

import apb_pkg::*;
`include "env/08_apb_env.sv"

module APB_top;

  // Interface instance
  apb_if apb_vif();

  // DUT instance
  apb_slave #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .PCLK       (apb_vif.PCLK),
    .PRESETn    (apb_vif.PRESETn),
    .PADDR      (apb_vif.PADDR),
    .PSEL       (apb_vif.PSEL),
    .PENABLE    (apb_vif.PENABLE),
    .PWRITE     (apb_vif.PWRITE),
    .PWDATA     (apb_vif.PWDATA),
    .PRDATA     (apb_vif.PRDATA),
    .PREADY     (apb_vif.PREADY),
    .PSLVERR    (apb_vif.PSLVERR),
    // NEW: connect runtime-configurable wait cycles
    .WAIT_CYCLES(apb_vif.WAIT_CYCLES)
  );

  // Environment instance
  apb_env env;

  // Clock generation: 100 MHz (10 ns period)
  initial begin
    apb_vif.PCLK = 1'b0;
    forever #5 apb_vif.PCLK = ~apb_vif.PCLK;
  end

  // Reset generation
  initial begin
    apb_vif.PRESETn = 1'b0;
    #25;
    apb_vif.PRESETn = 1'b1;
  end

  // Test sequence
  initial begin
    // Wait for reset deassertion
    wait (apb_vif.PRESETn == 1'b1);

    // Initialize the environment
    // Note: env expects a virtual apb_if.MASTER; pass the interface with its modport
    env = new(apb_vif.MASTER, 50); // 50 transactions, default max_wait_cycles=5

    // Run the environment
    // Directed cases
    $display ("Run directed cases");
    env.run("directed");
    #20;

    // Random cases
    $display ("Run random cases");
    env.run("random");
    #20;

    // Corner cases
    $display ("Run the corner cases");
    env.run("corner"); // "random" / "directed" / "corner"

    // Let the simulation run long enough
    #2000;

    $display("=== [APB TB] Simulation finished! ===");
    $finish;
  end

endmodule
