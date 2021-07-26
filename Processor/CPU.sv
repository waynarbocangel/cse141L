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
	
	wire [ 9:0] PgmCtr,        // program counter
			      PCTarg;
	wire [ 8:0] Instruction;   // our 9-bit instruction
	wire [ 7:0] S;				// flag register
	wire [ 2:0] Instr_opcode, ALUOP;  // out 3-bit opcode
	wire [ 15:0] ReadA, ReadB;  // reg_file outputs
	wire [ 15:0] InA, InB, 	   // ALU operand inputs
					ALU_out1, ALU_out2;       // ALU result
	wire [ 15:0] RegWriteValue, // data in to reg file
					MemWriteValue, // data in to data_memory
					MemReadValue;  // data out from data_memory
	wire        MemWrite,	   // data_memory write enable
				   RegWrEn,	      // reg_file write enable
				   Zero,		      // ALU output = 0 flag
					BranchEn,
					StFlag;	   // to program counter: branch enable
	logic  [15:0] CycleCt;	      // standalone; NOT PC!

	// Fetch = Program Counter + Instruction ROM
	// Program Counter
  InstFetch IF1 (
	.Reset       (Reset   ) , 
	.Start       (Start   ) ,  // SystemVerilg shorthand for .halt(halt), 
	.Clk         (Clk     ) ,  // (Clk) is required in Verilog, optional in SystemVerilog
	.BranchRelEn (BranchEn) ,  // branch enable
	.ALU_flag	 (Zero    ) ,
    .Target      (PCTarg  ) ,
	.ProgCtr     (PgmCtr  )	   // program count = index to instruction memory
	);	

	// Control decoder
  Ctrl Ctrl1 (
	.Instruction  (Instruction), // from instr_ROM
	.Jump         (Jump),		     // to PC
	.BranchEn     (BranchEn)		 // to PC
  );
	// instruction ROM
  InstROM IR1(
	.InstAddress   (PgmCtr), 
	.InstOut       (Instruction)
	);
	
	assign LoadInst = Instruction[8:6]==3'b000;  // calls out load specially
	
	always_comb							  // assign Zero = !Out;
	begin
		Ack = Instruction[0];
	end
	//Reg file
	// Modify D = *Number of bits you use for each register*
	RegFile #(.W(8),.D(3)) RF1 (
		.Clk    		(Clk)		  ,
		.WriteEn   (RegWrEn)    ,
		.StFlag	   (Instruction[8:6] == 3'b001), 
		.RaddrA    (Instruction[5:3]),         //concatenate with 0 to give us 4 bits
		.RaddrB    (Instruction[2:0]), 
		.Waddr     (Instruction[5:3]), 	       // mux above
		.DataIn    (RegWriteValue) , 
		.DataOutA  (ReadA        ) , 
		.DataOutB  (ReadB		 ),
		.S 		   (S)
	);
	
	
	
	assign InA = ReadA;						          // connect RF out to ALU in
	assign InB = (S == 0) ? ReadB : {13'b0000000000000, Instruction[2:0]};
	assign Instr_opcode = Instruction[8:6];
	assign MemWrite = (S && Instruction[8:6] == 0);       // mem_store command
	assign RegWriteValue = LoadInst? MemReadValue : ALU_out;  // 2:1 switch into reg_file
	assign ALUOP = (Instruction[8:6] == 4 && S) ? 3'b110 : Instruction[8:6];

ALU ALU1(
  .InputA(InA),      	  
  .InputB(InB),
  .OP(ALUOP),				  
  .Out1(ALU_out1),
  .Out2(ALU_out2),		  			
  .Zero()
);
	 
DataMem DM1(
	.DataAddress  (ReadA)    , 
	.WriteEn      (MemWrite), 
	.DataIn       (MemWriteValue), 
	.DataOut      (MemReadValue)  , 
	.Clk 		  	(Clk)     ,
	.Reset		  (Reset)
);

// count number of instructions executed
	always @(posedge Clk)
	  if (Start == 1)	   // if(start)
		 CycleCt <= 0;
	  else if(Ack == 0)   // if(!halt)
		 CycleCt <= CycleCt+16'b1;

endmodule