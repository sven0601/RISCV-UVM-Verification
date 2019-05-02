module pc_control(
  	input reset,
	input [31:0]pc,
  	input [31:0]Imm_pc,
	input [2:0]funct,
    input jal,
	input zero,
	input less_than,
	input branch,
	input jump,
  	input [31:0]Imm_jalr,
  	output reg [31:0]pc_in0,
  	output reg [31:0]next_pc
	);
  

reg [31:0] pc_in1;
reg b_type, pc_sel;

  always_comb begin
    case ({funct[2],funct[0]})
        2'b00: b_type = zero;
        2'b01: b_type = ~zero;
        2'b10: b_type = less_than;
        2'b11: b_type = ~ (less_than | zero);
    endcase 
    pc_sel = (jump) | (branch & b_type);
  	pc_in0 = reset ? pc + 32'd4 : 32'h0;
  	pc_in1 = (jump & ~jal) ? Imm_jalr : (pc + $signed(Imm_pc));
  	next_pc = reset ? (pc_sel ? pc_in1 : pc_in0) : 32'h0;
end  
    
endmodule 
