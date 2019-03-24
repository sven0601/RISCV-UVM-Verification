`include "control_unit.sv"
`include "hw_control.sv"
`include "EX.sv"
`include "reg.sv"
`include "se.sv"

module riscv_core#(
				parameter DATA_WIDTH = 32 )(
  input clk,
  input reset,
  
  output reg [31:0]pc,
  input [31:0]instr_in,
  
  output trap,
  
  output csr, 
  output [11:0]csr_rd_addr,
  output [31:0] csr_wr_data,
  input [31:0]csr_rd_data,
  
  output MemRead,
  output MemWrite,
  output [31:0]m_addr,
  output reg [31:0]m_wr_dat,
  input [31:0]m_rd_dat
  
);
   
  
wire [31:0]pc_out;
reg r_flag; // for reset
wire csri;
reg [31:0] csr_wr;
reg [31:0] temp;
wire [31:0]Imm_H;
reg [31:0] Imm;
wire [2:0]funct;
reg [31:0]reg_wr_dat;
wire [31:0]alu_out_h;
wire [31:0]alu_out;

  
wire [31:0] rd1, rd2, se_csr_imm, se_B_imm, se_J_imm, se_I_imm, se_S_imm, se_U_imm, csr_rd,IF_out1, next_pc;
wire jump, branch, Alusrc1, Alusrc2, regWrite, H_sel, c, invert;	
wire [1:0] ImSel, wr_sel;
wire [31:0] mtvec, mstatus, predecessor, successor;
wire [2:0]ALUop;
reg [31:0]instr;
  
always @(posedge clk) begin
  if (reset) begin
    pc <=  pc_out ;
    instr  <= instr_in;
    r_flag <= 0;
  end
  else begin
    pc <= 32'h0 ;
    instr <= 32'h0;
    r_flag <= 1;
  end
end
   
assign trap = (instr == 32'h00100073) ? 1 : 0;
assign csri = csr & funct[2];
assign funct = instr[14:12];
assign IF_out1 = csri? se_csr_imm : rd1;
assign Imm_H = H_sel? se_J_imm : se_B_imm;
assign alu_out = (funct[1] | (jump & ~H_sel))? m_addr : Imm;
assign alu_out_h = alu_out & 32'hfffffffe;
assign invert = (instr[31:25] == 7'b0100000) ? 1 : 0 ;


  control_unit  debug(.reset(reset),.opcode(instr[6:0]),.jump(jump),.ImSel(ImSel),.branch(branch),.Alusrc1(Alusrc1),.Alusrc2(Alusrc2),.MemRead(MemRead),.MemWrite(MemWrite),.ALUop(ALUop),.regWrite(regWrite),.H_sel(H_sel),.csr(csr),.wr_sel(wr_sel),.funct(funct),.invert(invert),.fence(fence));   // control unit
 
sign_extend_csr se_csr(.se_csr_in(instr[19:15]),.se_csr_imm(se_csr_imm));	// Sign extend of CSR 

  wire [4:0]rd;
  assign rd = instr[11:7];
  assign csr_rd_addr = instr[31:20];
  assign csr_wr_data = alu_out[31:0];
 
  sign_extend_I se_I(.se_I_in(instr[31:20]),.opcode(instr[6:0]),.funct(funct),.se_I_imm(se_I_imm));	// Sign extend of I Type

sign_extend_S se_S(.se_S_in1(instr[31:25]),.se_S_in2(instr[11:7]),.se_S_imm(se_S_imm));	// Sign extend of S Type

sign_extend_U se_U(.se_U_in(instr[31:12]),.se_U_imm(se_U_imm));	// Sign extend of U Type

sign_extend_J se_J(.se_J_in(instr[31:12]),.se_J_imm(se_J_imm));	// Sign extend of J 

sign_extend_B se_B(.se_B_in1(instr[31:25]),.se_B_in2(instr[11:7]),.se_B_imm(se_B_imm));	// Sign extend of B 

  registers regfetch(.clk(clk),.reset(reset),.rs1(instr[19:15]),.rs2(instr[24:20]),.rd(instr[11:7]),.reg_wr_dat(reg_wr_dat),.regWrite(regWrite),.rd1(rd1),.rd2(rd2));	// Register

  hw_control hw(.r_flag(r_flag),.reset(reset),.next_pc(next_pc),.predecessor(predecessor),.successor(successor),.pc(pc),.fence(fence),.Imm_H(Imm_H),.H_sel(H_sel),.funct(funct),.zero(zero),.less_than(less_than),.branch(branch),.jump(jump),.alu_out_h(alu_out_h),.pc_out(pc_out)); // Hardware control - jump branch and PC

  
always_comb begin
case (ImSel)// Mux for Immediate select
  2'b00: Imm = csr_rd_data;
  2'b01: Imm = se_I_imm;
  2'b10: Imm = se_S_imm;
  2'b11: Imm = se_U_imm;
endcase 
end


  
  
wire [31:0]alu_in1,alu_in2;

assign alu_in1 = Alusrc1 ? pc : IF_out1;	// Muxes for input to ALU respectively
assign alu_in2 = Alusrc2 ? Imm : rd2;

  ALU compute(.alu_in1(alu_in1),.alu_in2(alu_in2),.ALUop(ALUop),.funct(funct),.invert(invert),.zero(zero),.less_than(less_than),.alu_out(m_addr));



  
always_comb begin
    if (reset) begin
    if (ALUop[1]) begin  
       case (funct[1:0])
            2'b00: m_wr_dat = rd2 & 32'h000000ff;
            2'b01: m_wr_dat = rd2 & 32'h0000ffff;
            2'b10: m_wr_dat = rd2;
        endcase
    end  
    end 
    else m_wr_dat <= 32'h0;
end

  
always_comb begin 
case (wr_sel)
  2'b00: reg_wr_dat = m_addr;
  2'b01: if ( ALUop[1]) begin
        case (funct[1:0])
            2'b00: reg_wr_dat = m_rd_dat & 32'h000000ff;
            2'b01: reg_wr_dat = m_rd_dat & 32'h0000ffff;
            2'b10: reg_wr_dat = m_rd_dat;
        endcase
    	end 
  2'b10: reg_wr_dat = Imm; 
  2'b11: reg_wr_dat = next_pc; 
endcase 
end 
  
always_comb begin   
    
  if (MemRead)    begin
    uvm_config_db #(reg[31:0])::set(uvm_root::get(),"*","m_addr", m_addr << 2);   
    uvm_config_db #(reg[31:0])::set(uvm_root::get(),"*","m_dat", (instr[11:7] == 5'b00000) ? 32'b0 : reg_wr_dat);
  end

  if (MemWrite)    begin
    uvm_config_db #(reg[31:0])::set(uvm_root::get(),"*","m_addr", m_addr << 2);   
    uvm_config_db #(reg[31:0])::set(uvm_root::get(),"*","m_dat", m_wr_dat);
  end
end
  
endmodule