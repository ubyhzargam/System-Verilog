// Write a code to create clock of period 20ns and 10ns

module tb();
reg clk1,clk2;
initial
  begin
    clk1=0;
    clk2=0;
  end

always
  #5 clk1=~clk1;

always 
  #10 clk2=~clk2;

endmodule

