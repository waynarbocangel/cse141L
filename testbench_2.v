//  CSE141L Summer session1 2021
//  pulses start while loading program 2 operand into CPU
//  waits for done pulse from CPU 
//  reads and verifies result from CPU against its own computation
`timescale 1ns/1ps

module test_bench_2;

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


// program 2 variables
reg[7:0]  N;      				// number of inputs;
reg[15:0]  numbers[255:0];	    // numbers;
reg[15:0] result;	            // final result

// program 2 desired values

reg[15:0] real_result;	     // final correct result
real quotientR;			    //  quotient in $real format
reg[63:0] tmp;
reg[63:0] quotient;
reg [23:0] sum;
reg [23:0] dividend;
reg [7:0] divisor;
integer i;

// clock -- controls all timing, data flow in hardware and test bench
always begin
    #5 clk = ~clk;
end

initial begin
    clk = 0;
    // launch program 2 with the first input
    start = 1;
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

	//***** Secnod Test Case ******
	#20 reset = 1;
	#20 start = 1;
    N = 16'd6; 
	numbers [1][7:0]  =   8'd0; //fraction part of input1
	numbers [1][15:8] =   8'd1;  //int part of input1
	numbers [2][7:0]  =   8'd0; //fraction part of input2
	numbers [2][15:8] =   8'd2;  //int part of input2
	numbers [3][7:0]  =   8'd0; //fraction part of input3
	numbers [3][15:8] =   8'd4;  //int part of input3
	numbers [4][7:0]  =   8'd0; //fraction part of input4
	numbers [4][15:8] =   8'd8;  //int part of input4
	numbers [5][7:0]  =   8'd0; //fraction part of input5
	numbers [5][15:8] =   8'd16;  //int part of input5
	numbers [6][7:0]  =   8'd0; //fraction part of input6
	numbers [6][15:8] =   8'd32;  //int part of input6

	
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

	//***** Third Test Case ******
	#20 reset = 1;
	#20 start = 1;
    N = 16'd4; 
	numbers [1][7:0]  =   8'd0; //fraction part of input1
	numbers [1][15:8] =   8'd0;  //int part of input1
	numbers [2][7:0]  =   8'b10000000; //fraction part of input2
	numbers [2][15:8] =   8'd64;  //int part of input2
	numbers [3][7:0]  =   8'b10000000; //fraction part of input3
	numbers [3][15:8] =   8'd128;  //int part of input3
	numbers [4][7:0]  =   8'b10000000; //fraction part of input4
	numbers [4][15:8] =   8'd128;  //int part of input3

	
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

    
end

task automatic avg;
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

task automatic div;
begin
  tmp = dividend<<40;
  quotient = tmp/divisor;
  real_result = quotient[63:40];
  quotientR = $itor(dividend)/(256.0*$itor(divisor));
end
endtask

endmodule


