// Check if randomization is successful using the keyword assert

class generator;
  
  randc bit [3:0] a,b;
  constraint data {a>17;}
endclass

module tb;
generator g;
initial
begin
  g=new();
  for(int i=0;i<10;i++)
    begin
      assert(g.randomize())
      else
        begin
          $display("Randomization failed at time %d",$time);
          $finish;
        end
      $display(g.a," ",g.b);
      #10;
    end
end
endmodule
