// Create a generator class to generate 20 random values for 8 bit variables x,y and z
class generator;

randc bit [7:0] x,y,z;

endclass

module tb;

generator g;

initial

begin

g=new();

  for(int i=0;i<20;i++)begin

    assert(g.randomize()) else

begin

$display("Randomization failed at %d time",$time);

$finish;

end

$display("The values of x, y and z are %d %d and %d",g.x,g.y,g.z);

end

end

endmodule

