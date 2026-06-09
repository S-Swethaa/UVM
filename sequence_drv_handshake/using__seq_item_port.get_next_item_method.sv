`include "uvm_macros.svh"
import uvm_pkg::*;

class sequence_item extends uvm_sequence_item;
  `uvm_object_utils(sequence_item)
  
  rand int a;
  
  function new(string name = "sequence_item");
    super.new(name);
  endfunction
  
endclass

class sequenc extends uvm_sequence #(sequence_item);
  `uvm_object_utils(sequenc)
  
  function new(string name = "sequenc");
    super.new(name);
  endfunction
  
  virtual task body();
    sequence_item seq;
    repeat (2) begin
      seq=sequence_item::type_id::create("seq");
      `uvm_info("sequence","sequence_item object is created",UVM_LOW)
      wait_for_grant();
      `uvm_info("sequence","sequence is wait for the grant",UVM_LOW)
      seq.randomize();
      `uvm_info("sequence","randomization successful",UVM_LOW)
      send_request(seq);
      `uvm_info("sequence","sending the transaction to driver",UVM_LOW)
      wait_for_item_done();
      `uvm_info("sequence","it wait for the item done from driver via seqr",UVM_LOW)
      get_response(seq);
      
      `uvm_info("sequence","acknowledgement is received from driver",UVM_LOW)
    end
  endtask
endclass

class sequencer extends uvm_sequencer #(sequence_item);
  `uvm_component_utils(sequencer)
  
  function new(string name = "sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass

class driver extends uvm_driver #(sequence_item);
  `uvm_component_utils(driver)
  
  sequence_item seq;
  
  function new(string name = "driver",uvm_component parent);
    super.new(name , parent);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    seq=sequence_item::type_id::create("seq");
    forever begin
      seq_item_port.get_next_item(seq);
      `uvm_info("driver","driver dending the requenst to get next transaction",UVM_LOW)
      #10;
      seq_item_port.item_done(seq);
      `uvm_info("driver","driver actively driveing to dut send responce to sequene",UVM_LOW)
    end
  endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  driver drv;
  sequencer seqr;
  
  function new(string name = "agent",uvm_component parent);
    super.new(name , parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv=driver::type_id::create("drv",this);
    seqr=sequencer::type_id::create("seqr",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  
 agent agnt;
  
  function new(string name = "env",uvm_component parent);
    super.new(name , parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agnt=agent::type_id::create("agnt",this);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  
  env e;
  sequenc se;
  
  function new(string name = "test",uvm_component parent);
    super.new(name , parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e=env::type_id::create("e",this);
    se=sequenc::type_id::create("se");
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    se.start(e.agnt.seqr);
    phase.drop_objection(this);
  endtask
endclass

module m;
  initial
    begin
      run_test("test");
    end
  endmodule

# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(277) @ 0: reporter [Questa UVM] QUESTA_UVM-1.2.3
# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(278) @ 0: reporter [Questa UVM]  questa_uvm::init(+struct)
# UVM_INFO @ 0: reporter [RNTST] Running test test...
# UVM_INFO testbench.sv(26) @ 0: uvm_test_top.e.agnt.seqr@@se [sequence] sequence_item object is created
# UVM_INFO testbench.sv(28) @ 0: uvm_test_top.e.agnt.seqr@@se [sequence] sequence is wait for the grant
# UVM_INFO testbench.sv(30) @ 0: uvm_test_top.e.agnt.seqr@@se [sequence] randomization successful
# UVM_INFO testbench.sv(32) @ 0: uvm_test_top.e.agnt.seqr@@se [sequence] sending the transaction to driver
# UVM_INFO testbench.sv(64) @ 0: uvm_test_top.e.agnt.drv [driver] driver dending the requenst to get next transaction
# UVM_INFO testbench.sv(67) @ 10: uvm_test_top.e.agnt.drv [driver] driver actively driveing to dut send responce to sequene
# UVM_INFO testbench.sv(34) @ 10: uvm_test_top.e.agnt.seqr@@se [sequence] it wait for the item done from driver via seqr
# UVM_INFO testbench.sv(37) @ 10: uvm_test_top.e.agnt.seqr@@se [sequence] acknowledgement is received from driver
# UVM_INFO testbench.sv(26) @ 10: uvm_test_top.e.agnt.seqr@@se [sequence] sequence_item object is created
# UVM_INFO testbench.sv(28) @ 10: uvm_test_top.e.agnt.seqr@@se [sequence] sequence is wait for the grant
# UVM_INFO testbench.sv(30) @ 10: uvm_test_top.e.agnt.seqr@@se [sequence] randomization successful
# UVM_INFO testbench.sv(32) @ 10: uvm_test_top.e.agnt.seqr@@se [sequence] sending the transaction to driver
# UVM_INFO testbench.sv(64) @ 10: uvm_test_top.e.agnt.drv [driver] driver dending the requenst to get next transaction
# UVM_INFO testbench.sv(67) @ 20: uvm_test_top.e.agnt.drv [driver] driver actively driveing to dut send responce to sequene
# UVM_INFO testbench.sv(34) @ 20: uvm_test_top.e.agnt.seqr@@se [sequence] it wait for the item done from driver via seqr
# UVM_INFO testbench.sv(37) @ 20: uvm_test_top.e.agnt.seqr@@se [sequence] acknowledgement is received from driver
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_objection.svh(1270) @ 20: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_report_server.svh(847) @ 20: reporter [UVM/REPORT/SERVER] 
# --- UVM Report Summary ---
# 
# ** Report counts by severity
# UVM_INFO :   21
# UVM_WARNING :    0
# UVM_ERROR :    0
# UVM_FATAL :    0
# ** Report counts by id
# [Questa UVM]     2
# [RNTST]     1
# [TEST_DONE]     1
# [UVM/RELNOTES]     1
# [driver]     4
# [sequence]    12
# 
# ** Note: $finish    : /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_root.svh(517)
#    Time: 20 ns  Iteration: 74  Instance: /m
# End time: 23:38:53 on Jun 08,2026, Elapsed time: 0:00:02
# Errors: 0, Warnings: 0
End time: 23:38:53 on Jun 08,2026, Elapsed time: 0:00:13
*** Summary *********************************************
    qrun: Errors:   0, Warnings:   0
    vlog: Errors:   0, Warnings:   1
    vopt: Errors:   0, Warnings:   2
    
  
      

      
