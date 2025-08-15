module wait_state_shift_reg #(
  parameter WAIT_CYCLE = 2
)(
  input  logic                  PCLK        ,
  input  logic                  PRESETn     ,
  input  logic                  PENABLE     ,
  input  logic                  access      ,
  output logic [WAIT_CYCLE-1:0] wait_counter,
  output logic                  PREADY
);

  always_ff @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      wait_counter <= '0;
    end else begin
      if (!PENABLE) begin
        wait_counter <= '0;
      end else begin
        wait_counter <= {wait_counter[WAIT_CYCLE-2:0], access};
		  end
    end
  end

  assign PREADY = wait_counter[WAIT_CYCLE - 1];

endmodule : wait_state_shift_reg
