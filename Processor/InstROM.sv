// Design Name: 
// Module Name:    InstROM 
// Project Name:   CSE141L
// Tool versions: 
// Description: Verilog module -- instruction ROM template	
//	 preprogrammed with instruction values (see case statement)
//
// Revision: 
//

module InstROM (InstAddress, InstOut) ;
  input logic [(2**11)-1:0] InstAddress;
  output logic [8:0] InstOut;
	 

// Instruction format: {4bit opcode, 3bit rs or rt, 3bit rt, immediate, or branch target}
	 
//  always_comb 
//	case (InstAddress)
// opcode = 0 lhw, rs = 0, rt = 1
//	  0 : InstOut = 'b0000000001;  // load from address at reg 0 to reg 1  
// opcode = 1 addi, rs/rt = 1, immediate = 1
     
//	  1 : InstOut = 'b0001001001;  // addi reg 1 and 1
		
// opcode = 2 shw, rs = 0, rt = 1
//	  2 : InstOut = 'b0010000001;  // sw reg 1 to address in reg 0
		
// opcode = 3 beqz, rs = 1, target = 1
//      3 : InstOut = 'b0011001001;  // beqz reg1 to absolute address 1
		
// opcode = 15 halt
//	  4 : InstOut = '1;  // equiv to 10'b1111111111 or 'b1111111111    halt
//	  default : InstOut = 'b0000000000;
//    endcase

// alternative expression
//   need $readmemh or $readmemb to initialize all of the elements
  logic[8:0] inst_rom[(2**11)-1:0];
  always_comb begin
	InstOut = inst_rom[InstAddress];
  end
 
  initial begin		                  // load from external text file
  	$readmemb("machine_code.txt",inst_rom);
  end 
  
endmodule