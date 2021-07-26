// Module Name:    ALU 
// Project Name:   CSE141L
//
	 
module ALU(InputA,InputB,OP,Out1,Out2,Zero);

	input logic [15:0] InputA;
	input logic [15:0] InputB;
	input logic [2:0] OP;
	output logic [15:0] Out1, Out2; // logic in SystemVerilog
	output logic Zero;
	logic [3:0] DivisionCounter = 0;
	logic [15:0] DivisionHolder = 0;
	always_comb begin 
		Out1 = 0;
		Out2 = 0;
		DivisionCounter = 0;
		DivisionHolder = 0;
		case (OP)
			3'b010: Out1 = InputA + InputB; // ADD
			3'b011: Out1 = InputA - InputB; // SUB
			3'b100: Out1 = InputA * InputB; // MULT
			3'b101: begin					// DIV
				while (DivisionCounter != 15) begin
					Out2 = Out2 << 1;
					Out2 = Out2 + InputA[15];
					InputA = InputA << 1;
					Out1 = Out1 << 1;
					if (!(Out2 < InputB)) begin
						Out2 = Out2 - InputB;
						Out1[0] = Out2[0];
					end
					DivisionCounter = DivisionCounter + 1;
				end
				while (Out2[15] == 0) begin
					Out2 = Out2 << 1;
				end
				DivisionCounter = 0;
				InputA = Out2;
				Out2 = 0;
				while (DivisionCounter != 15) begin
					DivisionHolder = DivisionHolder << 1;
					DivisionHolder = DivisionHolder + InputA[15];
					InputA = InputA << 1;
					Out2 = Out2 << 1;
					if (!(DivisionHolder < InputB)) begin
						DivisionHolder = DivisionHolder - InputA;
						Out2[0] = DivisionHolder[0];
					end
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
			'b0     : Zero = 1'b1;
			default : Zero = 1'b0;
      endcase
	end


endmodule