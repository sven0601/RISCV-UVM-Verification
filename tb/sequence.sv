


class riscv_sequence extends uvm_sequence#(riscv_seq_item);
  
  `uvm_object_utils(riscv_sequence)
  
  riscv_seq_item trans;
  reg [4:0] i;
  reg [31:0] count, ins_mem [1023:0]; 
  
  
  function new (string name = "riscv_sequence");
      super.new(name); 
  endfunction
  
    
  
  task body();

    
        i = 0;    //		DEMO TEST SEQUENCE 
    repeat (32) begin	// U
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b0110111, 7'b0010111};
      	};
      	trans.instr[11:7] = i;
      	++i;
        start_item(trans);
        finish_item(trans);
   	end 
    
    i = 0; 		 //	--------------	TEST  ---------------  //
    repeat(32) begin      
        trans = riscv_seq_item::type_id::create("trans");
      	trans.instr = {12'b0, i, 3'b0, i, 7'b0010011};
      	++i;
        start_item(trans);
        finish_item(trans);
    end 
 
    
    repeat (20) begin	// BRANCH
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b1100011};
      	};
        start_item(trans);
        finish_item(trans);
    end
    
    
    repeat (20) begin	// JUMP
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b1100111, 7'b1101111};
      	};    
        start_item(trans);
        finish_item(trans);
    end

    repeat (20) begin	//	R
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b0110011};
      	};  
        start_item(trans);
        finish_item(trans);
    end
 
    repeat (20) begin	//	I
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b0010011};
      	};
        start_item(trans);
        finish_item(trans);
    end
    
    repeat (20) begin	// CSR
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b1110011};
      	};      
        start_item(trans);
        finish_item(trans);
    end    
    
    i = 0; 		 //	--------------	TEST  ---------------  //
    repeat(32) begin      
        trans = riscv_seq_item::type_id::create("trans");
      	trans.instr = {12'b0, i, 3'b0, i, 7'b0010011};
      	++i;
        start_item(trans);
        finish_item(trans);
    end 
    
    repeat (20) begin	// STORE
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b0100011};
      	};      
        start_item(trans);
        finish_item(trans);
    end    
         
    
    repeat (20) begin	// LOAD
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b0000011};
      	};      
        start_item(trans);
        finish_item(trans);
    end   
   

    i = 0; 		 //	--------------	TEST  ---------------  //
    repeat(32) begin      
        trans = riscv_seq_item::type_id::create("trans");
      	trans.instr = {12'b0, i, 3'b0, i, 7'b0010011};
      	++i;
        start_item(trans);
        finish_item(trans);
        end 
                
 /*
    repeat (200) begin	//	Random
        trans = riscv_seq_item::type_id::create("trans");
      trans.randomize();  
        start_item(trans);
        finish_item(trans);
    end
*/
    
  endtask 

endclass: riscv_sequence      