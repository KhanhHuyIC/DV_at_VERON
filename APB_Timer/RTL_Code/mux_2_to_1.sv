module mux_2_to_1 #(
  parameter WIDTH = 8            // Width of data inputs and output
) (
  input  logic [WIDTH-1:0] in0,   // Input 0
  input  logic [WIDTH-1:0] in1,   // Input 1
  input  logic             sel,   // Select signal
  output logic [WIDTH-1:0] out    // Output
);

  assign out = ~sel ? in0 : in1;

endmodule : mux_2_to_1
