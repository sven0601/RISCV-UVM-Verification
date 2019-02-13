
module sign_extend_csr(
	input [4:0]se_csr_in,
  output [31:0]se_csr_imm
	);
assign se_csr_imm = {28'b0,se_csr_in};

endmodule




// Sign extend of I Type 
module sign_extend_I(
  	input [11:0]se_I_in,
	output [31:0]se_I_imm
	);
  assign se_I_imm = {20'b0,se_I_in};
endmodule


// Sign extend of S Type
module sign_extend_S(
	input [6:0]se_S_in1,
	input [4:0]se_S_in2,
	output [31:0]se_S_imm
	);
  	assign se_S_imm = {20'b0,se_S_in1,se_S_in2};
endmodule




// Sign extend of U Type
module sign_extend_U(
	input [19:0]se_U_in,
	output [31:0]se_U_imm
	);
  assign se_U_imm = {se_U_in,12'b0};
endmodule




// Sign extend of J 
module sign_extend_J(
	input [19:0]se_J_in,
	output [31:0]se_J_imm
	);
  assign se_J_imm = {12'b0,se_J_in[19],se_J_in[7:0],se_J_in[8],se_J_in[18:9],1'b0};
endmodule



// Sign extend of B 
module sign_extend_B(
	input [6:0]se_B_in1,
	input [4:0]se_B_in2,
	output [31:0]se_B_imm
	);
  assign se_B_imm = {20'b0,se_B_in1[6],se_B_in2[0],se_B_in1[5:0],se_B_in2[4:1],1'b0};
endmodule
