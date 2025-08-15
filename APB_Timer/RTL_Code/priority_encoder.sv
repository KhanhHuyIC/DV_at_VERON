module priority_encoder(
  input  logic i_os0,
  input  logic i_os1,
  input  logic i_os2,
  input  logic i_os3,
  output logic o_y0 ,
  output logic o_y1
);

  assign o_y0 = (i_os0 & (!i_os3 | i_os1)) | (i_os2 & (!i_os1 | i_os3));
  assign o_y1 = (i_os1 | i_os3)                                        ;

endmodule : priority_encoder
