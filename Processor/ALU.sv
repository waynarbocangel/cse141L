// Module Name:    ALU 
// Project Name:   CSE141L
//
	 
module ALU(InputA,InputB,OP,Out1,Out2,Zero);

	input logic [15:0] InputA;
	input logic [15:0] InputB;
	input logic [2:0] OP;
	output logic [15:0] Out1, Out2; // logic in SystemVerilog
	output logic Zero;

	logic [15:0] Operand1, Operand2;
	logic [3:0] DivisionCounter = 0;
	logic [15:0] DivisionHolder = 0;
	always_comb begin 
		Out1 = 0;
		Out2 = 0;
		DivisionCounter = 0;
		DivisionHolder = 0;
		Operand1 = InputA;
		Operand2 = InputB;
		case (OP)
			3'b001: Out1 = InputB;			// ASSIGNMENT
			3'b010: Out1 = InputA + InputB; // ADD
			3'b011: Out1 = InputA - InputB; // SUB
			3'b100: Out1 = InputA * InputB; // MULT
			3'b101: begin					// DIV
				while (DivisionCounter != 16) begin
					Out2 = Out2 << 1;
					Out2 = Out2 + Operand1[15];
					Operand1 = Operand1 << 1;
					Out1 = Out1 << 1;
					if (!(Out2 < Operand2)) begin
						Out2 = Out2 - Operand2;
						Out1[0] = Out2[0];
					end
					DivisionCounter = DivisionCounter + 1;
				end
				DivisionCounter = 0;
				while (Out2[15] == 0 && DivisionCounter != 16) begin
					Out2 = Out2 << 1;
					DivisionCounter = DivisionCounter + 1;
				end
				DivisionCounter = 0;
				Operand1 = Out2;
				Out2 = 0;
				while (DivisionCounter != 8) begin
					DivisionHolder = DivisionHolder << 1;
					DivisionHolder = DivisionHolder + Operand1[15];
					Operand1 = Operand1 << 1;
					Out2 = Out2 << 1;
					if (!(DivisionHolder < Operand2)) begin
						DivisionHolder = DivisionHolder - Operand1;
						Out2[0] = DivisionHolder[0];
					end
					DivisionCounter = DivisionCounter + 1;
				end
			end
			3'b110: Out1 = InputA << InputB;	   // Shift left
			default: begin
				Out1 = 0;
				Out2 = 0;
			end 
		endcase
	
	end 


	always_comb							  // assign Zero = !Out;
	begin
		case(Out1)
			'b0     : Zero = 1'b0;
			default : Zero = 1'b1;
      endcase
	end


endmodule