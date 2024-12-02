// Write a task generate a clock taking input as ton, toff and phase delay 

task clock_gen(input real phase, input real ton, input real toff, output reg clk);
  #phase;
  while(1)
    begin
      clk=1;
      #ton; clk=0;
      #toff; end
endtask
