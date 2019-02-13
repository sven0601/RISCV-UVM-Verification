

module registers(
	input clk,
  	input reset,
	input [4:0] rs1,
	input [4:0] rs2,
  	input [4:0] rd,
	input [31:0] reg_wr_dat,
	input regWrite,
	output [31:0] rd1,
	output [31:0] rd2
	);

reg [31:0] ram [31:0];
initial begin
  	ram[0] = 32'd0;
  ram[1] = 32'd5;
  ram[2] = 32'd10;
  ram[3] = 32'd15;
  ram[4] = 32'd20;
  ram[6] = 32'hffffffff;
end



always @(posedge clk) begin
  if(regWrite & (rd!=5'b0)) begin
	ram[rd] <= reg_wr_dat;
    end
  end // always @(posedge clk)

  always @(*) begin
    ram[0] <= 32'b0;
  end
  assign rd1 = reset? ram[rs1] : 32'b0;
  assign rd2 = reset? ram[rs2] : 32'b0;
 
endmodule // registers