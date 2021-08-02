// Module Name:    InstFetch 
// Project Name:   CSE141L
//
	 
module InstFetch(Reset,Start,Clk,BranchEn,ALU_flag,Target,ProgCtr);

  input         Reset,			   // reset, init, etc. -- force PC to 0 
                Start,			   // begin next program in series
                Clk,			   // PC can change on pos. edges only
				BranchEn,
                ALU_flag;		   // flag from ALU, e.g. Zero, Carry, Overflow, Negative (from ARM)
  input  logic [5:0] Target;	   // jump ... "how high?"
  output logic [9:0] ProgCtr ;     // the program counter register itself
  
  
  //// program counter can clear to 0, increment, or jump
	always_ff @(posedge Clk) begin
		if(Reset)
		  ProgCtr <= 0;				        // for first program; want different value for 2nd or 3rd
		else if(Start)						// hold while start asserted; commence when released
		  ProgCtr <= ProgCtr;
		else if(ALU_flag && BranchEn)    // conditional relative jump
			if (Target[5] == 1) begin
				ProgCtr <= ProgCtr - {4'b0000, (~Target[5:0] + 6'b000001)};
			end
			else begin
				ProgCtr <= Target + ProgCtr;
			end
		else
		  ProgCtr <= ProgCtr+'b1; 	        // default increment (no need for ARM/MIPS +4 -- why?)
	end


endmodule

/* Note about Start: if your programs are spread out, with a gap in your machine code listing, you will want 
to make Start cause an appropriate jump. If your programs are packed sequentially, such that program 2 begins 
right after Program 1 ends, then you won't need to do anything special here. 
*/