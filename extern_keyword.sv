// This code demonstrates the use of extern keyword for defining and using external constraints and funcitons 

class generator; 

randc bit [7:0] x,y,z;

  extern constraint data;
extern function void display();

endclass
  
  constraint generator::data{ x inside{[0:50]};

                             y inside {[0:50]}; z inside {[0:50]};};

function void generator::display();

$display("x=%d, y=%d, z=%d",x,y,z);

endfunction

module tb;

generator g;

initial

begin

g=new();

for(int i=0;i<20;i++)

begin

g.randomize();

g.display();

end

end

endmodule

