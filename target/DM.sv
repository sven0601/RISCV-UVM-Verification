
module memory(
	input clk,
  	input reset,
	input [31:0]m_addr,
    input [31:0]m_wr_dat,
    input rd_en,// control signal
    input wr_en,
    output reg [31:0]m_rd_dat// read data from memory
	);


  reg [31:0]mem[(2**25) - 1:0];
 initial begin
//   $readmemh("mem.txt", mem);
 end

  always @(*) begin
  if (reset) begin
    if (rd_en == 1) begin
      m_rd_dat <= mem[m_addr << 2];
    end
    if (wr_en == 1) begin
      mem[m_addr << 2] <= m_wr_dat;
  end
   
end
  end

endmodule