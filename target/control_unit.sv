module control_unit(
	input [6:0]opcode,
  	input reset,
    input invert,
  	input [2:0]funct,
	output [1:0]ImSel,
    output jump,
    output branch,
    output Alusrc1,
    output Alusrc2,
    output regWrite,
    output MemRead,
    output MemWrite,
    output H_sel,
    output csr,
    output [1:0]wr_sel,
    output [2:0]ALUop,
    output fence
	);

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



assign jump = reset ? j_type : 0 ;
assign branch = reset ? b_type : 0;
assign Alusrc1 = reset ? u_type : 0;
assign Alusrc2 = reset ? ~(b_type | r_type) : 0;
assign regWrite = reset ? ~(s_type | b_type) : 0;
assign MemRead = reset ? load_type : 0;
assign MemWrite = reset ? s_type : 0;
assign H_sel = reset ? j_type & opcode[3] : 0;
assign csr = reset ? csr_type : 0;
assign ImSel[0] = reset ? i_type | u_type | j_type | load_type : 0;
assign ImSel[1] = reset ? u_type | s_type : 0;
assign wr_sel[0] = reset ? j_type | load_type | s_type : 0;
assign wr_sel[1] = reset ? csr_type | j_type | (u_type&opcode[5]) : 0;
assign ALUop[0] = reset ? u_type | j_type | load_type | b_type | (r_type&invert&(funct==3'b0)) : 0;
assign ALUop[1] = reset ? load_type | s_type : 0;
  assign ALUop[2] = reset ? csr_type | b_type | (r_type&invert&(funct==3'b0)) : 0;


endmodule // control_unit

