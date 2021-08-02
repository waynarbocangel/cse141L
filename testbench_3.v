//  CSE141L Summer session1 2021
//  pulses start while loading program 3 operand into CPU
//  waits for done pulse from CPU 
//  reads and verifies result from CPU against its own computation
`timescale 1ns/1ps

module test_bench_3;

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


// program 3 variables
reg[7:0]  N;      				// number of inputs;
reg[7:0]  Xnumbers[255:0];	    // x numbers;
reg[7:0]  Ynumbers[255:0];	    // x numbers;

reg[15:0] result;	            // final result

// program 3 desired values

reg[15:0] real_result;	     // final correct result
real quotientR;			    //  quotient in $real format
reg[63:0] tmp;
reg[63:0] quotient;
reg [15:0] sum;
reg [15:0] dividend;
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
    start = 1;
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
	for (i = N+1; i <= 2*N; i = i +1) begin
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

	//***** Secnod Test Case ******
	#20 reset = 1;
	#20 start = 1;
    	N = 16'd4; 
	Xnumbers [1]  =  8'd2;
	Xnumbers [2]  =  8'd4;
	Xnumbers [3]  =  8'd8;
	Xnumbers [4]  =  8'd10;
	Ynumbers [1]  =  8'd7;
	Ynumbers [2]  =  8'd3;
	Ynumbers [3]  =  8'd5;
	Ynumbers [4]  =  8'd1;
	
	cov;

    // ***change names of memeroy or its guts as needed***
    dut.DM1.Core[0] = N;
	for (i = 1; i <= N; i = i + 1) begin
		dut.DM1.Core[i] = Xnumbers[i];
	end
	for (i = N+1; i <= 2*N; i = i +1) begin
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


