
`include "seq_item.sv"
class riscv_sequence extends uvm_sequence#(riscv_seq_item);
  
  `uvm_object_utils(riscv_sequence)
  
  riscv_seq_item trans;
  reg [4:0] i;
  reg [24:0]ins;
  
  
  function new (string name = "riscv_sequence");
      super.new(name);  
    
  endfunction
  
    
  
  task body();
   
    srandom(2);
    
    
    repeat (15) begin	// BRANCH & JUMP
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b1100011, 7'b1100111, 7'b1101111};
      	};
        start_item(trans);
        finish_item(trans);
        end
 
    	//	--------------	TEST  ---------------  //
    $display("\n\n//	-------------	REG TEST ---------------  //\n\n",);    
    i = 0;
    repeat(33) begin      
        trans = riscv_seq_item::type_id::create("trans");
      	trans.instr = {12'b0, i, 3'b0, i, 7'b0010011};
      	++i;
        start_item(trans);
        finish_item(trans);
        end 
        //	-------------------------------------  //
    
    
    repeat (15) begin	// U
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b0110111, 7'b0010111};
      	};
        start_item(trans);
        finish_item(trans);
   end 
      
     
    	//	--------------	TEST  ---------------  //
    $display("\n\n//	-------------	REG TEST ---------------  //\n\n",);    
    i = 0;
    repeat(33) begin      
        trans = riscv_seq_item::type_id::create("trans");
      	trans.instr = {12'b0, i, 3'b0, i, 7'b0010011};
      	++i;
        start_item(trans);
        finish_item(trans);
        end 
        //	-------------------------------------  //
    
    
    repeat (15) begin	//	R
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b0110011};
      	};  
        start_item(trans);
        finish_item(trans);
        end
    
    
     
    	//	--------------	TEST  ---------------  //
    $display("\n\n//	-------------	REG TEST ---------------  //\n\n",);    
    i = 0;
    repeat(33) begin      
        trans = riscv_seq_item::type_id::create("trans");
      	trans.instr = {12'b0, i, 3'b0, i, 7'b0010011};
      	++i;
        start_item(trans);
        finish_item(trans);
        end 
        //	-------------------------------------  //
    
    
    repeat (15) begin	//	I
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b0010011};
      	};
        start_item(trans);
        finish_item(trans);
        end
    
	 
    	//	--------------	TEST  ---------------  //
    $display("\n\n//	-------------	REG TEST ---------------  //\n\n",);    
    i = 0;
    repeat(33) begin      
        trans = riscv_seq_item::type_id::create("trans");
      	trans.instr = {12'b0, i, 3'b0, i, 7'b0010011};
      	++i;
        start_item(trans);
        finish_item(trans);
        end 
        //	-------------------------------------  //
    
 /* 
 	repeat (15) begin	//	RANDOM
      	trans = riscv_seq_item::type_id::create("trans");
        trans.randomize();
        start_item(trans);
        finish_item(trans);
        end 
    
    
    repeat (15) begin	// BRANCH
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b1100011};
      	};
        start_item(trans);
        finish_item(trans);
        end
    
    
    repeat (15) begin	// JUMP
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b1100111, 7'b1101111};
      	};    
        start_item(trans);
        finish_item(trans);
        end
    
    
    
    repeat (15) begin	// CSR
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b1110011};
      	}; 
        start_item(trans);
        finish_item(trans);
        end
    
    repeat (25) begin	// LOAD
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b0000011};
      	};
        start_item(trans);
        finish_item(trans);
        end 
    
    repeat (15) begin	// STORE
        trans = riscv_seq_item::type_id::create("trans");
      	trans.randomize with {
          trans.instr[6:0] inside {7'b0100011};
      	};      
        start_item(trans);
        finish_item(trans);
        end    
    
    
   
    */   
     
/*    
	//	--------------	TEST  ---------------  //
        
    $display("\n\n//	-------------	REG TEST ---------------  //\n\n",);    
    i = 0;
    repeat(33) begin      
        trans = riscv_seq_item::type_id::create("trans");
      	trans.instr = {12'b0, i, 3'b0, i, 7'b0010011};
      	++i;
        start_item(trans);
        finish_item(trans);
        end 	*/
  endtask 

endclass: riscv_sequence      