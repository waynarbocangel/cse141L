// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)

module Ctrl (Instruction, Jump, BranchEn);


  input[ 8:0] Instruction;	   // machine code
  output logic Jump,
               BranchEn;

// jump on right shift that generates a zero
always_comb
begin
  if(Instruction[2:0] ==  3'b111) // assuming 111 is your jump instruction
    Jump = 1;
  else
    Jump = 0;
	 
	 if(Instruction[2:0] ==  3'b110 /*AND some other conditions are true*/) // assuming 110 is your branch instruction
    BranchEn = 1;
  else
    BranchEn = 0;
	 
	 
end


endmodule

