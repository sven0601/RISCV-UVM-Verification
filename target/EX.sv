module ALU(
	input [31:0]alu_in1,
	input [31:0]alu_in2,
	input [2:0]ALUop,
	input invert,
	input [2:0]funct,
	output reg [31:0] alu_out,
	output reg zero,
	output reg less_than
	);


reg [32:0]alu_res;
wire [31:0]alu2;
reg [2:0]op;
reg carry;
reg [31:0]temp;


always @ (*) begin
case (ALUop)
	3'b000: op <= funct;
	3'b001: op <= 3'b000;
	3'b010: op <= 3'b000; 
	3'b011: op <= 3'b000;
    3'b100: op <= {1'b1,funct[1:0]}; // csr
	3'b101: begin 
		op <= 3'b000;
		temp <= ~alu_in2 + 1;
	end // 3'b101:
    3'b110: op <= {1'b1,1'b1,funct[0]};
	default: op <= 3'b000;
endcase // ALUop

case(op)
  3'b000:	alu_res <= {1'b0,alu_in1} + {1'b0,alu2};	// add
	3'b001: alu_res <= {1'b0,alu_in1} << {1'b0,alu2};		// Shift left
	3'b010: alu_res <= {1'b0,alu_in1} - {1'b0,alu2};		// set if less
	3'b011: alu_res <= {1'b0,alu_in1} - {1'b0,alu2};		// set if less Unsigned
	3'b100: alu_res <= {1'b0,alu_in1} ^ {1'b0,alu2};		// XOR
	3'b101: begin alu_res <= {1'b0,alu_in1} >> {1'b0,alu2};		// Shift right
      if (invert ) alu_res[31] <= alu_in1[31]; end
	3'b110: alu_res <= {1'b0,alu_in1} | {1'b0,alu2};		// OR
	3'b111: alu_res <= {1'b0,alu_in1} & {1'b0,alu2};		// AND
	default: alu_res <= 33'h00000000;  // default
endcase // op 
 
  if (op[2:1] == 2'b01) begin
      less_than <= alu_res[31];
      alu_out <= less_than;
    end
    else begin 
      alu_out <= alu_res[31:0];
      less_than <= 1'b0;
    end
  
  carry = alu_res[32];
  zero = (alu_res == 0)?1'b1:1'b0;
end 
  
assign alu2 = (invert)? temp: alu_in2;

endmodule // ALU
