module clk_sel_channel (
  input logic       i_rst_n          ,
  input logic       i_clk            ,

  // Prescaled clock inputs
  input logic       i_clk_phi_2      ,
  input logic       i_clk_phi_8      ,
  input logic       i_clk_phi_32     ,
  input logic       i_clk_phi_64     ,
  input logic       i_clk_phi_1024   ,
  input logic       i_clk_phi_8192   ,

  // External and cascaded clock signals
  input logic       i_TMCI           ,  // External signal input
  input logic       i_cascaded_signal,  // Cascaded TCNT signal (e.g., overflow/compare)

  // Select lines
  input logic [2:0] i_cks            ,  // Clock Source Select
  input logic [1:0] i_icks           ,  // Internal Clock Edge Select

  output logic      o_TCNT_EN           // Output Enable Pulse
);

  // -------- Internal signals -------- //
  logic CLK_internal  ;       // Output of internal clock MUX
  logic posedge_phi   ;       // posedge of internal selected clock
  logic negedge_phi   ;       // negedge of internal selected clock
  logic clk_phi_edge  ;       // edge (pos/neg) selected by i_icks[1]

  logic posedge_TMCI  ;
  logic negedge_TMCI  ;
  logic both_edge_TMCI;
  logic external_edge ;      // selected external edge based on i_cks[1:0]

  // -------- Internal Clock MUX (select from 6 clock_phi inputs) -------- //
  param_mux #(
    .NUM_INPUTS(8),
    .SEL_WIDTH (3)
  ) mux8to1 (
    .sel({i_cks[1], i_cks[0], i_icks[0]                                                                   }), // uses 3 bits total
    .in ({i_clk_phi_1024, i_clk_phi_8192, i_clk_phi_32, i_clk_phi_64, i_clk_phi_2, i_clk_phi_8, 1'b0, 1'b0}), // 2 unused inputs filled with 0
    .y  (CLK_internal                                                                                      )
  );

  // -------- Edge Detection for Internal Clocks -------- //
  posedge_detector pos_edge_detect_clk_phi (
    .i_rst_n         (i_rst_n     ),
    .i_clk           (i_clk       ),
    .i_sig_in        (CLK_internal),
    .o_posedge_detect(posedge_phi )
  );

  negedge_detector neg_edge_detect_clk_phi (
    .i_rst_n         (i_rst_n     ),
    .i_clk           (i_clk       ),
    .i_sig_in        (CLK_internal),
    .o_negedge_detect(negedge_phi )
  );

  // Select edge type (pos or neg) of internal clock
  param_mux #(
    .NUM_INPUTS(2),
    .SEL_WIDTH (1)
  ) mux2to1_ICKS1 (
    .sel (i_icks[1]                 ),
    .in  ({negedge_phi, posedge_phi}),
    .y   (clk_phi_edge              )
  );

  // -------- Edge Detection for External Clock (TMCI) -------- //
  posedge_detector pos_edge_detect_external (
    .i_rst_n         (i_rst_n     ),
    .i_clk           (i_clk       ),
    .i_sig_in        (i_TMCI      ),
    .o_posedge_detect(posedge_TMCI)
  );

  negedge_detector neg_edge_detect_external (
    .i_rst_n         (i_rst_n     ),
    .i_clk           (i_clk       ),
    .i_sig_in        (i_TMCI      ),
    .o_negedge_detect(negedge_TMCI)
  );

  assign both_edge_TMCI = posedge_TMCI | negedge_TMCI;

  // Select which external event to use (cascade, pos/neg/both edge of TMCI)
  param_mux #(
    .NUM_INPUTS(4),
    .SEL_WIDTH (2)
  ) mux4to1_CKS10 (
    .sel ({i_cks[1], i_cks[0]                                           }), // 2 bits for selection
    .in  ({both_edge_TMCI, negedge_TMCI, posedge_TMCI, i_cascaded_signal}), // Order changed to match selection
    .y   (external_edge                                                  )
  );

  // -------- Final Clock Source Selection -------- //
  param_mux #(
    .NUM_INPUTS(2),
    .SEL_WIDTH(1)
  ) mux2to1_final_select (
    .sel(i_cks[2]                     ), // 0 = internal clock; 1 = external/cascaded signal
    .in ({external_edge, clk_phi_edge}),
    .y  (o_TCNT_EN                    )
  );

endmodule : clk_sel_channel
