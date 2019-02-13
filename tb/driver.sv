
class riscv_driver extends uvm_driver #(riscv_seq_item);
  
    `uvm_component_utils(riscv_driver)

    virtual riscv_if vi;
    riscv_seq_item req;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      if( !uvm_config_db #(virtual riscv_if)::get(this, "", "trans", vi) )
        `uvm_error("", "uvm_config_db::get failed")
        req = riscv_seq_item::type_id::create("req",this);
    endfunction 
   
        
    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
 		drive(req);
//        vi.instructions.sample();
        seq_item_port.item_done();
      end
    endtask
      
      
      task drive(input riscv_seq_item req);
        @(posedge vi.DRIVER.clk);
        vi.instr = req.instr;
        req.pc = vi.pc;
//        $display("DRIVER	:	PC = %d	instr = %d\n", vi.pc, vi.instr);
      endtask
      
  
  endclass: riscv_driver
  
//-------------------------------------------------------------------------
//	