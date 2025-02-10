// Design code
module dff (dff_if vif);
 
  always @(posedge vif.clk)
    begin
      if (vif.rst == 1'b1)
        vif.dout <= 1'b0;
      else
        vif.dout <= vif.din;
    end
  
endmodule
 


interface dff_if;
  logic clk;   
  logic rst;  
  logic din;   
  logic dout;  
  
endinterface


// Verification Environment 

`include "uvm_macros.svh"
class transaction;
  
  randc logic din;
  logic dout;
  
  function transaction copy();
    copy=new();
    copy.din=this.din;
    copy.dout=this.dout;
  endfunction
  
  function void display(string s);
    $display("[%0s] DIN : %0d , DOUT : %0d", s, din, dout);
  endfunction
  
endclass



class generator;
  
  mailbox #(transaction) mbx;
  mailbox #(transaction) mbxref;
  
  transaction tr;
  
  event sconext;
  event done;
  
  int count;
  
  function new(mailbox #(transaction) mbx, mailbox #(transaction) mbxref);
    this.mbx=mbx;
    this.mbxref=mbxref;
  endfunction
  
  task run();
    repeat(count) 
      begin
      tr=new();
    assert(tr.randomize)
      else 
        $error ( "[GEN] : RANDOMIZATION FAILED");
    mbx.put(tr);
    mbxref.put(tr);
    tr.display("GEN");
        @(sconext);
    end
    ->done;
  endtask
endclass



class driver;
  
  transaction tr;
  mailbox #(transaction) mbx;
  virtual dff_if vif;
    
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;
  endfunction
  
  task reset();
    vif.rst<=1'b1;
    repeat(5) @(posedge vif.clk);
    vif.rst<=1'b0;
    @(posedge vif.clk);
    $display("[DRV] Reset Done");
  endtask
  
  task run();
    forever 
      begin
    mbx.get(tr);
        vif.din<=tr.din;
        @(posedge vif.clk);
        vif.din<=1'b0;
        @(posedge vif.clk);
      end
  endtask
  
endclass



class monitor;
  
  transaction tr;
  mailbox #(transaction) mbx;
  virtual dff_if vif;
  
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;
  endfunction
  
  task run();
    tr=new();
    forever begin
      repeat(2) @(posedge vif.clk);
      tr.dout=vif.dout;
      mbx.put(tr);
      tr.display("MON");
    end
  endtask
  
endclass



class scoreboard;
  
  transaction tr;
  transaction trref;
  mailbox #(transaction) mbx;
  mailbox #(transaction) mbxref;
  
  event sconext;
  
  function new(mailbox #(transaction) mbx, mailbox #(transaction) mbxref);
    this.mbx=mbx;
    this.mbxref=mbxref;
  endfunction
  
  task run();
    forever begin
      mbx.get(tr);
      mbxref.get(trref);
      tr.display("SCO");
      trref.display("REF");
      if(tr.dout==trref.din)
        $display("[SCO] : DATA MATCHED ");
      else 
        $display("[SCO] : DATA MISMATCHED ");
      ->sconext;
    end
  endtask
endclass



class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  event next;
  
  mailbox #(transaction) gtsmbx;
  mailbox #(transaction) gtdmbx;
  mailbox #(transaction) mtsmbx;
  
  virtual dff_if vif;
  
  function new(virtual dff_if vif);
               gtsmbx=new();
               gtdmbx=new();
               mtsmbx=new();
               gen=new(gtdmbx,gtsmbx);
               drv=new(gtdmbx);
               mon=new(mtsmbx);
               sco=new(mtsmbx,gtsmbx);
               this.vif=vif;
               drv.vif=this.vif;
               mon.vif=this.vif;
               gen.sconext=next;
               sco.sconext=next;
   endfunction
               
   task pre_test();
     drv.reset();
   endtask
   
               task test();
                 fork
                   gen.run();
                   drv.run();
                   mon.run();
                   sco.run();
                 join_any
               endtask
               
               task post_test();
                 wait(gen.done.triggered)
                 $finish();
               endtask
               
               task run();
                 pre_test();
                 test();
                 post_test();
               endtask
  endclass
               
               
                 
                 
  module tb;
    dff_if vif();
    dff dut(vif);
    
    initial begin
      vif.clk<=0;
    end
    
    always #10 vif.clk<=~vif.clk;
    
    environment env;
    
    initial
    begin
      env=new(vif);
      env.gen.count=30;
      env.run();
    end
    
    initial 
      begin
        $dumpfile("dump.vcd");
        $dumpvars;
      end
  endmodule
  
  
    
    
