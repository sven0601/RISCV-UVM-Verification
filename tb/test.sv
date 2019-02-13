
`include "env.sv"     

class riscv_test extends uvm_test;
  
  `uvm_component_utils(riscv_test)
    
    riscv_env env;
    riscv_sequence sequ;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      env = riscv_env::type_id::create("env", this);
      sequ = riscv_sequence::type_id::create("sequ");
    endfunction
    
    task run_phase(uvm_phase phase);
     /* if( !sequ.randomize() ) 
        `uvm_error("", "Randomize failed")*/
      phase.raise_objection(this);
      sequ.start(env.agent.seqr);
      phase.drop_objection(this);
    endtask
      
  endclass: riscv_test
  