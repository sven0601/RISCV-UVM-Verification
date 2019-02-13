
interface riscv_if( input clk, input reset);  
	  
  
  logic [31:0] pc; //  program counter 32bit
  logic [31:0]instr; // instr 32bit  
  
  clocking driver_cb @(posedge clk);
    output instr;
    input pc;
    endclocking
  
  clocking monitor_cb @(posedge clk);
    input instr;
    input pc;
    endclocking
  
  
  modport DRIVER  (clocking driver_cb,input clk,reset);
  modport MONITOR  (clocking monitor_cb,input clk,reset);

/*  covergroup instructions;
    ins : coverpoint instr[6:0] {
      bins LUI = {7'b0110111};
      bins AUIPC = {7'b0010111};
      bins JAL = {7'b1101111};
      bins JALR = {7'b1100111};
      bins BRANCH = {7'b1100011};
      bins LOAD = {7'b0000011};
      bins STORE = {7'b0100011};
      bins ITYPE = {7'b0010011};
      bins RTYPE = {7'b0110011};
      bins FENCE = {7'b0001111};
      bins CSR = {7'b1110011};
    }
  endgroup

    
  instructions cov = new();
*/
endinterface: riscv_if
    
    