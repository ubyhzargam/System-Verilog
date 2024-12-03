// A code to demonstrate deep copy of object when we have both data members and handlers in a class

class generator;
bit [3:0] a=5,b=7;
bit wr=1;
bit en=1;
bit [4:0] s=12;
function generator copy();
copy=new();
copy.a=a;
copy.b=b;
copy.wr=wr;
copy.en=en;
copy.s=s;
endfunction
function void display();
$display("a:%0d b:%0d wr:%0b en:%0b s:%0d", a,b,wr, en,s);
endfunction
endclass

class first;
generator g;
  function new();
    g=new();
  endfunction
  function first copy();
    copy=new;
    copy.g=g.copy;
  endfunction
    endclass

module tb;
generator g1;
generator g2;
first f1;
first f2;
initial
begin
f1=new();
f2=new();
g1=new();
g2=new();
f1.g.a=3;
f2=f1.copy();
f2.g.a=4;
g2=g1.copy();
g2.a=2;g2.b=1;
g2.display();
g1.display();
$display(f1.g.a," ",f2.g.a);
end
endmodule

