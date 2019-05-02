module registers(
  	input clk,
  	input reset,
	input [4:0] rs1,
	input [4:0] rs2,
  	input [4:0] rd,
	input [31:0] reg_wr_dat,
	input regWrite,
	output reg [31:0] rd1,
	output reg [31:0] rd2
	);
 
  reg [31:0] registry [31:1], test;
  
  initial begin
    for (int i = 1; i<32; ++i)
      registry[i] = 32'h0;
  end
  
  always_comb begin
  	rd1 =  (reset & (rs1!=5'b0)) ? registry[rs1] : 32'h0;
  	rd2 =  (reset & (rs2!=5'b0)) ? registry[rs2] : 32'h0;
    uvm_config_db #(reg[31:0])::set(uvm_root::get(),"*","rd1", rd1);
  end
  
  
  always@ (posedge clk) begin    
    if(reset & regWrite & (rd!=5'b0)) begin      registry[rd] <= reg_wr_dat;
      test <= reg_wr_dat;
    end
  end
  
  
endmodule // registers