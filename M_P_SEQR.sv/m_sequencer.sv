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
      `uvm_do(seq)
      `uvm_info("sequence","automatically wait_grant,randomize,sending_trans,wait_for_grant",UVM_LOW)
      `uvm_info("SEQUENCE",$sformatf("current_Sequencer=%s",m_sequencer.get_name()),UVM_LOW)
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
# UVM_INFO testbench.sv(55) @ 0: uvm_test_top.e.agnt.drv [driver] driver dending the requenst to get next transaction
# UVM_INFO testbench.sv(58) @ 10: uvm_test_top.e.agnt.drv [driver] driver actively driveing to dut send responce to sequene
# UVM_INFO testbench.sv(27) @ 10: uvm_test_top.e.agnt.seqr@@se [sequence] automatically wait_grant,randomize,sending_trans,wait_for_grant
  
  --------------------------------------------------------------------------------------------------------------------------------------------------------
# UVM_INFO testbench.sv(28) @ 10: uvm_test_top.e.agnt.seqr@@se [SEQUENCE] current_Sequencer=seqr
 --------------------------------------------------------------------------------------------------------------------------------------------------------- 
  
# UVM_INFO testbench.sv(55) @ 10: uvm_test_top.e.agnt.drv [driver] driver dending the requenst to get next transaction
# UVM_INFO testbench.sv(58) @ 20: uvm_test_top.e.agnt.drv [driver] driver actively driveing to dut send responce to sequene
# UVM_INFO testbench.sv(27) @ 20: uvm_test_top.e.agnt.seqr@@se [sequence] automatically wait_grant,randomize,sending_trans,wait_for_grant
  
  ---------------------------------------------------------------------------------------------------------------------------------------------------------
# UVM_INFO testbench.sv(28) @ 20: uvm_test_top.e.agnt.seqr@@se [SEQUENCE] current_Sequencer=seqr
-----------------------------------------------------------------------------------------------------------------------------------------------------------
  
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_objection.svh(1270) @ 20: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_report_server.svh(847) @ 20: reporter [UVM/REPORT/SERVER] 
# --- UVM Report Summary ---
# 
# ** Report counts by severity
# UVM_INFO :   13
# UVM_WARNING :    0
# UVM_ERROR :    0
# UVM_FATAL :    0
# ** Report counts by id
# [Questa UVM]     2
# [RNTST]     1
# [SEQUENCE]     2
# [TEST_DONE]     1
# [UVM/RELNOTES]     1
# [driver]     4
# [sequence]     2
# 
# ** Note: $finish    : /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_root.svh(517)
#    Time: 20 ns  Iteration: 74  Instance: /m
# End time: 12:01:55 on Jun 09,2026, Elapsed time: 0:00:03
# Errors: 0, Warnings: 0
End time: 12:01:55 on Jun 09,2026, Elapsed time: 0:00:14
*** Summary *********************************************
