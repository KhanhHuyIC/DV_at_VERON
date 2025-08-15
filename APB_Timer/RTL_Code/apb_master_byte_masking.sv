module apb_master_byte_masking #(
  parameter DATA_WIDTH = 32,              // Width of data (e.g., 32-bit)
  parameter STRB_WIDTH = DATA_WIDTH / 8   // Number of byte lanes (e.g., 4)
)(
  input  logic [STRB_WIDTH - 1:0] pstrb_byte_mask,
  input  logic [DATA_WIDTH - 1:0] apb_write_data ,
  input  logic [DATA_WIDTH - 1:0] PRDATA         ,
  output logic [DATA_WIDTH - 1:0] PWDATA
);

  genvar i;
  generate
    for (i = 0; i < STRB_WIDTH; i++) begin : byte_masking_gen
      mux_2_to_1 #(
        .WIDTH(8)
      ) byte_masking_mux (
        .in0 (PRDATA[i*8 +: 8]        ), // Read byte from PRDATA
        .in1 (apb_write_data[i*8 +: 8]), // Write byte from write_data
        .sel (pstrb_byte_mask[i]      ), // Byte enable
        .out (PWDATA[i*8 +: 8]        )  // Output masked byte
      );
    end
  endgenerate

endmodule : apb_master_byte_masking
