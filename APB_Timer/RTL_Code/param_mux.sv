module param_mux #(
  parameter int NUM_INPUTS = 4                 , 
  parameter int DATAWIDTH  = 1                 ,
  parameter int SEL_WIDTH  = $clog2(NUM_INPUTS)
)(
  input  logic [NUM_INPUTS-1:0][DATAWIDTH-1:0] in , // Array of inputs, each DATAWIDTH bits wide
  input  logic [SEL_WIDTH-1:0]                 sel, // Select signal to choose one of the inputs
  output logic [DATAWIDTH-1:0]                 y
);

  assign y = in[sel];

endmodule : param_mux
