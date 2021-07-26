// Design Name:    CSE141L
// Module Name:    reg_file 
//
// Additional Comments: 					  $clog2

/* parameters are compile time directives 
       this can be an any-size reg_file: just override the params!
*/
module RegFile (Clk,WriteEn,StFlag,RaddrA,RaddrB,Waddr,DataIn,DataOutA,DataOutB, S);
  input                Clk,
                       WriteEn,
					   StFlag;
  input        [3:0] RaddrA,				  // address pointers
                       RaddrB,
                       Waddr;
  input        [15:0] DataIn;
  output logic [15:0] DataOutA;			  // showing two different ways to handle DataOutX, for
  output logic [15:0] DataOutB;
  output logic [1:0] S = 0;				  //   pedagogic reasons only;

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [15:0] Registers[3:0];	  // or just registers[16] if we know D=4 always
// combinational reads 
/* can write always_comb in place of assign
    difference: assign is limited to one line of code, so
	always_comb is much more versatile     
*/

always_comb
begin
 DataOutA = Registers[RaddrA];	  
 DataOutB = Registers[RaddrB];    
end

// sequential (clocked) writes 
always_ff @ (posedge Clk) begin
  	if (WriteEn)	                             // works just like data_memory writes
    	Registers[Waddr] <= DataIn;
	if (StFlag)
		S <= DataIn[1:0];
end

endmodule
