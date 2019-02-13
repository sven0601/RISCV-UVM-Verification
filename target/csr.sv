

module cs_reg(
    input clk,
  	input reset,
  	input csr,
  input [11:0]rd_addr,
	output reg [31:0]csr_rd,
	input [31:0]wr_dat
/*
    output [31:0]mstatus,
    output mie,
    output mip,
    output [31:0]mtvec,
    output [31:0]mcycle,
    output [31:0]minstret,
    output [31:0]mcycleh,
    output [31:0]minstreth
*/

);

  reg [31:0]csrm[4095:0];



 initial begin
   csrm[12'h304] =32'b0;
   csrm[12'h344] = 32'b0;
    
 end
  /*   
      
    csr[0xC00] = 32'b0; // cycle
    csr[0xC01] = 32'b0; // time
    csr[0xC02] = 32'b0; // instret
    
    csr[0xC80] = 32'b0; // cycleh
    csr[0xC81] = 32'b0; // timeh
    csr[0xC82] = 32'b0; // instreth

  
 	assign mcycle = csrm[12'hC00];
  	assign minstret = csrm[12'hC02];
  	assign mcycleh = csrm[12'hC80];
  	assign minstreth = csrm[12'hC82];

  assign mstatus = csrm[12'h300];
  assign mie = csrm[12'h304][7];
  assign mip = csrm[12'h344][7];
  assign mtvec = csrm[12'h305];

*/
always @(posedge clk) begin
  if (reset) begin 
    if (csr) begin
        csr_rd  = csrm [rd_addr];
   end
   else csr_rd = 32'b0;
end
end
  /*
always @(posedge clk) begin
  if(csrm[12'hC00] == 32'hffffffff) csrm[12'hC80] = csrm[12'hC80] + 1;
    else csrm[12'hC00] = csrm[12'hC00] + 1;
  
  if(csrm[12'hC02] == 32'hffffffff) csrm[12'hC82] = csrm[12'hC82] + 1;
    else csrm[12'hC02] = csrm[12'hC02] + 1;
end
  */
 
endmodule // cs_reg