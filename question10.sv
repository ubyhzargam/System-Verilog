// Code for transaction class is mentioned in the Instruction tab. Write a code to send transaction data between generator and driver. Also, verify the data by
// printing the value of data members of Generator and Driver.

class transaction;
 
 bit [7:0] addr = 7'h12;
 bit [3:0] data = 4'h4;
 bit we = 1'b1;
 bit rst = 1'b0;
 
endclass

class generator;
  transaction t;
  mailbox #(transaction) mbx;
  
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;
  endfunction
  
  task run();
          t=new();
          mbx.put(t);
          $display(" DATA SENT || addr = %0d, data = %0d, we = %0d, rst = %0d",t.addr,t.data,t.we,t.rst);
  endtask
  
endclass

class driver;
  transaction datac;
  mailbox #(transaction) mbx;
  
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;
  endfunction
  
  task run();
    mbx.get(datac);
    $display(" DATA RCVD || addr = %0d, data = %0d, we = %0d, rst = %0d",datac.addr, datac.data, datac.we, datac.rst);
  endtask
endclass

module tb;
  mailbox #(transaction) mbx;
  generator g;
  driver d;
  initial
    begin
      mbx=new();
      g=new(mbx);
      d=new(mbx);
  fork
    g.run();
    d.run();
  join
    end
endmodule
  
