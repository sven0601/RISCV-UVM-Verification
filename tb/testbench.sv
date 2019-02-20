

`include "interface.sv"
`include "test.sv"
module top();
   
  bit clk;
  bit reset;

  initial begin
   $dumpfile("dump.vcd"); 
   $dumpvars;  	
    clk = 0;
    reset = 0;
    #12 reset = 1;
  end

  always #5 clk = ~clk;
   
 
  riscv_if riscv_if0 (.clk(clk), .reset(reset));


  riscv_wrapper dut(
    .clk(riscv_if0.clk),
    .reset(riscv_if0.reset),
    .pc(riscv_if0.pc),
    .instr(riscv_if0.instr));
  
  

  initial begin
    uvm_config_db #(virtual riscv_if)::set(uvm_root::get(),"*","trans", riscv_if0);

   	 end
  
initial begin

  run_test();
end
  
  
endmodule