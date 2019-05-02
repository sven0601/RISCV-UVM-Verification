module sign_extend_csr(
	input [4:0]se_csr_in,
  	output [31:0]se_csr_imm
	);
  assign se_csr_imm = {27'b0,se_csr_in};

endmodule


module sign_extend_I(
  	input [6:0]opcode,
  	input [11:0]se_I_in,
  	input [2:0] funct,
	output [31:0]se_I_imm
	);
  assign se_I_imm = ((funct[1:0] == 2'b01) & (opcode == 7'b0010011)) ? {27'b0,se_I_in[4:0]} : {{21{se_I_in[11]}},se_I_in[10:0]};
endmodule


module sign_extend_S(
	input [6:0]se_S_in1,
	input [4:0]se_S_in2,
	output [31:0]se_S_imm
	);
  assign se_S_imm = {{21{se_S_in1[6]}},se_S_in1[5:0],se_S_in2};
endmodule



module sign_extend_U(
	input [19:0]se_U_in,
	output [31:0]se_U_imm
	);
  assign se_U_imm = {se_U_in,12'b0};
endmodule



module sign_extend_J(
	input [19:0]se_J_in,
	output [31:0]se_J_imm
	);
  assign se_J_imm = {{12{se_J_in[19]}},se_J_in[7:0],se_J_in[8],se_J_in[18:9],1'b0};
endmodule



// Sign extend of B 
module sign_extend_B(
	input [6:0]se_B_in1,
	input [4:0]se_B_in2,
	output [31:0]se_B_imm
	);
  assign se_B_imm = {{20{se_B_in1[6]}},se_B_in2[0],se_B_in1[5:0],se_B_in2[4:1],1'b0};
endmodule
