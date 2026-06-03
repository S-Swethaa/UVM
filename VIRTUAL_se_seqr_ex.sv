`include "uvm_macros.svh"
import uvm_pkg::*;

typedef class sequencer_1;
typedef class sequencer_2;
typedef class vir_sequencer;

class seq_item extends uvm_sequence_item;
  rand int d1,d2;
  `uvm_object_utils(seq_item)
  function new(string name="seq_item");
    super.new(name);
  endfunction
endclass

class sequenc_1 extends uvm_sequence #(seq_item);
  `uvm_object_utils(sequenc_1)
  seq_item req;
  function new(string name="sequenc_1");
    super.new(name);
  endfunction
  task body();
    req=seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize());
    finish_item(req);
  endtask
endclass

class sequenc_2 extends uvm_sequence #(seq_item);
  `uvm_object_utils(sequenc_2)
  seq_item req;
  function new(string name="sequenc_2");
    super.new(name);
  endfunction
  task body();
    req=seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize());
    finish_item(req);
  endtask
endclass

class sequencer_1 extends uvm_sequencer #(seq_item);
  `uvm_component_utils(sequencer_1)
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
endclass

class sequencer_2 extends uvm_sequencer #(seq_item);
  `uvm_component_utils(sequencer_2)
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
endclass

class vir_sequencer extends uvm_sequencer #(uvm_sequence_item);
  `uvm_component_utils(vir_sequencer)
  sequencer_1 seqr_1;
  sequencer_2 seqr_2;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
endclass

class virtual_sequenc extends uvm_sequence;
  `uvm_object_utils(virtual_sequenc)
  `uvm_declare_p_sequencer(vir_sequencer)
  sequenc_1 seq1;
  sequenc_2 seq2;
  function new(string name="virtual_sequenc");
    super.new(name);
  endfunction
  task body();
    seq1=sequenc_1::type_id::create("seq1");
    seq2=sequenc_2::type_id::create("seq2");
    fork
      seq1.start(p_sequencer.seqr_1);
      seq2.start(p_sequencer.seqr_2);
    join
  endtask
endclass

class driver extends uvm_driver #(seq_item);
  `uvm_component_utils(driver)
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  task run_phase(uvm_phase phase);
    seq_item req;
    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask
  virtual task drive(seq_item req);
    `uvm_info(get_type_name(),$sformatf("d1=%0d d2=%0d",req.d1,req.d2),UVM_LOW)
    #10;
  endtask
endclass

class driver1 extends driver;
  `uvm_component_utils(driver1)
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  task drive(seq_item req);
    `uvm_info(get_type_name(),"Driver1 Driving",UVM_LOW)
    #10;
  endtask
endclass

class driver2 extends driver;
  `uvm_component_utils(driver2)
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  task drive(seq_item req);
    `uvm_info(get_type_name(),"Driver2 Driving",UVM_LOW)
    #10;
  endtask
endclass

class agent1 extends uvm_agent;
  `uvm_component_utils(agent1)
  driver1 drv1;
  sequencer_1 seqr_1;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv1=driver1::type_id::create("drv1",this);
    seqr_1=sequencer_1::type_id::create("seqr_1",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    drv1.seq_item_port.connect(seqr_1.seq_item_export);
  endfunction
endclass

class agent2 extends uvm_agent;
  `uvm_component_utils(agent2)
  driver2 drv2;
  sequencer_2 seqr_2;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv2=driver2::type_id::create("drv2",this);
    seqr_2=sequencer_2::type_id::create("seqr_2",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    drv2.seq_item_port.connect(seqr_2.seq_item_export);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  vir_sequencer v_seqr;
  agent1 agnt1;
  agent2 agnt2;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    v_seqr=vir_sequencer::type_id::create("v_seqr",this);
    agnt1=agent1::type_id::create("agnt1",this);
    agnt2=agent2::type_id::create("agnt2",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    v_seqr.seqr_1=agnt1.seqr_1;
    v_seqr.seqr_2=agnt2.seqr_2;
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  env en;
  virtual_sequenc vseq;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    en=env::type_id::create("en",this);
  endfunction
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    vseq=virtual_sequenc::type_id::create("vseq");
    vseq.start(en.v_seqr);
    #20;
    phase.drop_objection(this);
  endtask
endclass

module top;
  initial run_test("test");
endmodule
# 
# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(277) @ 0: reporter [Questa UVM] QUESTA_UVM-1.2.3
# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(278) @ 0: reporter [Questa UVM]  questa_uvm::init(+struct)
# UVM_INFO @ 0: reporter [RNTST] Running test test...
# UVM_INFO testbench.sv(110) @ 0: uvm_test_top.en.agnt1.drv1 [driver1] Driver1 Driving
# UVM_INFO testbench.sv(121) @ 0: uvm_test_top.en.agnt2.drv2 [driver2] Driver2 Driving
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_objection.svh(1270) @ 30: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_report_server.svh(847) @ 30: reporter [UVM/REPORT/SERVER] 
# --- UVM Report Summary ---
# 
# ** Report counts by severity
# UVM_INFO :    7
# UVM_WARNING :    0
# UVM_ERROR :    0
# UVM_FATAL :    0
# ** Report counts by id
# [Questa UVM]     2
# [RNTST]     1
# [TEST_DONE]     1
# [UVM/RELNOTES]     1
# [driver1]     1
# [driver2]     1
