// Simple sv code to demonstrate triggering an event and how to receive the triggering of events using @ and wait 

module tb;
  event a,b;
  initial
  begin
    #10;
    ->a;
    #30
    ->b;
  end
  initial
    begin
      @(a);
      $display("Received event a at time %0d",$time);
      wait(b.triggered);
      $display("Received event b at time %0d", $time);
    end
endmodule
