// Design Name:    CSE141L
// Module Name:    reg_file 
//
// Additional Comments: 					  $clog2

/* parameters are compile time directives 
       this can be an any-size reg_file: just override the params!
*/
module RegFile (Clk,Reset,WriteEn,StFlag,RaddrA,RaddrB,Waddr,DataIn,ALUIn,ALUOp,DataOutA,DataOutB,Branch1,Branch2,LoadStore,S);
  input                Clk,
					   Reset,
                       WriteEn,
					   StFlag;
  input        [2:0] RaddrA,				  // address pointers
                       RaddrB,
                       Waddr,
					   ALUOp;
  input        [15:0] DataIn,
  					  ALUIn;
  output logic [15:0] DataOutA;			  // showing two different ways to handle DataOutX, for
  output logic [15:0] DataOutB;
  output logic [15:0] Branch1;
  output logic [15:0] Branch2;
  output logic [15:0] LoadStore;
  output logic [1:0] S = 0;				  //   pedagogic reasons only;

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [15:0] Registers[7:0];	  // or just registers[16] if we know D=4 always
// combinational reads 
/* can write always_comb in place of assign
    difference: assign is limited to one line of code, so
	always_comb is much more versatile     
*/

always_comb
begin
 DataOutA = Registers[RaddrA];	  
 DataOutB = Registers[RaddrB];
 Branch1 = Registers[3];
 Branch2 = Registers[4];
 LoadStore = Registers[0];
end

// sequential (clocked) writes 
always_ff @ (posedge Clk) begin
  	if (WriteEn && !Reset) begin
		  if (ALUOp == 3'b100 || ALUOp == 3'b101) begin
			  Registers[3'b111] <= ALUIn;
			  Registers[3'b110] <= DataIn;
		  end
		  else begin
			  Registers[Waddr] <= DataIn; 
		  end
	end	
	if (StFlag && !Reset)
		S <= DataIn[1:0];
	if (Reset) begin
		Registers[0] <= 0;
		S <= 0;
 	end
end

endmodule
