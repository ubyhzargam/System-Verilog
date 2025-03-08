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



interface vif;
  logic uclktx;
  logic uclkrx;
  logic clk;
  logic rst;
  logic rx;
  logic tx_start;
  logic [7:0] data_in;
  logic txdone;
  logic rxdone;
  logic tx;
  logic [7:0] data_out;
endinterface



//VERIFICATION ENVIRONMENT

class transaction;

 typedef enum bit {read=1'b0,write=1'b1} oper_type;
 rand oper_type oper;

 randc bit [7:0] data_in;

 bit rx;
 bit tx_start;
 bit [7:0] data_out; 
 bit tx; 
 bit txdone; 
 bit rxdone; 

 function transaction copy();
	copy=new();
	copy.oper=this.oper;
	copy.data_in=this.data_in;
	copy.rx=this.rx;
	copy.tx_start=this.tx_start;
	copy.data_out=this.data_out;
	copy.tx=this.tx;
	copy.txdone=this.txdone;
	copy.rxdone=this.rxdone;
 endfunction

endclass



class generator;

 transaction pck; 
 mailbox #(transaction) mbxgd; 

 event drvnext; 
 event done; 
 event sconext;

 int count=0; 

 function new(mailbox #(transaction) mbxgd);
	this.mbxgd=mbxgd;
 endfunction

 task run();
	repeat(count)
	begin
		pck=new();
		assert(pck.randomize) 
		else
			$error("Randomization failed");
		mbxgd.put(pck.copy); 
  		if(pck.oper==1)
			$display("[GEN] : The randomized values are : data_in = %0d , operation name = %0s",pck.data_in,pck.oper.name());
  		else
    		$display("[GEN] : operation name = %0s",pck.oper.name());
		@(drvnext); 
		@(sconext);
	end
	->done;
 endtask

endclass



class driver;

 transaction pck; 

 mailbox #(transaction) mbxgd; 
 mailbox #(bit [7:0]) mbxds;
  
 bit [7:0] datarx;
 event drvnext; 

 virtual interface vif v;

 function new(mailbox #(transaction) mbxgd, mailbox #(bit [7:0]) mbxds);
	this.mbxgd=mbxgd; 
    this.mbxds=mbxds;
 endfunction
  
 task reset(); 
	@(posedge v.uclktx);
	v.rst<=1'b1;
	v.data_in<=8'd0;
	v.tx_start<=1'b0;
	v.rx<=1'b1;
	repeat(8) @(posedge v.uclktx); 
	v.rst<=1'b0;
	@(posedge v.uclktx);
	$display("[DRV] : Reset done ");
 endtask

 task run();
 forever
 begin
	mbxgd.get(pck); 
	if(pck.oper==1'b1)
	begin
		@(posedge v.uclktx);
		v.tx_start<=1'b1; 
		v.data_in<=pck.data_in;
		@(posedge v.uclktx);
		v.tx_start<=1'b0;
  		mbxds.put(pck.data_in);
  		$display("[DRV] : Data to be transmitted sent = %0d",v.data_in);
		wait(v.txdone==1'b1);
		->drvnext; 
	end
  
	else if(pck.oper==1'b0)
	begin
		v.rst<=1'b0;
		v.data_in<=8'd0;
		v.tx_start<=1'b0;
		@(posedge v.uclkrx);
		v.rx=1'b0;
		for(int i=0;i<=7;i++)
		begin
			@(posedge v.uclkrx);
			datarx[i]=$urandom;
			v.rx=datarx[i];
		end
  		mbxds.put(datarx);
  		$display("[DRV] : Data received through rx pin = %0d",datarx);
 		// @(posedge v.uclkrx);
		wait(v.rxdone==1'b1);
		v.rx<=1'b1;
		->drvnext;
	end
 end
 endtask
endclass


   
class monitor;

 transaction tr;
  
 mailbox #(bit [9:0]) mbx;
  
 virtual vif v;
  
 bit start,stop;
 bit [9:0] test;
 bit flag=0;
  
 function new(mailbox #(bit [9:0]) mbx);
 	this.mbx=mbx;
 endfunction
  
 task run();
 	forever 
    begin
    	@(posedge v.uclktx);
        if((v.tx_start==1'b1)&&(v.rx==1'b1))
        begin
        	@(posedge v.uclktx);
            test[0]<=v.tx;
          	for(int i=1;i<=8;i++)
            begin
            	@(posedge v.uclktx);
                test[i]=v.tx;
            end
          	$display("[MON] : Data sent on UART TX %0d", test[8:1]);
          	@(posedge v.uclktx);
          	if(v.txdone==1'b1)
            	$display("Txdone asserted successfully");
          	else 
              	$warning("Txdone not asserted");
          	test[9]<=v.tx;
          	mbx.put(test);
        end
      	else if((v.rx==1'b0)&&(v.tx_start==1'b0))
        begin
          	test[0]<=v.rx;
          	wait(v.rxdone==1);
          	if(v.rxdone==1'b1)
            	$display("Rxdone asserted successfully");
          	else 
            	$warning("Rxdone not asserted");
          	test[8:1]=v.data_out;
          	test[9]=1'b1;
          	$display("[MON] : Data received RX %0d ", test[8:1]);
          	@(posedge v.uclktx);
          	mbx.put(test);
        end
    end
  endtask
endclass
    
    
              
class scoreboard;
  
 transaction trd;
 transaction trm;
  
 mailbox #(bit [7:0]) mbxd;
 mailbox #(bit [9:0]) mbxm;
  
 virtual vif v;
  
 bit [7:0] ds;
 bit [9:0] ms;
  
 event sconext;
  
 function new (mailbox #(bit [7:0]) mbxd, mailbox #(bit [9:0]) mbxm);
 	this.mbxd=mbxd;
    this.mbxm=mbxm;
 endfunction 
  
 task run();
    forever 
    begin
    	mbxd.get(ds);
        mbxm.get(ms);
        $display("[SCO] : DRV : %0d MON : %0d", ds, ms[8:1]);
        if(ds==(ms[8:1]))
        	$display("Data matched");
        else
          	$display("Data mismatched");
        if((ms[9]==1'b1)&&(ms[0]==1'b0))
          	$display("[SCO] : Start and stop bits satisfy the conditions, stop = %0d, start=%0d",ms[9],ms[0]);
        else
          	$display("[SCO] : Start and stop bits do not satisfy the conditions, start = %0d, stop=%0d",ms[9],ms[0]);
        $display("*******************************************************************************************************************************************************");
        ->sconext;
      end
  endtask
endclass
                 
  
   
class environment;
  
 mailbox #(transaction) mbxgd;
 mailbox #(bit [7:0]) mbxds;
 mailbox #(bit [9:0]) mbxms;
  
 event sconext;
 event drvnext;
  
 virtual interface vif v;
  
 driver drv;
 monitor mon;
 generator gen;
 scoreboard sco;
  
 function new(virtual vif v);
    mbxgd=new();
    mbxds=new();
    mbxms=new();
    
    drv=new(mbxgd,mbxds);
    gen=new(mbxgd);
    mon=new(mbxms);
    sco=new(mbxds,mbxms);
    
    this.v=v;
    mon.v=v;
    drv.v=v;
    
    gen.sconext=sconext;
    sco.sconext=sconext;
    
    drv.drvnext=drvnext;
    gen.drvnext=drvnext;
  
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
 	$finish;    
 endtask
    
 task run();
 	pre_test();
    test();
    // post_test();
 endtask
    
endclass 
      

    
module tb;
  
 vif v1();
 vif v2();
 vif v3();

 uart_top u1(v1.clk,v1.rst,v1.rx,v1.data_in,v1.tx_start,v1.tx,v1.data_out,v1.txdone,v1.rxdone);
      
 uart_top #(100000,4800) u2(v2.clk,v2.rst,v2.rx,v2.data_in,v2.tx_start,v2.tx,v2.data_out,v2.txdone,v2.rxdone);
      
 uart_top #(100000,15200) u3(v3.clk,v3.rst,v3.rx,v3.data_in,v3.tx_start,v3.tx,v3.data_out,v3.txdone,v3.rxdone);
  
 environment env;
  
 initial v1.clk<=1'b0;
 initial v2.clk<=1'b0;
 initial v3.clk<=1'b0;
  
 always #500 v1.clk<=~v1.clk;
 always #50 v2.clk<=~v2.clk;
 always #50 v3.clk<=~v3.clk;
  
 assign v1.uclktx=u1.utx.uclk,
  		v1.uclkrx=u1.rtx.uclk;
      
 assign v2.uclktx=u2.utx.uclk,
  		v2.uclkrx=u2.rtx.uclk;
      
 assign v3.uclktx=u3.utx.uclk,
      	v3.uclkrx=u3.rtx.uclk;
  
 initial
 	begin
    	env=new(v1);
      	env.gen.count=10;
      	$display("*****************************BAUD RATE = 9600************************************");
      	$display("*********************************************************************************");
      	env.run();
      	env=new(v2);
      	env.gen.count=10;
      	$display("*****************************BAUD RATE = 4800************************************");
      	$display("*********************************************************************************");
      	env.run();
      	env=new(v3);
      	env.gen.count=10;
      	$display("*****************************BAUD RATE = 15200************************************");
      	$display("*********************************************************************************");
      	env.run();
      	wait(env.gen.done.triggered);
      	env.post_test();
    end
  
 initial 
 begin
 	$dumpfile("dump.vcd");
    $dumpvars;
 end
  
endmodule
