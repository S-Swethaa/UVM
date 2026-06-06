// // Code your design here
// //phases 

`include "uvm_macros.svh";
import uvm_pkg::*;

class seqenc extends uvm_sequence_item;
  `uvm_object_utils(seqenc)
  rand int a;
  
  function new(string name = "sequenc");
    super.new(name);
  endfunction
endclass

class sequenc extends  uvm_sequence #(seqenc);
  `uvm_object_utils(sequenc)
   function new(string name = "sequenc");
    super.new(name);
  endfunction
  task body();
    seqenc s;
    repeat(10)begin
      s= seqenc::type_id::create("s");
      start_item(s);
      assert(s.randomize());
      `uvm_info(get_type_name(),$sformatf("a=%0d",s.a),UVM_LOW)
      finish_item(s);
    end
  endtask
endclass

class sequencer extends uvm_sequencer #(seqenc);
  `uvm_component_utils(sequencer)
  
  function new(string name = "sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass
  

class driver extends uvm_driver #(seqenc);
   `uvm_component_utils(driver)
  
  function new(string name = "driver",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    seqenc s;
    forever begin
      s= seqenc::type_id::create("s");
      seq_item_port.get_next_item(s);
      `uvm_info(get_type_name(),$sformatf("a=%0d",s.a),UVM_LOW)
      seq_item_port.item_done();
    end
  endtask
endclass

class agent extends uvm_agent;

  `uvm_component_utils(agent)
   
  sequencer seqr;
  driver drv;
  function new(string name = "agent",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    seqr=sequencer::type_id::create("seqr",this);
    drv=driver::type_id::create("drv",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
  
  
  
  

class test extends uvm_test;
  `uvm_component_utils(test)
  
  function new(string name = "test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  sequenc seq;
  agent agnt;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agnt=agent::type_id::create("agnt",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
      seq=sequenc::type_id::create("seq");
    
    phase.raise_objection(this);
    seq.start(agnt.seqr);
    phase.drop_objection(this);
  endtask
endclass
            
        module test;
          initial
            begin
              run_test("test");
            end
        endmodule
# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(277) @ 0: reporter [Questa UVM] QUESTA_UVM-1.2.3
# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(278) @ 0: reporter [Questa UVM]  questa_uvm::init(+struct)
# UVM_INFO @ 0: reporter [RNTST] Running test test...
# UVM_INFO design.sv(27) @ 0: uvm_test_top.agnt.seqr@@seq [sequenc] a=-277150817
# UVM_INFO design.sv(59) @ 0: uvm_test_top.agnt.drv [driver] a=-277150817
# UVM_INFO design.sv(27) @ 0: uvm_test_top.agnt.seqr@@seq [sequenc] a=879633545
# UVM_INFO design.sv(59) @ 0: uvm_test_top.agnt.drv [driver] a=879633545
# UVM_INFO design.sv(27) @ 0: uvm_test_top.agnt.seqr@@seq [sequenc] a=726629711
# UVM_INFO design.sv(59) @ 0: uvm_test_top.agnt.drv [driver] a=726629711
# UVM_INFO design.sv(27) @ 0: uvm_test_top.agnt.seqr@@seq [sequenc] a=1072926597
# UVM_INFO design.sv(59) @ 0: uvm_test_top.agnt.drv [driver] a=1072926597
# UVM_INFO design.sv(27) @ 0: uvm_test_top.agnt.seqr@@seq [sequenc] a=705826776
# UVM_INFO design.sv(59) @ 0: uvm_test_top.agnt.drv [driver] a=705826776
# UVM_INFO design.sv(27) @ 0: uvm_test_top.agnt.seqr@@seq [sequenc] a=695008287
# UVM_INFO design.sv(59) @ 0: uvm_test_top.agnt.drv [driver] a=695008287
# UVM_INFO design.sv(27) @ 0: uvm_test_top.agnt.seqr@@seq [sequenc] a=-1422317828
# UVM_INFO design.sv(59) @ 0: uvm_test_top.agnt.drv [driver] a=-1422317828
# UVM_INFO design.sv(27) @ 0: uvm_test_top.agnt.seqr@@seq [sequenc] a=1958479769
# UVM_INFO design.sv(59) @ 0: uvm_test_top.agnt.drv [driver] a=1958479769
# UVM_INFO design.sv(27) @ 0: uvm_test_top.agnt.seqr@@seq [sequenc] a=1627627624
# UVM_INFO design.sv(59) @ 0: uvm_test_top.agnt.drv [driver] a=1627627624
# UVM_INFO design.sv(27) @ 0: uvm_test_top.agnt.seqr@@seq [sequenc] a=262047527
# UVM_INFO design.sv(59) @ 0: uvm_test_top.agnt.drv [driver] a=262047527
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_objection.svh(1270) @ 0: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_report_server.svh(847) @ 0: reporter [UVM/REPORT/SERVER] 
# --- UVM Report Summary ---
# 
# ** Report counts by severity
# UVM_INFO :   25
# UVM_WARNING :    0
# UVM_ERROR :    0
# UVM_FATAL :    0
# ** Report counts by id
# [Questa UVM]     2
# [RNTST]     1
# [TEST_DONE]     1
# [UVM/RELNOTES]     1
# [driver]    10
# [sequenc]    10
# 
# ** Note: $finish    : /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_root.svh(517)
#    Time: 0 ns  Iteration: 304  Instance: /test
# End time: 08:29:05 on Jun 06,2026, Elapsed time: 0:00:02
# Errors: 0, Warnings: 0
End time: 08:29:05 on Jun 06,2026, Elapsed time: 0:00:13
*** Summary *********************************************
