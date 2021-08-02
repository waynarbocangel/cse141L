//  CSE141L Summer session1 2021
//  pulses start while loading program 1 operand into CPU
//  waits for done pulse from CPU 
//  reads and verifies result from CPU against its own computation
`timescale 1ns/1ps

module test_bench_1;

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


// program 1 variables
reg[15:0] dividend;      // divident;
reg[7:0]  divisor;	     // divisor;
reg[23:0] result;	     // final result

// program 1 desired values

reg[23:0] real_result;	     // final correct result
real quotientR;			    //  quotient in $real format
reg[63:0] tmp;
reg[63:0] quotient;


// clock -- controls all timing, data flow in hardware and test bench
always begin
    #5 clk = ~clk;
end

initial begin
    clk = 0;
    // launch program 1 with the first input
    start = 1;
    dividend = 16'd12800; 
    divisor =  8'd25;

    //calculate the correct values
    if(divisor) 
        div; //divide only if divisor is non-zero
    else 
        real_result = '1;

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
               dividend, divisor, quotient, result, quotientR);

    if(result==real_result) 
        $display("success -- match");
    else 
        $display("OOPS! expected %h, got %h", real_result, result);
//
   #20 reset = 1;
   #20 start = 1;
   dividend = 16'd385; 
   divisor =  8'd6;

   //calculate the correct values
   if(divisor) 
       div; //divide only if divisor is non-zero
   else 
       real_result = '1;

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
              dividend, divisor, quotient, result, quotientR);

   if(result==real_result) 
       $display("success -- match");
   else 
       $display("OOPS! expected %h, got %h", real_result, result);


    
end


task automatic div;
begin
  tmp = dividend<<48;
  quotient = tmp/divisor;
  real_result = quotient[63:40];
  quotientR = $itor(dividend)/$itor(divisor);
end
endtask

endmodule


