
module memory(
	input clk,
  	input reset,
	input [31:0]m_addr,
    input [31:0]m_wr_dat,
    input rd_en,// control signal
    input wr_en,
    output reg [31:0]m_rd_dat// read data from memory
	);


  reg [31:0]mem[1023:0];
  int file;
  
initial begin
  file = $fopen("dat_mem.txt", "w"); 
 

end

always @(posedge clk) begin
  if (reset) begin
	if (rd_en == 1) 
      m_rd_dat <= mem[m_addr];
    if (wr_en == 1) begin
      mem[m_addr] <= m_wr_dat;
      $display("Data :  %h written at Address : %h \n", m_wr_dat, m_addr);
      $fwrite(file,"%h \n",m_wr_dat);
    end
  end
    else m_rd_dat <= 32'b0;
end

endmodule