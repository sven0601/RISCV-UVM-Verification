`include "reg.sv"
`include "control_unit.sv"
`include "sign_extend.sv"
`include "EX.sv"
`include "pc_control.sv"

module riscv_core#(
				parameter XLEN = 32,
				IRQ = 0)(
  input clk,
  input reset,
  
  output reg [31:0]pc,
  input [31:0]instr_in,
  
  output reg trap,
/*
  // PLIC
  input EIP,
  input [31:0]irq_handler,
  output IRQ_complete,
*/
  
  // CSR
  output csr_rd,
  output reg csr_wr, 
  output reg [11:0]csr_rd_addr,
  output reg [11:0]csr_wr_addr,
  output reg [31:0] csr_wr_data,
  input [31:0]csr_rd_data,
  
  
  // DATA MEMORY
  output reg MemRead_l2,
  output reg MemWrite_l2,
  output reg [31:0]m_addr,
  output reg [31:0]m_wr_dat,
  input [31:0]m_rd_dat
  
);
  
  
/////////////////////////////////////////////////////////////
//	IF
/////////////////////////////////////////////////////////////

reg [31:0]  instr, pc_l1;
reg reset_l1; 
  
  always@(posedge clk) begin
    instr <= reset ? instr_in : 32'h0;
    pc_l1 <= pc; 
    reset_l1 <= reset;
//    $display("DUT : pc = %h, instr = %h", pc_l1, instr);
  end
   
/////////////////////////////////////////////////////////////
//	ID & EX & pc_control
/////////////////////////////////////////////////////////////
 
  
  

 wire [1:0] im_sel, wr_sel;
 wire [2:0] ALUop, funct;
 control_unit  debug(.reset(reset_l1),
                     .instr(instr),
                     .jump(jump),
                     .im_sel(im_sel),
                     .branch(branch),
                     .Alusrc1(Alusrc1),
                     .Alusrc2(Alusrc2),
                     .MemRead(MemRead),
                     .MemWrite(MemWrite),
                     .ALUop(ALUop),
                     .regWrite(regWrite),
                     .jal(jal),
                     .csr(csr_rd),
                     .wr_sel(wr_sel),
                     .funct(funct),
                     .invert(invert),
                     .fence(fence)
                    );
  
  
  
wire [31:0] rd1, rd2;
wire [4:0] rs1, rs2;
reg [31:0] reg_wr_dat;
reg [4:0] rd_l3; 
reg regWrite_l3;
  assign rs1 = instr[19:15];
  assign rs2 = instr[24:20];
registers regfetch (.clk(clk),		.reset(reset_l1),
                    .rs1(rs1),		.rs2(rs2),
                    .rd1(rd1),				.rd2(rd2),
                    .rd(rd_l3),
                    .reg_wr_dat(reg_wr_dat),
                    .regWrite(regWrite_l3)
                    );
  
  
wire [31:0]se_I_imm, se_S_imm, se_U_imm, se_J_imm, se_B_imm, se_csr_imm; 
sign_extend_I se_I(.se_I_in(instr[31:20]),
                   .opcode(instr[6:0]),
                   .funct(funct),
                   .se_I_imm(se_I_imm));

sign_extend_S se_S(.se_S_in1(instr[31:25]),
                   .se_S_in2(instr[11:7]),
                   .se_S_imm(se_S_imm));

sign_extend_U se_U(.se_U_in(instr[31:12]),
                   .se_U_imm(se_U_imm));

sign_extend_J se_J(.se_J_in(instr[31:12]),
                   .se_J_imm(se_J_imm));

sign_extend_B se_B(.se_B_in1(instr[31:25]),
                   .se_B_in2(instr[11:7]),
                   .se_B_imm(se_B_imm));
  
sign_extend_csr se_csr(.se_csr_in(instr[19:15]),
                       .se_csr_imm(se_csr_imm));
  
  
wire [31:0] IF_out1;
reg [31:0]Imm;
  
always_comb begin
  case (im_sel)
  2'b00: Imm = csr_rd_data;
  2'b01: Imm = se_I_imm;
  2'b10: Imm = se_S_imm;
  2'b11: Imm = se_U_imm;
endcase 
end

wire [31:0] alu_in1, alu_in2, Imm_pc, Imm_jalr;

assign IF_out1 = (csr_rd & instr[14]) ? se_csr_imm : (rs1 == rd_l3 ? reg_wr_dat : rd1);  
assign funct = instr[14:12];
 
assign alu_in1 = Alusrc1 ? pc_l1 : ((csr_rd & (funct[1:0]== 2'b11)) ? ~IF_out1 : IF_out1);
assign alu_in2 = Alusrc2 ? Imm : (rs2 == rd_l3 ? reg_wr_dat : rd2);
  
assign Imm_pc = jal ? se_J_imm : se_B_imm;
   
assign csr_wr_addr = instr[31:20];
assign csr_rd_addr = instr[31:20];   

  wire [31:0]alu_out, next_pc, pc_in0;
ALU compute (.reset(reset_l1),
               .alu_in1(alu_in1), 
               .alu_in2(alu_in2),
               .ALUop(ALUop),
               .invert(invert),
               .zero(zero),
               .less_than(less_than),
               .alu_out(alu_out));


  assign Imm_jalr = (jump & ~jal) ? {alu_out[31:1],1'b0} : 32'h0;
  
pc_control hw(.reset(reset_l1), 
                .pc(pc_l1),
                .Imm_pc(Imm_pc),
                .funct(funct),
                .jal(jal),
                .zero(zero),
                .less_than(less_than),
              	.branch(branch),
                .jump(jump),
                .Imm_jalr(Imm_jalr),
              	.pc_in0(pc_in0),
                .next_pc(next_pc));

  
  reg [31:0] Imm_l2, pc_in0_l2;
  reg [4:0] rd_l2;
  reg [2:0] ALUop_l2, funct_l2;
  reg [1:0] wr_sel_l2;
  reg reset_l2, regWrite_l2;  
   
  
  always @ (posedge clk) begin
    
    uvm_config_db #(reg[31:0])::set(uvm_root::get(),"*","reg_rd_dat", (instr[11:7] == 5'b00000) ? 32'b0 : alu_out);
    reset_l2 <= reset_l1; 
    trap <= (instr == 32'h00100073) | ((instr == 32'h0) & reset_l1) ? 1 : 0;
    pc_in0_l2 <= pc_in0;
    
    
    pc <= reset_l1 ? next_pc : 32'h0;
    
    
    csr_wr <= csr_rd;
  	csr_wr_data <= csr_wr ? (funct[1] ? alu_out : alu_in1): 32'b0;
    
    rd_l2 <= instr[11:7];
    regWrite_l2 <= regWrite;
    
    funct_l2 <= funct;
    wr_sel_l2 <= wr_sel;
    Imm_l2 <= Imm;
    
    m_addr <= alu_out;
    MemWrite_l2 <= MemWrite;
    MemRead_l2 <= MemRead;
    
    if (reset_l1) begin
      if (MemWrite) begin  
        case (funct[1:0])
              2'b00: m_wr_dat <= rd2 & 32'h000000ff;
              2'b01: m_wr_dat <= rd2 & 32'h0000ffff;
              2'b10: m_wr_dat <= rd2;
              2'b11: m_wr_dat <= rd2;
        endcase
      end  else m_wr_dat <= 32'h0;
    end 
    else m_wr_dat <= 32'h0;
    
  end
/////////////////////////////////////////////////////////////
//	DM
/////////////////////////////////////////////////////////////
  
always @ (posedge clk) begin
    regWrite_l3 <= regWrite_l2;
    rd_l3 <= rd_l2;

   	if (reset_l2) begin
      case (wr_sel_l2)
        2'b00: reg_wr_dat <= m_addr;
        2'b01: if (MemRead_l2) begin
          		case (funct_l2[1:0])
                  2'b00: reg_wr_dat <= m_rd_dat & 32'h000000ff;
                  2'b01: reg_wr_dat <= m_rd_dat & 32'h0000ffff;
                  2'b10: reg_wr_dat <= m_rd_dat;
                endcase
              end 
        2'b10: reg_wr_dat <= Imm_l2; 
        2'b11: reg_wr_dat <= pc_in0_l2; 
      endcase 
    end
  	else reg_wr_dat <= 32'h0;
  
     
  if (MemRead_l2)    begin
    uvm_config_db #(reg[31:0])::set(uvm_root::get(),"*","m_addr", m_addr << 2);   
    uvm_config_db #(reg[31:0])::set(uvm_root::get(),"*","m_dat",  m_rd_dat);
  end

    if (MemWrite_l2)    begin
    uvm_config_db #(reg[31:0])::set(uvm_root::get(),"*","m_addr", m_addr << 2);   
    uvm_config_db #(reg[31:0])::set(uvm_root::get(),"*","m_dat", m_wr_dat);
  end
    
  
end 

  
/////////////////////////////////////////////////////////////
//	WB
/////////////////////////////////////////////////////////////

  
  
endmodule
/////////////////////////////////////////////////////////////
