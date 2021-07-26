// Design Name:
// Module Name:    DataMem
// single address pointer for both read and write
// CSE141L
module DataMem(Clk,Reset,WriteEn,DataAddress,DataIn,DataOut);
  input              Clk,
                     Reset,
                     WriteEn;
  input [7:0]        DataAddress,   // 8-bit-wide pointer to 256-deep memory
                     DataIn;		// 8-bit-wide data path, also
  output logic[7:0]  DataOut;

  logic [7:0] Core[256-1:0];			// 8x256 two-dimensional array -- the memory itself

  integer i;
/* optional way to plant constants into DataMem at startup
    initial 
      $readmemh("dataram_init.list", Core);
*/
  always_comb begin         // reads are combinational
    DataOut = Core[DataAddress];
  end
  
  always_ff @ (posedge Clk)		 // writes are sequential
/*( Reset response is needed only for initialization (see inital $readmemh above for another choice)
  if you do not need to preload your data memory with any constants, you may omit the if(Reset) and the else,
  and go straight to if(WriteEn) ...
*/
	begin
    if(Reset) begin
// you may initialize your memory w/ constants, if you wish
      for(i=0;i<256;i = i + 1)
	    Core[i] <= 0;
      Core[ 16] <= 254;          // overrides the 0  ***sample only***
      Core[244] <= 5;			 //    likewise
	end
    else if(WriteEn) 
      Core[DataAddress] <= DataIn;
	end
endmodule