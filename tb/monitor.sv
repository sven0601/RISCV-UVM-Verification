
class riscv_monitor extends uvm_monitor;
  
  `uvm_component_utils(riscv_monitor)
  
  uvm_analysis_port #(riscv_seq_item) m_port;
  
  
  riscv_seq_item seq;
  virtual riscv_if inf;
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
    m_port = new("m_port",this);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual riscv_if)::get(this,"","trans",inf))
      `uvm_error("", "uvm_config_db::get failed") 
  endfunction: build_phase
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq = riscv_seq_item::type_id::create("seq") ;
      @ (posedge inf.MONITOR.clk )    
      seq.pc = inf.pc;
      seq.instr = inf.instr;    
      seq.reset = inf.reset;
//      $display("MONITOR	:	pc = %d		instr = %d\n", seq.pc, seq.instr);
      m_port.write(seq);
    end
  endtask : run_phase
endclass : riscv_monitor
      
    