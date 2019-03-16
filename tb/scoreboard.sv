// Missing - U, ECALL, memdump



class riscv_scoreboard extends uvm_subscriber#(riscv_seq_item);
  
  `uvm_component_utils(riscv_scoreboard)
  
  reg [31:0] stack[31:0];
  reg [31:0] mem[(2**25) - 1:0],	csr[4095:0];
  reg [31:0] dat;
  reg [31:0] pc, next_pc, reg_rd_dat, m_addr, m_dat, m_addr_obs, m_dat_obs;
  reg bflag = 0, m_flag = 0;
  uvm_analysis_imp #(riscv_seq_item, riscv_scoreboard) sc_port;

    
  	function new(string name, uvm_component parent);
       super.new(name, parent);
      sc_port = new("sc_port",this);
        
//   $readmemh("mem.txt", mem);
  	endfunction : new 
    
  
  	function void write(input riscv_seq_item t);
		//checker code here
      if(t.reset)       begin
          
      stack[0] = 32'b0;
   
        if (bflag) begin		// 	Branch Check
          if (t.pc === next_pc)	$display("PC STATUS :	 --------- PASS ---------	Expected :	%h		Observed :	%h", next_pc, t.pc); 
        else	$display("PC STATUS :	 (!) ----------------FAIL 	Expected :	%h		Observed :	%h", next_pc, t.pc); 
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
          next_pc = ({{12{t.instr[31]}},t.instr[19:12], t.instr[20], t.instr[30:21],1'b0} + pc);	// & 32'hfffffffe;
          	bflag = 1;
        	end
        
        7'b1100111: 	begin//	JALR
            pc = t.pc;
          next_pc = ({{21{t.instr[31]}},t.instr[30:20]} + stack[t.instr[19:15]]) & 32'hfffffffe;
          	stack[t.instr[11:7]] = 32'd4 + t.pc;
          	bflag = 1;
//          $display(" %d + %d",stack[t.instr[19:15]] , {20'b0,t.instr[31:20]} );
//          $display("stack[%d] = %h", t.instr[11:7], 32'd4 + t.pc);
        	end 
        
        7'b1100011: 	begin
          
                bflag = 1;
          
         case(t.instr[14:12])
           
           3'b000	:	begin	//	BEQ
             if(stack[t.instr[19:15]]==stack[t.instr[24:20]]) begin
                pc = t.pc;
                next_pc = {{20{t.instr[31]}},t.instr[7],t.instr[30:25],t.instr[11:8],1'b0} + t.pc;
          	end  
             else begin
               pc = t.pc;
               next_pc = t.pc + 32'd4;
             end
         end
           
           
           3'b001	:	begin
             if(stack[t.instr[19:15]]==stack[t.instr[24:20]]) begin	//	BNE
            	pc = t.pc;
           		next_pc = t.pc + 32'd4;
          end   
             else begin
               pc = t.pc;
               next_pc = {{20{t.instr[31]}},t.instr[7],t.instr[30:25],t.instr[11:8],1'b0} + t.pc;
             end
         end 
           
           
           3'b100	:	begin
             if(stack[t.instr[19:15]] < stack[t.instr[24:20]]) begin	//	BLT
               pc = t.pc;
               next_pc = {{20{t.instr[31]}},t.instr[7],t.instr[30:25],t.instr[11:8],1'b0} + t.pc;
          end   
             else begin
               pc = t.pc;
               next_pc = t.pc + 32'd4;
             end
         end
           
           
           3'b101	:		begin
             if (stack[t.instr[19:15]] > stack[t.instr[24:20]]) begin	//	BGE
                 pc = t.pc;
                 next_pc = {{20{t.instr[31]}},t.instr[7],t.instr[30:25],t.instr[11:8],1'b0} + t.pc;
          end 
             else begin
               pc = t.pc;
               next_pc = t.pc + 32'd4;
             end
         end
           
           3'b110	:	begin
             if(stack[t.instr[19:15]] < stack[t.instr[24:20]]) begin	//	BLTU        
                 pc = t.pc;
                 next_pc = {{20{t.instr[31]}},t.instr[7],t.instr[30:25],t.instr[11:8],1'b0} + t.pc;
          		end   
             else begin
               pc = t.pc;
               next_pc = t.pc + 32'd4;
             end
         	end 
           
        3'b111	:	begin
          if(stack[t.instr[19:15]] > stack[t.instr[24:20]]) begin	//	BGEU    
                 pc = t.pc;
                 next_pc = {{20{t.instr[31]}},t.instr[7],t.instr[30:25],t.instr[11:8],1'b0} + t.pc;
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
           3'b000	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] + {{21{t.instr[31]}},t.instr[30:20]};
           3'b010	:	stack[t.instr[11:7]] = (stack[t.instr[19:15]] < {{21{t.instr[31]}},t.instr[30:20]}) ? 32'b1 : 32'b0;
           3'b011	:	stack[t.instr[11:7]] = (stack[t.instr[19:15]] < {{21{t.instr[31]}},t.instr[30:20]}) ? 32'b1 : 32'b0;
           3'b100	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] ^ {{21{t.instr[31]}},t.instr[30:20]};
           3'b110	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] | {{21{t.instr[31]}},t.instr[30:20]};
           3'b111	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] & {{21{t.instr[31]}},t.instr[30:20]};
           3'b001	:	stack[t.instr[11:7]] = stack[t.instr[19:15]] << {27'b0,t.instr[24:20]};
           3'b101	:	begin
             stack[t.instr[11:7]] = stack[t.instr[19:15]] >> {27'b0,t.instr[24:20]};
             if(t.instr[30])	stack[t.instr[11:7]][31] = stack[t.instr[19:15]][31];
           end   
           
         endcase
//       if (t.instr[13:12] == 2'b01)         $display("rd1 = %d	Imm = %d	rd = %d", stack[t.instr[19:15]], {27'b0,t.instr[24:20]}, stack[t.instr[11:7]]);
//     else		$display("rd1 = %d	Imm = %d	rd = %d", stack[t.instr[19:15]], {20'b0,t.instr[31:20]}, stack[t.instr[11:7]]);
       end

     7'b0110011:	begin	//	R
         case(t.instr[14:12])
           3'b000	:	begin
             if (t.instr[30]) stack[t.instr[11:7]] = stack[t.instr[19:15]] - stack[t.instr[24:20]];
             else  stack[t.instr[11:7]] = stack[t.instr[19:15]] + stack[t.instr[24:20]];
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
         if (t.instr[11:7] == 5'b00000)	stack[t.instr[11:7]] = 32'b0;
       end
               
          
    7'b1110011 : begin	//	CSR	
      case(t.instr[14:12]) 
           3'b000	:	begin	//	ECALL EBREAK
             csr[12'h341] = t.pc;
           end
           3'b001	:	begin	//	CSRRW
             if(t.instr[11:7] != 5'b00000)
             stack[t.instr[11:7]] = csr[t.instr[31:20]];
             csr[t.instr[31:20]] = stack[t.instr[19:15]];
           end
           3'b010	:	begin	//	CSRRS
             if(t.instr[11:7] != 5'b00000)
             stack[t.instr[11:7]] = csr[t.instr[31:20]];
             csr[t.instr[31:20]] = stack[t.instr[19:15]] | csr[t.instr[31:20]];
           end
           3'b011	:	begin	//	CSRRC
             if(t.instr[11:7] != 5'b00000)
             stack[t.instr[11:7]] = csr[t.instr[31:20]];
             csr[t.instr[31:20]] = ~stack[t.instr[19:15]] & csr[t.instr[31:20]];
           end
           3'b101	:	begin	//	CSRRWI
             if(t.instr[11:7] != 5'b00000)
             stack[t.instr[11:7]] = csr[t.instr[31:20]];
             csr[t.instr[31:20]] = {27'b0,t.instr[19:15]};
           end
           3'b110	:	begin	//	CSRRSI
             if(t.instr[11:7] != 5'b00000)
             stack[t.instr[11:7]] = csr[t.instr[31:20]];
             csr[t.instr[31:20]] = {27'b0,t.instr[19:15]} | csr[t.instr[31:20]];
           end
           3'b111	:	begin	//	CSRRCI
             if(t.instr[11:7] != 5'b00000)
             stack[t.instr[11:7]] = csr[t.instr[31:20]];
             csr[t.instr[31:20]] = ~{27'b0,t.instr[19:15]} & csr[t.instr[31:20]];
           end
         endcase
    end 
       
       7'b0000011 : begin	//	LOAD
         m_flag = 1;
         m_addr = (stack[t.instr[19:15]] + {20'b0,t.instr[31:20]}) << 2; 
         case(t.instr[14:12])
           3'b000 : 	stack[t.instr[11:7]] = (mem[(stack[t.instr[19:15]] + {{21{t.instr[31]}},t.instr[30:20]}) << 2]) & 32'h000000ff;
           3'b001 : 	stack[t.instr[11:7]] = (mem[m_addr]) & 32'h0000ffff;
           3'b010 : 	stack[t.instr[11:7]] = (mem[(stack[t.instr[19:15]] + {{21{t.instr[31]}},t.instr[30:20]}) << 2]);
           3'b100 : 	stack[t.instr[11:7]] = (mem[(stack[t.instr[19:15]] + {{21{t.instr[31]}},t.instr[30:20]}) << 2]) & 32'h000000ff;
           3'b101 : 	stack[t.instr[11:7]] = (mem[(stack[t.instr[19:15]] + {{21{t.instr[31]}},t.instr[30:20]}) << 2]) & 32'h0000ffff;         
         endcase 
         if (t.instr[11:7] == 5'b00000)	stack[t.instr[11:7]] = 32'b0;
         m_dat =  stack[t.instr[11:7]];
       end
       
      7'b0100011 : begin	//	STORE
         m_flag = 1;
        m_addr = (stack[t.instr[19:15]] + {{21{t.instr[31]}},t.instr[30:25],t.instr[11:7]}) << 2;
         case(t.instr[14:12])
           3'b000 : 	begin
             m_dat = stack[t.instr[24:20]] & 32'h000000ff;
           end
           3'b001 : 	begin
             m_dat = stack[t.instr[24:20]] & 32'h0000ffff;
           end
           3'b010 : 	begin
             m_dat = stack[t.instr[24:20]];
           end
         endcase
        mem[m_addr] = m_dat ;
       end
        
    endcase  
       
        
        
      if ((t.instr[6:0] == 7'b0010011) & (t.instr[31:20]== 12'b0) & (t.instr[14:12] == 3'b0)) begin 
            uvm_config_db #(reg[31:0])::get(uvm_root::get(),"*","reg_rd_dat", reg_rd_dat);
        	if (t.instr[11:7] == 32'b0) $display("\n\n//	 -----------------------------------------	REG TEST	-------------------------------------------   //\n",); 
        	if (stack[t.instr[11:7]] === reg_rd_dat) 	
              $display("REG x%d STATUS :	 --------- PASS ---------	Expected :	%h		Observed :	%h", t.instr[11:7], stack[t.instr[11:7]], reg_rd_dat);
        	else 	$display("REG x%d STATUS :	 (!) ----------------FAIL 	Expected :	%h		Observed :	%h", t.instr[11:7], stack[t.instr[11:7]], reg_rd_dat);

            //        $display("STACK	:		 %d		at		x%d", stack[t.instr[11:7]] , t.instr[11:7]);
      end
             
        else 	`uvm_info("Scoreboard", $psprintf("	%s", t.convert2string()), UVM_NONE);
        
        
        if (m_flag) begin		// LOAD STORE Check
            uvm_config_db #(reg[31:0])::get(uvm_root::get(),"*","m_addr", m_addr_obs);   
            uvm_config_db #(reg[31:0])::get(uvm_root::get(),"*","m_dat", m_dat_obs);

            if ((m_dat === m_dat_obs) & (m_addr === m_addr_obs))
              $display("MEM STATUS :	 --------- PASS ---------	Expected :	[%h] , %h,		Observed :	[%h] , %h", m_addr, m_dat, m_addr_obs, m_dat_obs);  
              else
                $display("MEM STATUS :	 (!) ----------------FAIL 	Expected :	[%h] , %h,		Observed :	[%h] , %h", m_addr, m_dat, m_addr_obs, m_dat_obs); 
              m_flag = 0; 
       end  
         
      
     end
  endfunction 
  

endclass: riscv_scoreboard
