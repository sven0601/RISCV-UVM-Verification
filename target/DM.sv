module data_memory(
	input clk,
  	input reset,
	input [31:0]m_addr,
    input [31:0]m_wr_dat,
    input rd_en,
    input wr_en,
    output reg [31:0]m_rd_dat
	);


  reg [31:0]mem[(2**30) - 1:0];
  
  initial begin
    mem[49152] = 32'h0;
    mem[49168] = 32'h0;
    mem[49184] = 32'h0;
    mem[49200] = 32'h0;
    mem[49216] = 32'h0;
    mem[49232] = 32'h0;
    mem[49248] = 32'h0;
    mem[49264] = 32'h0;
    mem[49280] = 32'h0;
  end
 
  always @(posedge clk) begin
    m_rd_dat <= (rd_en & reset) ? mem[m_addr << 2] : 32'h0;
    if  (wr_en & reset) begin
      	mem[m_addr << 2] <= m_wr_dat;
//        $display("%h",m_wr_dat);
    end

    
  end

endmodule