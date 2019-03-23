`include "interface.sv"
`include "seq_item.sv"
`include "sequence.sv" 
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "subscriber.sv"
`include "scoreboard.sv"
`include "env.sv"
`include "test.sv"

module top();
   
  bit clk;
  bit reset;

  initial begin
   $dumpfile("dump.vcd"); 
   $dumpvars;  	
    clk = 0;
    reset = 0;
    #5 reset = 1;
  end

  always #2 clk = ~clk;
   
 
  riscv_if riscv_if0 (.clk(clk), .reset(reset));


  riscv_wrapper dut(
    .clk(riscv_if0.clk),
    .reset(riscv_if0.reset),
    .trap(riscv_if0.trap),
    .pc(riscv_if0.pc),
    .instr(riscv_if0.instr));
  
  

  initial begin
    uvm_config_db #(virtual riscv_if)::set(uvm_root::get(),"*","trans", riscv_if0);

   	 end
  
initial begin

   run_test("riscv_test");
end
  
  
endmodule
