// Simple code to demostrate implication and equivalence operator on constraints 

class generator;
rand bit wr;
rand bit rst;
  
constraint ctrl{
wr dist{0:=30,1:=70};
rst dist{0:=50,1:=50};
}
  
  constraint c1{
    (wr==0)<->(rst==1);
  }
  
  constraint c2{
    (wr==1)->(rst==0);
  }

function void display();
$display("wr = %d, rst= %d",wr,rst);
endfunction
endclass

module tb;
generator g;
initial begin
g=new();
  for(int i=0;i<20;i++)
begin
g.randomize();
g.display();
  #10;
end
end
endmodule
