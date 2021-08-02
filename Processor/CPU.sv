// Design Name:    BasicProcessor
// Module Name:    TopLevel 
// CSE141L
// partial only	

/*
module TopLevel(		   // you will have the same 3 ports
    input        Reset,	   // init/reset, active high
			     Start,    // start next program
	             Clk,	   // clock -- posedge used inside design
    output logic Ack	   // done flag from DUT
    );
*/
	 
module CPU(Reset, Start, Clk,Ack);

	input Reset;		// init/reset, active high
	input Start;		// start next program
	input Clk;			// clock -- posedge used inside design
	output logic Ack;   // done flag from DUT
	
	logic [ 9:0] PgmCtr,        // program counter
			      PCTarg;
	logic [ 8:0] Instruction;   // our 9-bit instruction
	logic [ 1:0] S;				// flag register
	logic [ 2:0] ALUOp;  // out 3-bit opcode
	logic [ 15:0] ReadA, ReadB, Branch1, Branch2, LoadStore;  // reg_file outputs
	logic [ 15:0] InA, InB, 	   // ALU operand inputs
					ALU_out1, ALU_out2;       // ALU result
	logic [ 15:0] RegWriteValue, // data in to reg file
					MemReadValue,  // data out from data_memory
					ALUData;
	logic        	BranchEn,
					MemToReg,
				 	MemWrite,	   // data_memory write enable
				   	MemRead,
					RegWrite,	      // reg_file write enable
				   	ALUSrc,
					Byte,
					Zero,		      // ALU output = 0 flag
					StFlag;	   // to program counter: branch enable
	logic  [15:0] CycleCt;	      // standalone; NOT PC!

	// Fetch = Program Counter + Instruction ROM
	// Program Counter
  InstFetch IF1 (
	.Reset       (Reset   ) , 
	.Start       (Start   ) ,  // SystemVerilg shorthand for .halt(halt), 
	.Clk         (Clk     ) ,  // (Clk) is required in Verilog, optional in SystemVerilog
	.BranchEn (BranchEn) ,  // branch enable
	.ALU_flag	 (Zero    ) ,
    .Target      (Instruction[5:0]) ,
	.ProgCtr     (PgmCtr  )	   // program count = index to instruction memory
	);	

	// Control decoder
  Ctrl Ctrl1 (
	.Instruction  (Instruction), // from instr_ROM
	.S         (S),		     // to PC
	.BranchEn     (BranchEn),		 // to PC
	.MemToReg	  (MemToReg),
	.MemWrite	  (MemWrite),
	.MemRead	  (MemRead),
	.RegWrite	  (RegWrite),
	.ALUSrc		  (ALUSrc),
	.Byte 		  (Byte),
	.ALUOp 		  (ALUOp)
  );
	// instruction ROM
  InstROM IR1(
	.InstAddress   (PgmCtr), 
	.InstOut       (Instruction)
	);
	
	always_comb							  // assign Zero = !Out;
	begin
		Ack = (Instruction[8:6] == 3'b111);
	end
	//Reg file
	// Modify D = *Number of bits you use for each register*
	RegFile RF1 (
		.Clk    		(Clk)		  ,
		.WriteEn   (RegWrite)    ,
		.StFlag	   (Instruction[8:6] == 3'b001), 
		.RaddrA    (Instruction[5:3]),         //concatenate with 0 to give us 4 bits
		.RaddrB    (Instruction[2:0]), 
		.Waddr     (Instruction[5:3]), 	       // mux above
		.ALUOp	   (ALUOp),
		.DataIn    (RegWriteValue) , 
		.ALUIn	   (ALUData),
		.DataOutA  (ReadA        ) , 
		.DataOutB  (ReadB		 ),
		.Branch1   (Branch1),
		.Branch2   (Branch2),
		.LoadStore (LoadStore),
		.S 		   (S)
	);
	
	
	
	assign InA = (BranchEn) ? Branch1 : ((MemRead || MemWrite) ? LoadStore : ReadA);						          // connect RF out to ALU in
	assign InB = (!ALUSrc) ? ((BranchEn) ? Branch2 : ReadB) : {13'b0000000000000, Instruction[2:0]};
	assign RegWriteValue = MemToReg ? MemReadValue : ALU_out1;  // 2:1 switch into reg_file

ALU ALU1(
  .InputA(InA),      	  
  .InputB(InB),
  .OP(ALUOp),				  
  .Out1(ALU_out1),
  .Out2(ALU_out2),		  			
  .Zero()
);
	 
DataMem DM1(
	.Clk 		  	(Clk)     ,
	.Reset		  (Reset),
	.MemWrite      (MemWrite), 
	.MemRead	(MemRead),
	.Byte 		(Byte),
	.DataAddress  (ReadA)    , 
	.DataIn       (ReadA), 
	.DataOut      (MemReadValue)
);

// count number of instructions executed
	always @(posedge Clk)
	  if (Start == 1)	   // if(start)
		 CycleCt <= 0;
	  else if(Ack == 0)   // if(!halt)
		 CycleCt <= CycleCt+16'b1;

endmodule