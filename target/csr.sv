

module cs_reg(
  	input clk,
  	input reset,
  	input csr,
  	input [11:0]rd_addr,
	output reg [31:0]csr_rd,
	input [31:0]wr_dat

);

  reg [31:0]csrm[4095:0];

  always @(posedge clk) begin
  if (reset) begin 
    if (csr) begin
        csr_rd  = csrm [rd_addr];
      	csrm[rd_addr] = wr_dat;
   end
//   else csr_rd = 32'b0;
end
end
 
 
endmodule // cs_reg