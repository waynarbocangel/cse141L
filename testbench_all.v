// pulses start while loading program 1 operand into DUT
//  waits for done pulse from DUT
//  reads and verifies result from DUT against its own computation
// pulses start while loading program 2 operands into DUT
//  waits for done pulse from DUT
//  reads and verifies result from DUT against its own computation
// pulses start while loading program 3 operand into DUT
//  waits for done pulse from DUT
//  reads and verifies result from DUT against its own computation
 // Based on SystemVerilog source code provided by John Eldon
`timescale 1ns/1ps

module test_bench_all;

reg reset,  // Reset signal  
    clk,    // system clock runs testbench and CPU
    start;  // request to CPU

wire done;  // acknowledge back from CPU

// ***** instantiate your top level design here *****
  CPU dut(
    .Clk     (clk  ),   // input: use your own port names, if different
    .Reset   (init ),   // input: some prefer to call this ".reset"
    .Start   (start),   // input: launch program
    .Ack     (done )    // output: "program run complete"
  );


// variables
reg[7:0]  N;      				// number of inputs;
reg[7:0]  Xnumbers[255:0];	    // x numbers;
reg[7:0]  Ynumbers[255:0];	    // x numbers;

reg[23:0] result;	            // final result

//desired values

reg[15:0] real_result;	     // final correct result
reg[23:0] real_result_p1;	     // final correct result for p1
real quotientR;			    //  quotient in $real format
reg[63:0] tmp;
reg[63:0] quotient;
reg [15:0] sum;
reg [23:0] dividend;
reg [7:0]  divisor;
reg [15:0] numbers[255:0];
reg [15:0] x_bar;
reg [15:0] y_bar;
integer i,x;

// clock -- controls all timing, data flow in hardware and test bench
always begin
    #5 clk = ~clk;
end

initial begin
    clk = 0;
    // launch program 1 with the first input
	$display("******Program 1******");
    start = 1;
	dividend = 16'd12800; 
    divisor =  8'd25;

    //calculate the correct values
    if(divisor) 
        div; //divide only if divisor is non-zero
    else 
        real_result = '1;
		
	real_result_p1 = quotient[63:40]; // the output of program 1 is 24 bits

    // ***change names of memeroy or its guts as needed***
    dut.DM1.Core[0] = dividend[15:8];
    dut.DM1.Core[1] = dividend[7:0];
    dut.DM1.Core[2] = divisor;
    
    #20 start = 0;
    #20 wait(done);

    result[23:16] = dut.DM1.Core[4];
    result[15:8]  = dut.DM1.Core[5];
    result[7:0]   = dut.DM1.Core[6];

    $display ("dividend = %h, divisor = %h, quotient = %h, result = %h, equiv to %10.5f",
               dividend, divisor, quotient, result, quotientR*256);

    if(result==real_result_p1) 
        $display("success -- match");
    else 
        $display("OOPS! expected %h, got %h", real_result_p1, result);
		
	
	//******* Program 2 *********
	$display("******Program 2******");
	#10 start = 1;	
	
	 N = 16'd9; 
	numbers [1][7:0]  =   8'd0; //fraction part of input1
	numbers [1][15:8] =   8'd1;  //int part of input1
	numbers [2][7:0]  =   8'd0; //fraction part of input2
	numbers [2][15:8] =   8'd2;  //int part of input2
	numbers [3][7:0]  =   8'd0; //fraction part of input3
	numbers [3][15:8] =   8'd3;  //int part of input3
	numbers [4][7:0]  =   8'd0; //fraction part of input4
	numbers [4][15:8] =   8'd4;  //int part of input4
	numbers [5][7:0]  =   8'd0; //fraction part of input5
	numbers [5][15:8] =   8'd5;  //int part of input5
	numbers [6][7:0]  =   8'd0; //fraction part of input6
	numbers [6][15:8] =   8'd6;  //int part of input6
	numbers [7][7:0]  =   8'd0; //fraction part of input7
	numbers [7][15:8] =   8'd7;  //int part of input7
	numbers [8][7:0]  =   8'd0; //fraction part of input8
	numbers [8][15:8] =   8'd8;  //int part of input8
	numbers [9][7:0]  =   8'd0; //fraction part of input9
	numbers [9][15:8] =   8'd9;  //int part of input9
	
	
	avg;

    // ***change names of memeroy or its guts as needed***
    dut.DM1.Core[0] = N;
	for (i = 0; i < N; i = i+1) begin
		dut.DM1.Core[2*i+1] = numbers[i+1][15:8];
		dut.DM1.Core[2*i+2] = numbers[i+1][7:0];
	end
    
    
    #20 start = 0;
    #20 wait(done);

    result[15:8]  = dut.DM1.Core[2*N+1];
    result[7:0]   = dut.DM1.Core[2*N+2];

    $display ("dividend = %h, divisor = %h, quotient = %h, result = %h, equiv to %10.5f",
               dividend, divisor, quotient, result, quotientR);

    if(result==real_result) 
        $display("success -- match");
    else 
        $display("OOPS! expected %h, got %h", real_result, result);
		
		
	//********* Program 3************s
	$display("******Program 3******");
	#20 start  = 1;
		
		
    N = 16'd3; 
	Xnumbers [1]  =  8'd1;
	Xnumbers [2]  =  8'd2;
	Xnumbers [3]  =  8'd3;
	Ynumbers [1]  =  8'd10;
	Ynumbers [2]  =  8'd20;
	Ynumbers [3]  =  8'd27;
	
	cov;

    // ***change names of memeroy or its guts as needed***
    dut.DM1.Core[0] = N;
	for (i = 1; i <= N; i = i + 1) begin
		dut.DM1.Core[i] = Xnumbers[i];
	end
	for (i = N+1; i <= 2*N; i = i + 1) begin
		dut.DM1.Core[i] = Ynumbers[i-N];
	end
    
    
    #20 start = 0;
    #20 wait(done);

    result[15:8]  = dut.DM1.Core[2*N+1];
    result[7:0]   = dut.DM1.Core[2*N+2];

    $display ("dividend = %h, divisor = %h, quotient = %h, result = %h, equiv to %10.5f",
               dividend, divisor, quotient, result, quotientR);

    if(result==real_result) 
        $display("success -- match");
    else 
        $display("OOPS! expected %h, got %h", real_result, result);

	

    
end

task  cov; 
begin
	//calc x_bar
	for(i=0; i < 255; i = i+1) begin
		numbers[i] = Xnumbers[i]<<8;
	end
	avg;
	x_bar = real_result;
	$display("x_bar = %h", x_bar);
	
	//calc y_bar
	for(i=0; i < 255; i = i+1) begin
		numbers[i] = Ynumbers[i]<<8;
	end
	avg;
	y_bar = real_result;
	$display("y_bar = %h", y_bar);

	//calc cov
	for (i = 1; i <= N; i = i + 1) begin
		x = (((Xnumbers[i]<<8)-x_bar) * ((Ynumbers[i]<<8)-y_bar));
		numbers[i] = x>>8 ;

	end
	avg; 
end
endtask

task  avg;
begin 
	sum  = 0;
	for (i = 1; i <= N; i = i + 1) begin
		sum = sum + numbers[i];
	end
	dividend = sum;
	divisor = N;
	div ;
end
endtask

task  div;
begin
  tmp = dividend<<48;
  if ($signed(tmp) < 0) begin
	quotient = (-tmp)/divisor;
	quotient = -quotient;
	real_result = quotient[63:48];
	quotientR = $itor($signed(dividend))/(256*($itor(divisor)));
  end
  else begin
	quotient = $signed(tmp)/divisor;
	real_result = quotient[63:48];
	quotientR = $itor($signed(dividend))/(256*($itor(divisor)));
  end
  
  //$display("dividend = %h \t divisor = %h \t tmp = %h\t quotientR = %10.5f", dividend, divisor, tmp, quotientR);
end
endtask

endmodule


