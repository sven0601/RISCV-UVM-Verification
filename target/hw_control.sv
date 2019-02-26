module hw_control(
  	input clk,
  	input reset,
    output reg [31:0]predecessor,
    output reg [31:0]successor,
	input [31:0]pc,
	input [31:0]Imm_H,
	input [2:0]funct,
    input H_sel,
    input fence,
	input zero,
	input less_than,
	input branch,
	input jump,
	input [31:0]alu_out_h,
  	output reg [31:0]next_pc,
	output reg [31:0]pc_out
	);
  

wire [31:0] pc_in0;
wire [31:0] pc_in1;
reg [31:0]prev;
reg b_type;
reg pc_sel;

always @(*) begin
case ({funct[2],funct[0]})
	2'b00: b_type = zero;
	2'b01: b_type = ~zero;
	2'b10: b_type = less_than;
  	2'b11: b_type = ~ (less_than | zero);
endcase
  pc_sel <= (jump) | (branch & b_type);
end  
  
always @(*) begin
    if(!fence)  prev  = pc;
  	next_pc = pc + 32'd4 ;
	pc_out = reset ? (pc_sel ? pc_in1 : pc_in0) : 32'b0;
end 
  
always @(fence) begin
    predecessor <= prev;
    successor <= next_pc;
end

assign pc_in0 = next_pc;
assign pc_in1 = (jump & ~H_sel) ? alu_out_h : (pc + Imm_H);
  
endmodule 
