// This code demonstrates the use of pre-randomization and post-randomization methods in system verilog 

class generator; 
randc bit [7:0] x,y,z;
int min,max;
  extern constraint data;
  extern function void pre_randomize(input int min, input int max);
    extern function void post_randomize();
endclass
      
      function void generator::pre_randomize(input int min,input int max);
        this.min=min;
        this.max=max;
      endfunction
      constraint generator::data{ x inside{[min:max]};
                                 y inside {[min:max]}; z inside {[min:max]};};
      
function void generator::post_randomize();
$display("x=%d, y=%d, z=%d",x,y,z);
endfunction
module tb;
generator g;
initial
begin
g=new();
for(int i=0;i<20;i++)
begin
  g.pre_randomize(0,10);
g.randomize();
end
end
endmodule

