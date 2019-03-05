

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

reg [31:0] ram [31:0];
  
  always @ (*)	begin	// read
    if (reset & (rs1!=5'b0)) begin
      rd1 = ram[rs1];
    end
    else begin
      rd1 = 32'b0;
    end
    
    uvm_config_db #(reg[31:0])::set(uvm_root::get(),"*","reg_rd_dat", rd1);
    
    if (reset & (rs2!=5'b0)) begin
      rd2 = ram[rs2];
    end
    else begin
      rd2 = 32'b0;
    end
  end

  always @(posedge clk) begin	//	write
    
  if(reset & regWrite ) begin
    if (rd==5'b0)
      ram[rd] <= 32'b0;
    else 
      ram[rd] <= reg_wr_dat;
    end
     
  end // always @(posedge clk)


 
endmodule // registers