
`include "seq_item.sv"

class riscv_sequence extends uvm_sequence#(riscv_seq_item);
  
  `uvm_object_utils(riscv_sequence)
  
  riscv_seq_item trans;
  
  function new (string name = "riscv_sequence");
      super.new(name);
  endfunction
 
  task body();
    repeat (50) begin
        trans = riscv_seq_item::type_id::create("trans");
        trans.randomize();
        start_item(trans);
          finish_item(trans);
//        $display("SEQUENCE	:	pc = %d		instr = %b\n", trans.pc, trans.instr);
        end 
    endtask
   
endclass: riscv_sequence
     