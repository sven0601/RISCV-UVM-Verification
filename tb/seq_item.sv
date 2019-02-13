//import uvm_pkg::*;
//include "/home/mashruwv1/Downloads/1800.2-2017-0.9/src/uvm_macros.svh";


class riscv_seq_item extends uvm_sequence_item;
  
    `uvm_object_utils(riscv_seq_item)
  
  rand logic [31:0]pc; 
  rand logic [31:0]instr;
  string instr_name;
  
  function new (string name = "riscv_seq_item");
      super.new(name);
    endfunction
  
  
  

  constraint c_opcode{ instr[6:0] inside {7'b0110111,7'b0010111,7'b1101111,7'b1100111,7'b1100011,7'b0000011,7'b0100011,7'b0010011,7'b0110011,7'b0001111,7'b1110011}; }
  
    constraint c_funct{ 
      (instr[6:0] == 7'b1100111) -> (instr[14:12] inside {3'b000}); 
      (instr[6:0] == 7'b1100011) -> (instr[14:12] inside {3'b000,3'b001,3'b100,3'b101,3'b110,3'b111}); 
      (instr[6:0] == 7'b0000011) -> (instr[14:12] inside {3'b000,3'b001,3'b010,3'b100,3'b101});
      (instr[6:0] == 7'b0100011) -> (instr[14:12] inside {3'b000,3'b001,3'b010}); 
      (instr[6:0] == 7'b1110011) -> !(instr[14:12] inside {3'b100});
      (instr[6:0] == 7'b0001111) -> (instr[14:12] inside {3'b000,3'b001});  
  }
  
  
      function string convert2string;
        case(instr[6:0])
          7'b0110111 : instr_name = "LUI";
          7'b0010111 : instr_name = "AUIPC";
          7'b1101111 : instr_name = "JAL";
          7'b1100111 : instr_name = "JALR";
          7'b1100011 : instr_name = "BRANCH";
          7'b0000011 : instr_name = "LOAD";
          7'b0100011 : instr_name = "STORE";
          7'b0010011 : instr_name = "ITYPE";
          7'b0110011 : instr_name = "RTYPE";
          7'b0001111 : instr_name = "FENCE";
          7'b1110011 : instr_name = "CSR";
        endcase
        return $psprintf("pc = %h, instr = %h, instr type = %s", pc, instr, instr_name);
    endfunction: convert2string
     
endclass: riscv_seq_item

    