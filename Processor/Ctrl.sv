// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)

module Ctrl (Instruction, S, BranchEn, MemToReg, MemWrite, MemRead, RegWrite, ALUOp, ALUSrc, Byte);


  input[ 8:0] Instruction;	   // machine code
  input logic [1:0] S;		// Flag
  output logic BranchEn,
			   MemToReg,
			   MemWrite,
			   MemRead,
			   RegWrite,
			   ALUSrc,
			   Byte;
  output logic [2:0] ALUOp;

// jump on right shift that generates a zero
always_comb
begin
	ALUOp = Instruction[8:6];
	case (Instruction[8:6])
		3'b000: begin
			BranchEn = 0;
			MemToReg = ~S[0];
			MemWrite = S[0];
			MemRead = ~S[0];
			RegWrite = ~S[0];
			ALUSrc = 1;
			ALUOp = 3'b010;
			Byte = S[1];
		end
		3'b001: begin
			BranchEn = 0;
			MemToReg = 0;
			MemWrite = 0;
			MemRead = 0;
			RegWrite = 1;
			ALUSrc = 1;
			Byte = S[1];
		end
		3'b110: begin
			BranchEn = 1;
			MemToReg = 0;
			MemWrite = 0;
			MemRead = 0;
			RegWrite = 0;
			ALUOp = 3'b011;
			ALUSrc = 0;
			Byte = S[1];
		end
		3'b111: begin
			BranchEn = 0;
			MemToReg = 0;
			MemWrite = 0;
			MemRead = 0;
			RegWrite = 0;
			ALUSrc = 0;
			Byte = 0;
		end
		default: begin
			BranchEn = 0;
			MemToReg = 0;
			MemWrite = 0;
			MemRead = 0;
			RegWrite = 1;
			ALUSrc = S[0];
			Byte = S[1];
			if (Instruction[8:6] == 3'b100 && S[0]) begin
				ALUOp = 3'b110;
			end
		end
	endcase
end


endmodule

