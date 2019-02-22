// LOAD, STORE, FENCE
// BLTU, BGEU, ECALL, EBREAK, STLU
class riscv_scoreboard extends uvm_subscriber#(riscv_seq_item);
  
  `uvm_component_utils(riscv_scoreboard)
  reg [31:0] stack[31:0],	mem[1024:0],	csr[4095:0];
  reg [31:0] pc, next_pc, reg_rd_dat;
  reg bflag = 0;
  uvm_analysis_imp #(riscv_seq_item, riscv_scoreboard) sc_port;

    
  	function new(string name, uvm_component parent);
       super.new(name, parent);
      sc_port = new("sc_port",this);
      
    for (int i = 0; i < 32 ; ++i) begin
    stack[i] = 32'b0;
  end
      
  	endfunction : new 
    
  
  	function void write(input riscv_seq_item t);
		//checker code here
      if(t.pc!=32'b0)       begin
          
      stack[0] = 32'b0;
   
      if (bflag) begin
        if (t.pc == next_pc)	$display("PC STATUS :	 	--------- PASS ---------	Expected :	%d		Observed : %d\n", next_pc, t.pc);
        else	$display("PC STATUS :	 	--------- FAIL ---------	Expected :	%d		Observed : %d\n", next_pc, t.pc);
        bflag = 0;
      end
         
        
     case(t.instr[6:0]) 
        7'b0110111: begin	// LUI
          stack[t.instr[11:7]] = {t.instr[31:12], 12'b0};
          end
        
       7'b0010111: 	begin//	AUIPC
          stack[t.instr[11:7]] = {t.instr[31:12], 12'b0} + t.pc;
        	end
          
          
       	7'b1101111: 	begin//	JAL
          stack[t.instr[11:7]] = 32'd4 + t.pc;
            pc = t.pc;
          next_pc = ({11'b0,t.instr[31],t.instr[19:12], t.instr[20], t.instr[30:21],1'b0} + pc);	// & 32'hfffffffe;
          	bflag = 1;
        	end
        
        7'b1100111: 	begin//	JALR
          stack[t.instr[11:7]] = 32'd4 + t.pc;
            pc = t.pc;
          	next_pc = ({20'b0,t.instr[31:20]} + stack[t.instr[19:15]]) & 32'hfffffffe;
          	bflag = 1;
        	end 
        
        7'b1100011: 	begin
          
                bflag = 1;
          
         case(t.instr[14:12])
           
           3'b000	:	begin	//	BEQ
             if(stack[t.instr[19:15]]==stack[t.instr[24:20]]) begin
                pc = t.pc;
                next_pc = {19'b0,t.instr[31],t.instr[7],t.instr[30:25],t.instr[11:8],1'b0} + t.pc;
          	end  
             else begin
               pc = t.pc;
               next_pc = t.pc + 32'd4;
             end
         end
           
           
           3'b001	:	begin
             if(stack[t.instr[19:15]]!=stack[t.instr[24:20]]) begin	//	BNE
            	pc = t.pc;
           		next_pc = {19'b0,t.instr[31],t.instr[7],t.instr[30:25],t.instr[11:8],1'b0} + t.pc;
          end   
             else begin
               pc = t.pc;
               next_pc = t.pc + 32'd4;
             end
         end
           
           
           3'b100	:	begin
             if(stack[t.instr[19:15]] <= stack[t.instr[24:20]]) begin	//	BLT
               pc = t.pc;
               next_pc = {19'b0,t.instr[31],t.instr[7],t.instr[30:25],t.instr[11:8],1'b0} + t.pc;
          end   
             else begin
               pc = t.pc;
               next_pc = t.pc + 32'd4;
             end
         end
           
           
           3'b101	:		begin
             if (stack[t.instr[19:15]] > stack[t.instr[24:20]]) begin	//	BGE
                 pc = t.pc;
                 next_pc = {19'b0,t.instr[31],t.instr[7],t.instr[30:25],t.instr[11:8],1'b0} + t.pc;
          end 
             else begin
               pc = t.pc;
               next_pc = t.pc + 32'd4;
             end
         end
           
           3'b110	:	begin
             if(stack[t.instr[19:15]] <= stack[t.instr[24:20]]) begin	//	BLTU        
                 pc = t.pc;
                 next_pc = {19'b0,t.instr[31],t.instr[7],t.instr[30:25],t.instr[11:8],1'b0} + t.pc;
          end  
             else begin
               pc = t.pc;
               next_pc = t.pc + 32'd4;
             end
         end
           
           3'b111	:	begin
             if(stack[t.instr[19:15]] > stack[t.instr[24:20]]) begin	//	BGEU    
                 pc = t.pc;
                 next_pc = {19'b0,t.instr[31],t.instr[7],t.instr[30:25],t.instr[11:8],1'b0} + t.pc;
          end  
             else begin
               pc = t.pc;
               next_pc = t.pc + 32'd4;
             end
         end
         endcase
                     
       end
       
       
       
     7'b0010011: begin	// I
         case(t.instr[14:12])
           3'b000	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] + {20'b0,t.instr[31:20]};
           3'b010	:	stack[t.instr[11:7]] = (stack[t.instr[19:15]] < {20'b0,t.instr[31:20]}) ? 32'b1 : 32'b0;
           3'b011	:	stack[t.instr[11:7]] = (stack[t.instr[19:15]] < {20'b0,t.instr[31:20]}) ? 32'b1 : 32'b0;
           3'b100	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] ^ {20'b0,t.instr[31:20]};
           3'b110	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] | {20'b0,t.instr[31:20]};
           3'b111	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] & {20'b0,t.instr[31:20]};
           3'b001	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] << {20'b0,t.instr[24:20]};
           3'b101	:	begin
             stack[t.instr[11:7]] = stack[t.instr[19:15]] >> {20'b0,t.instr[24:20]};
             if(t.instr[30])	stack[t.instr[11:7]][31] = stack[t.instr[19:15]][31];
           end   
         endcase
       end

     7'b0110011:	begin	//	R
         case(t.instr[14:12])
           3'b000	:	begin
             if (t.instr[30]) stack[t.instr[11:7]] = stack[t.instr[19:15]] - stack[t.instr[24:20]];
             else  stack[t.instr[11:7]] = stack[t.instr[19:15]] - stack[t.instr[24:20]];
           end
           3'b010	:	stack[t.instr[11:7]] = (stack[t.instr[19:15]] < stack[t.instr[24:20]]) ? 32'b1 : 32'b0;
           3'b011	:	stack[t.instr[11:7]] = (stack[t.instr[19:15]] < stack[t.instr[24:20]]) ? 32'b1 : 32'b0;
           3'b100	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] ^ stack[t.instr[24:20]];
           3'b110	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] | stack[t.instr[24:20]];
           3'b111	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] & stack[t.instr[24:20]];
           3'b001	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] << stack[t.instr[24:20]];
           3'b101	:	begin
             stack[t.instr[11:7]] = stack[t.instr[19:15]] >> stack[t.instr[24:20]];
             if(t.instr[30])	stack[t.instr[11:7]][31] = stack[t.instr[19:15]][31];
           end   
         endcase
       end
               
          
    7'b1110011 : begin	//	CSR	
         case(t.instr[14:12])
           3'b000	:	begin	//	ECALL EBREAK
             csr[12'h341] = t.pc;
           end
           3'b001	:	begin	//	CSRRW
             if(!t.instr[11:7])
             stack[t.instr[11:7]] = csr[t.instr[31:20]];
             csr[t.instr[31:20]] = stack[t.instr[19:15]];
           end
           3'b010	:	begin	//	CSRRS
             stack[t.instr[11:7]] = csr[t.instr[31:20]];
             if(!t.instr[11:7])
             csr[t.instr[31:20]] = stack[t.instr[19:15]] | csr[t.instr[31:20]];
           end
           3'b011	:	begin	//	CSRRC
             stack[t.instr[11:7]] = csr[t.instr[31:20]];
             if(!t.instr[11:7])
             csr[t.instr[31:20]] = ~stack[t.instr[19:15]] & csr[t.instr[31:20]];
           end
           3'b101	:	begin	//	CSRRWI
             if(!t.instr[11:7])
             stack[t.instr[11:7]] = csr[t.instr[31:20]];
             csr[t.instr[31:20]] = {27'b0,t.instr[19:15]};
           end
           3'b110	:	begin	//	CSRRSI
             stack[t.instr[11:7]] = csr[t.instr[31:20]];
             if(!t.instr[11:7])
             csr[t.instr[31:20]] = {27'b0,t.instr[19:15]} | csr[t.instr[31:20]];
           end
           3'b111	:	begin	//	CSRRCI
             stack[t.instr[11:7]] = csr[t.instr[31:20]];
             if(!t.instr[11:7])
             csr[t.instr[31:20]] = ~{27'b0,t.instr[19:15]} & csr[t.instr[31:20]];
           end
         endcase
    end 
        
      endcase 
       
        
      `uvm_info("mg", $psprintf("Scoreboard received t %s", t.convert2string()), UVM_NONE);
      
        
      if ((t.instr[6:0] == 7'b0010011) & (t.instr[31:20]== 12'b0) & (t.instr[14:12] == 3'b0)) begin
          	uvm_config_db #(reg[31:0])::get(uvm_root::get(),"*","reg_rd_dat", reg_rd_dat);
        
        if (stack[t.instr[11:7]] == reg_rd_dat) 	$display("x%d STATUS :	 	--------- PASS ---------		Expected :	%d		Observed :	%d\n", t.instr[11:7], stack[t.instr[11:7]], reg_rd_dat);
        else begin
          $display("x%d STATUS :	 	--------- FAIL ---------		Expected :	%d		Observed :	%d\n", t.instr[11:7], stack[t.instr[11:7]], reg_rd_dat);
        end 
        	
//        $display("STACK	:		 %d		at		x%d", stack[t.instr[11:7]], t.instr[11:7]);

      end 
         
      
     end
  endfunction 
  

endclass: riscv_scoreboard
