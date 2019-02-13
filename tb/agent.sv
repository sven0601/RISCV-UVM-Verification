`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"

class riscv_agent extends uvm_agent;

    `uvm_component_utils(riscv_agent)
    
    riscv_sequencer seqr;
    riscv_driver    driver;
  	riscv_monitor	monitor;
  	    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      	monitor = riscv_monitor::type_id::create("monitor", this);
      seqr = riscv_sequencer::type_id::create("seqr", this); 
      driver = riscv_driver::type_id::create("driver", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver.seq_item_port.connect( seqr.seq_item_export );
      
//      riscv_driv.rsp_port.connect( sha1_seqr.rsp_export );
    endfunction: connect_phase
    
  endclass: riscv_agent
    