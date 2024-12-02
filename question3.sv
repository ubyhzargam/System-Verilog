// Create a function that will perform the multiplication of the two unsigned integer variables. Compare values return by function with the expected result and
// if both values match send "Test Passed" to Console else send "Test Failed".Create a function that will perform the multiplication of the two unsigned 
// integer variables. Compare values return by function with the expected result and if both values match send "Test Passed" to Console else send "Test Failed".

module tb;

function int unsigned mul(input int unsigned a,b);

return a*b;

endfunction

int unsigned x,y;

int unsigned p;

initial

begin

x=10;

y=20;

p=x*y;

  if(p==mul(x,y))

$display("Test passed");

else

$display("Test failed");

end

endmodule
