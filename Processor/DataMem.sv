// Design Name:
// Module Name:    DataMem
// single address pointer for both read and write
// CSE141L
module DataMem(Clk,Reset,MemWrite,MemRead,Byte,DataAddress,DataIn,DataOut);
  input              Clk,
                     Reset,
                     MemWrite,
					 MemRead,
					 Byte;
  input [7:0]        DataAddress;   // 8-bit-wide pointer to 256-deep memory
  input [15:0]       DataIn;		// 8-bit-wide data path, also
  output logic [15:0]  DataOut;

  logic [7:0] Core[256-1:0];			// 8x256 two-dimensional array -- the memory itself
  logic [7:0] Buffer;
  integer i;

  
  always_comb begin         // reads are combinational
	Buffer = 0;
	DataOut = 0;
	if (MemRead) begin
		Buffer = Core[DataAddress];
		if (Byte) begin
			DataOut = {Buffer[7:0], DataIn[7:0]};
		end
		else begin
			DataOut = {DataIn[15:8], Buffer[7:0]};
		end
	end
  end
  
  always_ff @ (posedge Clk)	begin
	if (Reset) begin
		for (i = 0; i < 256; i = i + 1) Core[i] <= 0;
	end
    else if(MemWrite) 
		if (Byte) begin
			Core[DataAddress] <= DataIn[15:8];
		end
		else begin
			Core[DataAddress] <= DataIn[7:0];
		end
	end
endmodule