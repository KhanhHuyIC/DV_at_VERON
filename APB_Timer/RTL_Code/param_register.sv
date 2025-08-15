module param_register #(
  parameter WIDTH      = 32,
  parameter NUM_SLAVE  = 8
)(
  input  logic                            clk  ,
  input  logic                            rst_n,
  input  logic                            en   ,                          
  input  logic [NUM_SLAVE-1:0][WIDTH-1:0] d    ,     
  output logic [NUM_SLAVE-1:0][WIDTH-1:0] q            
);

  genvar i;
  generate
    for (i = 0; i < NUM_SLAVE; i++) begin : gen_param_reg
      apb_register #(
        .WIDTH(WIDTH)
      ) u_apb_register (
        .clk  (clk     ),
        .rst_n(rst_n   ),
        .en   (en      ),         // tất cả share chung enable
        .d    (d[i]    ),
        .q    (q[i]    )
      );
    end
  endgenerate

endmodule
