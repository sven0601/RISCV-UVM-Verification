`include "csr.sv"
`include "DM.sv"
`include "core.sv"


module riscv_wrapper(
	input clk,
	input reset,
	output trap,
  	output [31:0] pc,
  	input [31:0] instr
);
  
  wire [31:0]csr_wr_data, csr_rd_data, m_addr, m_rd_dat, m_wr_dat;
  wire [11:0]csr_rd_addr, csr_wr_addr;
  
  riscv_core core(
    		.clk(clk),.reset(reset),
                 
    		.pc(pc),.instr_in(instr),
     
    		.trap(trap),
                        
            .csr_rd(csr_rd),
    		.csr_wr(csr_wr),
            .csr_rd_addr(csr_rd_addr),
    		.csr_wr_addr(csr_wr_addr),
            .csr_wr_data(csr_wr_data),
            .csr_rd_data(csr_rd_data),
            
            .MemRead_l2(rd_en),
    		.MemWrite_l2(wr_en),
            .m_addr(m_addr),
            .m_wr_dat(m_wr_dat),
            .m_rd_dat(m_rd_dat)
           );

/* IM ins_mem(.clk(clk),
            .reset(reset),
            .pc(pc),
            .instr(instr_in)
           );
*/
  
cs_reg csre(.clk(clk),
            .reset(reset),       
            .csr_rd(csr_rd),
    		.csr_wr(csr_wr),
            .rd_addr(csr_rd_addr),
            .rd_dat(csr_rd_data),
            .wr_addr(csr_wr_addr),
            .wr_dat(csr_wr_data)
           );
  
data_memory mem(.clk(clk),
             .reset(reset),
             .m_addr(m_addr),
             .m_wr_dat(m_wr_dat),
             .rd_en(rd_en),
             .wr_en(wr_en),
             .m_rd_dat(m_rd_dat)
            );
  
  
/*  
  always @(pc) begin
  $display("PC          = %d  ",pc);
  $display("Reset       = %d  ",reset);
  $display("Instruction = 0x%h  ",instr);
  $display("ALU output  = %d  ",m_addr); 
//  if (MemWrite) $display("Data 0x%h written to address %d",m_wr_dat, m_addr);
    $display("---------------------------------------------------------------");
end
  */
/*  always @(pc) begin
    $display("PC = %h : instr = %h", pc, instr);
  end*/
  endmodule