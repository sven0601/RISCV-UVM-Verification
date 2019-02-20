
class riscv_scoreboard extends uvm_subscriber#(riscv_seq_item);
  
  `uvm_component_utils(riscv_scoreboard)
  reg [31:0] stack[31:0],	mem[1024:0],	csr[4095:0];
  reg [31:0] pc, next_pc;
  uvm_analysis_imp #(riscv_seq_item, riscv_scoreboard) sc_port;

    
  	function new(string name, uvm_component parent);
       super.new(name, parent);
      sc_port = new("sc_port",this);
  	endfunction : new
    
  
  	function void write(input riscv_seq_item t);
		//checker code here
      if(t.pc!=32'b0)       begin
     case(t.instr[6:0]) 
        7'b0110111: begin	// LUI
          stack[t.instr[11:7]] = {t.instr[31:12], 12'b0};
        end
        
       7'b0010111: 	begin//	AUIPC
          stack[t.instr[11:7]] = {t.instr[31:12], 12'b0} + t.pc;
        end
          
          
       	7'b1101111: 	begin//	JAL
            stack[t.instr[11:7]] = 32'b1 + t.pc;
            pc = t.pc;
          next_pc = ({12'b0,t.instr[31],t.instr[19:12], t.instr[20], t.instr[30:21]});	// & 32'hfffffffe;
        end
        
        7'b1100111: 	begin//	JALR
            stack[t.instr[11:7]] = 32'b1 + t.pc;
            pc = t.pc;
          next_pc = ({20'b0,t.instr[31:20]} + stack[t.instr[19:15]]);	// & 32'hfffffffe;
        end
        
        7'b1100011: 	begin//	BEQ
          if(stack[t.instr[19:15]==t.instr[24:20]]) begin
            pc = t.pc;
            next_pc = {20'b0,t.instr[31],t.instr[7],t.instr[30:25],t.instr[11:6]} + t.pc;
          end             
       end
       
       7'b1100011: 		begin//	BNE
         if(stack[t.instr[19:15]!=t.instr[24:20]]) begin
            pc = t.pc;
            next_pc = {20'b0,t.instr[31],t.instr[7],t.instr[30:25],t.instr[11:6]} + t.pc;
          end             
       end
           
     7'b1100011: 		begin	//	BLT
         if(stack[t.instr[19:15] < t.instr[24:20]]) begin
            pc = t.pc;
            next_pc = {20'b0,t.instr[31],t.instr[7],t.instr[30:25],t.instr[11:6]} + t.pc;
          end             
       end
       
     7'b1100011: 		begin	//	BGE
         if(stack[t.instr[19:15] > t.instr[24:20]]) begin
            pc = t.pc;
            next_pc = {20'b0,t.instr[31],t.instr[7],t.instr[30:25],t.instr[11:6]} + t.pc;
          end             
       end
     7'b1100011: 		begin	//	BLTU                    
         if(stack[t.instr[19:15] < t.instr[24:20]]) begin
            pc = t.pc;
            next_pc = {20'b0,t.instr[31],t.instr[7],t.instr[30:25],t.instr[11:6]} + t.pc;
          end             
       end
       
     7'b1100011: 		begin	//	BGEU                     
         if(stack[t.instr[19:15] > t.instr[24:20]]) begin
            pc = t.pc;
            next_pc = {20'b0,t.instr[31],t.instr[7],t.instr[30:25],t.instr[11:6]} + t.pc;
          end             
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
        $display("STACK	:		 %d		at		x%d", stack[t.instr[11:7]], t.instr[11:7]);
      end
        
     end
  endfunction 
  

endclass: riscv_scoreboard
