// Design code 

`timescale 1ns/1ps

module top 
  #(parameter clk_freq 1000000, parameter baud_rate 9600)
  (input clk,
   input rst,
   input rx,
   input newd,
   input [7:0] dintx,
   output reg donerx, donetx,
   output reg [7:0] doutrx,
   output reg tx);
  
  uarttx #(clk_freq,baud_rate) (clk, rst, newd, dintx, donetx, tx);
  uartrx #(clk_freq,baud_rate) (clk, rst, rx, donerx, doutrx);
  
endmodule 



module uarttx
  #(parameter clk_freq, parameter baud_rate)
  (input clk,rst,
   input newd,
   input [7:0] dintx,
   output reg donetx,
   output reg tx);
  
  enum {idle =1'b0, transfer = 1'b1} op;
  op state;
  
  int counts=0;
  int count=0;
  
  reg uclk;
  reg [7:0] din;
  
  localparam ratio=(clk_freq/baud_rate);
  
  always@(posedge clk)
    begin
      if(count<ratio/2)
        count<=count+1;
      else 
        begin
          count<=0;
          uclk<=~uclk;
        end
    end
  
  always@(posedge uclk)
    begin
      if(rst)
        begin
          state<=idle;
        end
      else
        case(state)
          idle : begin
            counts<=1'b0;
            tx<=1'b1;
            donetx<=1'b0;
            if(newd==1'b1)
            	 begin
                   din<=dintx;
                   tx<=1'b0;
                   state<=transfer;
                 end
          		 else
                     state<=idle;
                   end
            transfer : begin
              if(counts<=7)
               	begin
                  count<=count+1;
                  tx<=din[counts];
                  state<=transfer;
                end
              else
                begin
                state<=idle;
              	tx<=1'b1;
                donetx<=1'b1;
                end
            end
          
          default: begin
            state<=idle;
          end
        endcase
    end
endmodule



module uartrx
  #(parameter clk_freq, parameter baud_rate)
  (input clk, rst,
   input rx,
   output reg donerx,
   output reg [7:0] doutrx);
  
  int counts=0;
  int count=0;
  
  localparam ratio=(clk_freq/baud_rate);
  
  enum {idle=1'b0, receive =1'b1} op;
  op state;
  
  reg uclk;
  
  always@(posedge clk)
    begin
      if(count<ratio/2)
        count<=count+1;
      else
        begin
          count<=0;
          uclk<=~uclk;
        end
    end
  
  always @(posedge uclk)
    begin
      if(rst)
        begin
          state<=idle;
        end
      else
        case(state)
          idle : begin
            counts<=1'b0;
            doutrx<=8'b00000000;
            donerx<=1'b0;
            if(rx==1'b0)
              state<=receive;
            else
              state<=idle;
          end
          
          receive : begin
            if(counts<=7)
              begin
                doutrx<={rx,doutrx[7:1]};
                state<=receive;
              end
            else
              begin
                doutrx<=8'h00;
                state<=idle;
                donerx<=1'b1;
              end
          end
          
          default : state<=idle;
        endcase
    end
endmodule



interface uart_if;
  logic uclktx;
  logic uclkrx;
  logic clk;
  logic rst;
  logic rx;
  logic newd;
  logic [7:0] dintx;
  logic donetx;
  logic donerx;
  logic tx;
  logic [7:0] doutrx;
endinterface




// Verification environment

class transaction;
  
  typedef enum bit {write =1'b0, read = 1'b1} oper_type;
  randc oper_type oper;
  
  rand [7:0] dintx;
  
  bit rx;
  bit newd;
  bit donerx, donetx;
  bit [7:0] doutrx;
  bit tx;
  
  function transaction copy();
    
    copy=new();
    copy.oper = this.oper;
    copy.dintx=this.dintx;
    copy.rx=this.rx;
    copy.newd=this.newd;
    copy.donerx=this.donerx;
    copy.donetx=this.donetx;
    copy.doutrx=this.doutrx;
    copy.tx=this.tx;
    
  endfunction
  
endclass



class generator;
  
transaction tr;
  
event done;
event sconext;
event drvnext;
  
int count;

mailbox #(transaction) mbx;
  
function new(mailbox #(transaction) mbx);  
  this.mbxd=mbxd;
  this.mbxs=mbxs;
endfunction
  
  task run();
    repeat(count)
      begin
        tr=new();
        assert(tr.randomize)
          $display("[GEN], OPERATION : %0d, VALUE : %0d", tr.oper.name(),tr.dintx);
        else
          $error("RANDOMIZATION FAILED");
        mbx.put(tr.copy);
        @(drvnext);
        @(sconext);
      end
    ->done;
  endtask
  
endclass
  


class driver;
  
transaction tr;
  
  mailbox #(transaction) mbx;
  mailbox #(bit [7:0]) mbxds;
  
  event drvnext;
  
  bit [7:0] din;
  bit wr=0;
  bit [7:0] datarx;
  
  virtual interface uart_if vif;
    
    function new(mailbox #(transaction) mbx, mailbox #(transaction) mbxds);
      this.mbxs=mbxs;
      this.mbx=mbx;
    endfunction
    
    task reset();
      vif.rst<=1'b1;
      vif.dintx<=8'b00000000;
      vif.newd<=0;
      vif.rx<=1'b1;
      repeat(5) @(posedge vif.uclktx);
      vif.rst<=1'b0;
      @(posedge vif.uclktx);
      $display("[DRV] : RESET DONE");
    endtask
    
    task run();
      forever 
        begin
          mbx.get(tr);
          if(tr.oper==1'b0)
            begin
              @(posedge vif.uclktx);
              vif.rst<=1'b0;
              vif.newd<=1'b1;
              vif.rx<=1'b1;
              vif.dintx=tr.dintx;
              @(posedge vif.uclktx);
              vif.newd<=1'b0;
              mbxs.put(tr.dintx);
              $display("[DRV] : Data sent : %0d ", tr.dintx);
              wait(vif.donetx==1'b1);
              ->drvnext;
            end
          else if(tr.oper==1'b1)
            begin
              @(posedge vif.uclktx);
              vif.rst<=1'b0;
              vif.newd<=1'b0;
              vif.rx<=1'b0;
              @(posedge vif.uclkrx);
              for(int i=0;i<=7;i++)
                begin
                  @(posedge vif.uclkrx);
                  vif.rx<=$urandom;
                  datarx[i]=vif.rx;
                end
              
              mbxs.put(datarx);
              
              $display("[DRV] : Data rcvd : %0d" , datarx);
              wait(vif.donerx==1'b1);
              vif.rx<=1'b1;
              ->drvnext;
            end
        end
    endtask
endclass
    
    
    
    
class monitor;

  transaction tr;
  
  mailbox #(bit [7:0]) mbx;
  
  virtual uart_if vif;
  
  bit[7:0] srx;
  bit [7:0] rrx;
  
  function new(mailbox #(bit [7:0]) mbx);
    this.mbx=mbx;
  endfunction
  
  task run();
    forever begin
      @(posedge vif.uclktx);
      if((vif.newd==1'b1)&&(vif.rx==1'b1))
        begin
          @(posedge vif.uclktx);
          for(int i=0;i<=7;i++)
            begin
              @(posedge vif.uclktx);
              srx[i]=vif.tx;
            end
          $display("[MON] : Data sent on UART TX %0d", srx);
          @(posedge vif.uclktx);
          mbx.put(srx);
        end
      else if((vif.rx==1'b0)&&(vif.newd==1'b0))
        begin
          wait(vif.donerx==1);
          rrx=vif.doutrx;
          $display("[MON] : Data received RX %0d ", rrx);
          @(posedge vif.uclktx);
          mbx.put(rrx);
        end
    end
  endtask
endclass
    
    
              
class scoreboard;
  
transaction trd;
transaction trm;
  
mailbox #(bit [7:0]) mbxd;
mailbox #(bit [7:0]) mbxm;
  
virtual uart_if vif;
  
bit [7:0] ds, ms;
  
event sconext;
  
  function new (mailbox #(bit [7:0]) mbxd, mailbox #(bit [7:0]) mbxm);
    this.mbxd=mbxd;
    this.mbxm=mbxm;
  endfunction 
  
  task run();
    forever 
      begin
        mbxd.get(ds);
        mbxm.get(ms);
        $display("[SCO] : DRV : %0d MON : %0d", ds, ms);
        if(ds==ms)
          $display("Data matched");
        else
          $display("Data mismatched");
        ->sconext;
      end
  endtask
endclass
    
    
    
class environment;
  
  generator 
////////////////////////////////////////////////////// .............STILL WRITING CODE.................////////////////////////////////////////////////
