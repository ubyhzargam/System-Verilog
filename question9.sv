// Create two tasks each capable of sending a message to Console at a fixed interval. Assume Task1 sends the message "Task 1 Trigger" at an interval of 20 ns 
// while Task2 sends the message "Task 2 Trigger" at an interval of 40 ns. Keep the count of the number of times Task 1 and Task 2 trigger by adding a variable 
// for keeping the track of task execution and incrementing with each trigger. Execute both tasks in parallel till 200 nsec. Display the number of times Task 1 
// and Task 2 executed after 200 ns before calling $finish for stopping the simulation.

module tb;
  
int c1=0,c2=0;

task t1();
forever 
begin
$display("Task 1 Triggered at time %0d",$time);
#20;
c1=c1+1;
end
endtask

task t2();
forever 
begin
$display("Task 2 Triggered at time %0d",$time);
#40;
c2=c2+1;
end
endtask
  
task t3();
#200;
$display("The number of times task 1 executed = %0d and task 2 executed = %0d",c1,c2); 
$finish();
endtask

initial begin
fork 
t1();
t2();
t3();
join
end

endmodule

