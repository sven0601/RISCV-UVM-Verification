`include "csr.sv"
`include "DM.sv"
`include "core.sv"


module riscv_wrapper(  
  
      input clk,
      input reset,
  output trap,
  output [31:0]pc,
  input [31:0]instr);


  wire [31:0] csr_wr_data, csr_rd_data, m_addr, m_wr_dat;
  wire [31:0]m_rd_dat;
  wire [11:0]csr_rd_addr;
  
  riscv_core 			cpu(
    		.clk(clk),.reset(reset),
                 
    		.pc(pc),.instr_in(instr),
    
    		.trap(trap),
            
            .csr(csr),
            .csr_rd_addr(csr_rd_addr),
            .csr_wr_data(csr_wr_data),
            .csr_rd_data(csr_rd_data),
            
            .MemRead(MemRead),
            .MemWrite(MemWrite),
            .m_addr(m_addr),
            .m_wr_dat(m_wr_dat),
            .m_rd_dat(m_rd_dat)
           );

/* IM ins_mem(.clk(clk),
            .reset(reset),
            .pc(pc + INS_BASE_ADDR),
            .instr(instr)
           );
*/	
  
cs_reg csre(.clk(clk),
           .reset(reset),
            .csr(csr),
            .rd_addr(csr_rd_addr),
            .csr_rd(csr_rd_data),
            .wr_dat(csr_wr_data)
           );
  
memory mem(.clk(clk),
             .reset(reset),
             .m_addr(m_addr),
             .m_wr_dat(m_wr_dat),
             .rd_en(MemRead),
             .wr_en(MemWrite),
             .m_rd_dat(m_rd_dat)
            );
  
  /*
  always @(pc) begin
  $display("PC          = %d  ",pc);
  $display("Reset       = %d  ",reset);
  $display("Instruction = 0x%h  ",instr);
//  $display("ALU output  = %d  ",m_addr); 
//  if (MemWrite) $display("Data 0x%h written to address %d",m_wr_dat, m_addr);
    $display("---------------------------------------------------------------");
end*/
  
  endmodule