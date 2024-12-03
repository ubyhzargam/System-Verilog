// Assume class consists of three data members a, b, and c each of size 4-bit. Create a task inside the class that returns the result of the addition of data 
// members. The task must also be capable of sending the value of a, b, c, and result to the console. Verify code for a = 1, b = 2, and c = 4.
class Uby;

bit [3:0] a,b,c;

bit [4:0] sum;

function new(input bit [3:0] x,y,z);

a=x;b=y;c=z;

endfunction

task add();

sum=a+b+c;

$display("a=%d b=%d c=%d sum=%d",a,b,c,sum);

endtask

endclass

module m;

Uby H;

initial

begin

H=new(1,2,4);

H.add();

end

endmodule
