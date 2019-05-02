
module control_unit(
  	input [31:0]instr,
  	input reset,
  	input [2:0]funct,
    output invert,
  	output [1:0]im_sel,
    output jump,
    output branch,
    output Alusrc1,
    output Alusrc2,
    output regWrite,
    output MemRead,
    output MemWrite,
    output jal,
    output csr,
    output [1:0]wr_sel,
    output [2:0]ALUop,
    output fence
); 
  
  wire [6:0]opcode;
assign opcode = instr[6:0];
wire rv = opcode[1] & opcode[0];
wire j_type = opcode[6] & opcode[5] & ~opcode[4] & opcode[2] & rv;
wire b_type = opcode[6] & opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] & rv;     // b_type + sub
wire u_type = ~opcode[6] & opcode[4] & ~opcode[3] & opcode[2] & rv;
wire load_type = ~opcode[6] & ~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] & rv;
wire s_type = ~opcode[6] & opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] & rv;
wire r_type = ~opcode[6] & opcode[5] & opcode[4] & ~opcode[3] & ~opcode[2] & rv;
wire i_type = ~opcode[6] & ~opcode[5] & opcode[4] & ~opcode[3] & ~opcode[2] & rv;
wire csr_type = opcode[6] & opcode[5] & opcode[4] & ~opcode[3] & ~opcode[2] & rv;

assign fence =  ~opcode[6] & ~opcode[5] & ~opcode[4] & opcode[3] & opcode[2] & rv;

assign invert = ((instr[31:25] == 7'b0100000) & (((funct == 3'b101)&(i_type | r_type)) | (r_type&(funct == 3'b000)))) | (MemRead & (funct[2:1]==2'b10)) ? 1 : 0 ;   


assign jump = reset ? j_type : 0 ;
assign branch = reset ? b_type : 0;
assign Alusrc1 = reset ? u_type : 0;
assign Alusrc2 = reset ? ~(b_type | r_type) : 0;
assign regWrite = reset ? ~(s_type | b_type | fence) : 0;
assign MemRead = reset ? load_type : 0;
assign MemWrite = reset ? s_type : 0;
assign jal = reset ? j_type & opcode[3] : 0;
assign csr = reset ? csr_type : 0;
assign im_sel[0] = reset ? i_type | u_type | j_type | load_type : 0;
assign im_sel[1] = reset ? u_type | s_type : 0;
assign wr_sel[0] = reset ? j_type | load_type | s_type : 0;
assign wr_sel[1] = reset ? csr_type | j_type | (u_type&opcode[5]) : 0;
assign ALUop[2] = reset ? ~(u_type | j_type | b_type | load_type | s_type ) & (((i_type | r_type) & funct[2]) | csr_type): 0;
assign ALUop[1] = reset ? ~(u_type | j_type | s_type) & (((i_type | r_type) & funct[1]) | (csr_type & funct[1]) | (b_type & funct[2])  | (load_type & (funct[2:1]==2'b10))): 0;
assign ALUop[0] = reset ? ~(u_type | j_type | s_type) & (((i_type | r_type) & funct[0]) | (csr_type & funct[0]) | (b_type & funct[1])  | (load_type & (funct[2:1]==2'b10))): 0;

endmodule // control_unit

