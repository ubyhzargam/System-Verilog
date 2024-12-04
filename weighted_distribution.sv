// This is a code to demonstrate weigthed distribution of values for a randomized variable

class generator;
rand bit wr;
rand bit rst;
  
constraint ctrl{
wr dist{0:=30,1:=70};
rst dist{0:=50,1:=50};
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
