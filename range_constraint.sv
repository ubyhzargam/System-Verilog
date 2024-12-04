// This code demonstrates how to add range constraints to variables x,y and z

class generator;
  randc bit [3:0] x,y,z;
  constraint data{!(x inside{[1:10]});
                  y inside{[2:4],[11:12]};
                  z == 13;}
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

