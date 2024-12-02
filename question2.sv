// Create a Class consisting of 3 data members each of unsigned integer type. Initialize them to 45,78, and 90. Use the display function to print the values on
// the console.
class C;

int unsigned a,b,x;

endclass

module m;

C c;

initial 

begin

c=new();

c.a=45;c.b=78;c.x=90;

  $strobe(c.a," ",c.b," ",c.x);

end

endmodule
