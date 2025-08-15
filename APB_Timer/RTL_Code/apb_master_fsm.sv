module apb_master_fsm (
  input  logic       PCLK    ,  // APB clock
  input  logic       PRESETn ,  // APB active-low reset
  input  logic       transfer,  // Transfer request from master
  input  logic       PREADY  ,  // Ready signal from slave
  output logic [1:0] state      // Current FSM state
);

  typedef enum logic [1:0] {
    IDLE   = 2'b00,
    SETUP  = 2'b01,
    ACCESS = 2'b10
  } state_t;

  state_t current_state, next_state;

  // FSM state register
  always_ff @(posedge PCLK) begin
    if (!PRESETn) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  assign state = current_state;

  // FSM next-state logic
  always_comb begin
    case (current_state)
      IDLE   : next_state = transfer ? SETUP : IDLE                    ;
      SETUP  : next_state = ACCESS                                     ;
      ACCESS : next_state = PREADY ? (transfer ? SETUP : IDLE) : ACCESS;
      default: next_state = IDLE                                       ;
    endcase
  end

endmodule : apb_master_fsm
