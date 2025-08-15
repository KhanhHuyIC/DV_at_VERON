module comparator(
  input  logic  [7:0] i_tcora_0   ,
  input  logic  [7:0] i_tcora_1   ,
  input  logic  [7:0] i_tcorb_0   ,
  input  logic  [7:0] i_tcorb_1   ,
  output logic        o_final_comp
);

  assign o_final_comp = {i_tcora_0, i_tcora_1} > {i_tcorb_0, i_tcorb_1};

endmodule : comparator
