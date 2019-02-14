
`include "seq_item.sv"

class riscv_sequence extends uvm_sequence#(riscv_seq_item);
  
  `uvm_object_utils(riscv_sequence)
  
  riscv_seq_item trans;
  function new (string name = "riscv_sequence");
      super.new(name);     
  endfunction
  
  
  task body();
    
    repeat (30) begin
      	trans = riscv_seq_item::type_id::create("trans");
        trans.randomize();
        start_item(trans);
          finish_item(trans);
        end 
   
    
    repeat (10) begin	// LOAD
        trans = riscv_seq_item::type_id::create("trans");
        trans.randomize();       
      	trans.instr[6:0] = 7'b0000011;
        start_item(trans);
        finish_item(trans);
        end 
  
    
   repeat (10) begin	// U
        trans = riscv_seq_item::type_id::create("trans");
        trans.randomize();       
    	trans.instr[4:0] = 5'b10111;
    	trans.instr[6] = 1'b0;
        start_item(trans);
        finish_item(trans);
   end 
      
    
    
  repeat (10) begin	//	R
        trans = riscv_seq_item::type_id::create("trans");
        trans.randomize();   
      	trans.instr[6:0] = 7'b0110011;    
        start_item(trans);
        finish_item(trans);
        end
    
    
  repeat (10) begin	//	I
        trans = riscv_seq_item::type_id::create("trans");
        trans.randomize();   
    trans.instr[6:0] = 7'b0010011;    
        start_item(trans);
        finish_item(trans);
        end
    
    
    repeat (10) begin	// S
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize();
      	trans.instr[6:0] = 7'b0100011;
        start_item(trans);
        finish_item(trans);
    end
    
    
    
    repeat (10) begin	// BRANCH
        trans = riscv_seq_item::type_id::create("trans");
        trans.randomize();    
      	trans.instr[6:0] = 7'b1100011;   
        start_item(trans);
        finish_item(trans);
        end
    
    
    
    repeat (10) begin	// LOAD
        trans = riscv_seq_item::type_id::create("trans");
        trans.randomize();       
      	trans.instr[6:0] = 7'b0000011;
        start_item(trans);
        finish_item(trans);
        end 
  
        
  repeat (10) begin	// JUMP
        trans = riscv_seq_item::type_id::create("trans");
        trans.randomize();    
    	trans.instr[2:0] = 3'b111;
    	trans.instr[6:4] = 3'b110;  
        start_item(trans);
        finish_item(trans);
        end
    
    
    
    repeat (10) begin	// CSR
        trans = riscv_seq_item::type_id::create("trans");
        trans.randomize(); 
      	trans.instr[6:0] = 7'b1110011;      
        start_item(trans);
        finish_item(trans);
        end
    
    
    
    
    repeat (10) begin	// STORE
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize();
      	trans.instr[6:0] = 7'b0100011;
        start_item(trans);
        finish_item(trans);
        end
    
  endtask

endclass: riscv_sequence      
