// Code your design here
`include "uvm_macros.svh"
import uvm_pkg::*;

class transac extends uvm_sequence_item;
  rand bit [7:0]data;
  
  `uvm_object_utils(transac)
  
  function new(string name = "transac");
    super.new(name);
  endfunction
  
  function string convert2string();
    return $sformatf("DATA=%0d",data);
  endfunction
endclass

class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  uvm_blocking_put_port #(transac)put_port;
  function new(string name = "producer",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    put_port=new("put_port",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    transac trans;
    repeat(5)begin
      trans=transac::type_id::create("trans");
      assert(trans.randomize());
      `uvm_info("producer",$sformatf("send=%s",trans.convert2string()),UVM_MEDIUM)
      put_port.put(trans);
    end
  endtask
endclass

class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  uvm_blocking_get_port #(transac)get_port;
  
  function new(string name = "consumer",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    get_port=new("get_port",this);
  endfunction
  
  task run_phase (uvm_phase phase);
    transac trans;
    forever begin
      get_port.get(trans);
      `uvm_info("consumer",$sformatf("received:%s",trans.convert2string()),UVM_MEDIUM)
    end
  endtask
endclass

class environ extends uvm_env;
  producer p;
  consumer c;
  uvm_tlm_fifo #(transac)fifo;
  `uvm_component_utils(environ)
  
  function new(string name = "environ",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p=producer::type_id::create("p",this);
    c=consumer::type_id::create("c",this);
    fifo=new("fifo",this,10);//fifo depth = 10;
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    p.put_port.connect(fifo.put_export);
    c.get_port.connect(fifo.get_export);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  
  environ env;
  function new(string name = "test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=environ::type_id::create("env",this);
  endfunction
  
endclass

module m;
  initial
    begin
      run_test("test");
    end
endmodule
    # 
# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(277) @ 0: reporter [Questa UVM] QUESTA_UVM-1.2.3
# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(278) @ 0: reporter [Questa UVM]  questa_uvm::init(+struct)
# UVM_INFO @ 0: reporter [RNTST] Running test test...
# UVM_INFO design.sv(37) @ 0: uvm_test_top.env.p [producer] send=DATA=184
# UVM_INFO design.sv(37) @ 0: uvm_test_top.env.p [producer] send=DATA=165
# UVM_INFO design.sv(37) @ 0: uvm_test_top.env.p [producer] send=DATA=56
# UVM_INFO design.sv(37) @ 0: uvm_test_top.env.p [producer] send=DATA=50
# UVM_INFO design.sv(37) @ 0: uvm_test_top.env.p [producer] send=DATA=179
# UVM_INFO design.sv(60) @ 0: uvm_test_top.env.c [consumer] received:DATA=184
# UVM_INFO design.sv(60) @ 0: uvm_test_top.env.c [consumer] received:DATA=165
# UVM_INFO design.sv(60) @ 0: uvm_test_top.env.c [consumer] received:DATA=56
# UVM_INFO design.sv(60) @ 0: uvm_test_top.env.c [consumer] received:DATA=50
# UVM_INFO design.sv(60) @ 0: uvm_test_top.env.c [consumer] received:DATA=179
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_report_server.svh(847) @ 0: reporter [UVM/REPORT/SERVER] 
# --- UVM Report Summary ---
# 
# ** Report counts by severity
# UVM_INFO :   14
# UVM_WARNING :    0
# UVM_ERROR :    0
# UVM_FATAL :    0
# ** Report counts by id
# [Questa UVM]     2
# [RNTST]     1
# [UVM/RELNOTES]     1
# [consumer]     5
# [producer]     5
# 
# ** Note: $finish    : /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_root.svh(517)
#    Time: 0 ns  Iteration: 269  Instance: /m
# End time: 01:57:56 on Jun 05,2026, Elapsed time: 0:00:03
# Errors: 0, Warnings: 0
End time: 01:57:56 on Jun 05,2026, Elapsed time: 0:00:13
*** Summary *********************************************
    qrun: Errors:   0, Warnings:   0
    vlog: Errors:   0, Warnings:   0
    vopt: Errors:   0, Warnings:   1
    vsim: Errors:   0, Warnings:   0
  Totals: Errors:   0, Warnings:   1
