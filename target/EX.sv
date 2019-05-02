module ALU(
  	input reset,
	input [31:0]alu_in1,
	input [31:0]alu_in2,
	input [2:0]ALUop,
	input invert,
	output reg [31:0] alu_out,
	output reg zero,
	output reg less_than
	);


reg [32:0]alu_res;
   
wire [31:0]alu2, temp;


always_comb begin
  if (reset) begin    
      case (ALUop)
        3'b000: alu_res = $signed(alu_in1) + $signed(alu2);		// add
        3'b001: alu_res = alu_in1 << alu_in2[4:0];				// Shift left
        3'b010: alu_res = $signed(alu_in1) - $signed(alu2);		// set if less
        3'b011: alu_res = alu_in1 - alu2;						// set if less Unsigned
        3'b100: alu_res = alu_in1 ^ alu_in2;					// XOR
        3'b101: begin alu_res = alu_in1 >> alu_in2[4:0];		// Shift right
                  if (invert ) alu_res[31] = alu_in1[31];
                end
        3'b110: alu_res = alu_in1 | alu_in2;					// OR
        3'b111: alu_res = alu_in1 & alu_in2;					// AND
         default: alu_res = 33'h00000000;  						// default
      endcase  
 
      if (ALUop[2:1] === 2'b01) begin
        less_than = (alu_res[32] === 1) ? 1 : 0;
        alu_out = less_than;
      end else begin 
        alu_out = alu_res[31:0];
        less_than = 1'b0;
      end 
    zero = (alu_res == 33'b0) ? 1 : 0;
  end
  else begin
    alu_out = 32'b0;
    less_than = 0;
    zero = 0;
  end
end
  
  
  assign alu2 = invert ? (~alu_in2 + 32'b1): alu_in2;

endmodule