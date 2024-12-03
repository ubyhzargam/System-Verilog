// Create a function that generate and return 32 values of multiple of 8 (0, 8, 16, 24, 32, 40 .... 248). Store this value in the local array of the testbench
// top and also print the value of each element of this array on the console.

module tb;

function automatic void init_arr(ref int arr[32]);

  for(int i=0;i<32;i++)

arr[i]=8*i;

endfunction

int arr[32];

initial

begin

init_arr(arr);

$display("%p",arr);

end

endmodule
