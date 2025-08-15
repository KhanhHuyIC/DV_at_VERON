module COMP (
  input  logic       i_wren       ,
  input  logic [7:0] i_data_comp_A,
  input  logic [7:0] i_data_comp_B,
  output logic       o_data_comp
);

  logic match_flag;

  assign match_flag  = (i_data_comp_A == i_data_comp_B);
  assign o_data_comp = (i_wren) ? 1'b0 : match_flag    ;

endmodule: COMP
