// Code your design here
module or_gate(
  input wire [3:0]a,b,
  output [3:0]y);
  
  assign y=a|b;
endmodule

// No includes — this file is pulled in by testbench.sv
interface intf(input logic clk);
  logic [3:0] a;
  logic [3:0] b;
  logic [3:0] y;
endinterface

// No includes — compiled as part of testbench.sv include chain
class seq_item extends uvm_sequence_item;
  `uvm_object_utils(seq_item);

  rand bit [3:0] a, b;
  bit [3:0] y;

  function new(string name = "seq_item");
    super.new(name);
  endfunction

endclass

class or_sequence extends uvm_sequence #(seq_item);
  `uvm_object_utils(or_sequence)

  function new(string name="or_sequence");
    super.new(name);
  endfunction

  task body();
    seq_item trans;
    repeat(15) begin
      trans = seq_item::type_id::create("trans");
      start_item(trans);
      if (!trans.randomize())
        `uvm_fatal("SEQ", "Randomize failed")
      finish_item(trans);
    end
  endtask
endclass

// No includes — compiled as part of testbench.sv include chain
class sequencer extends uvm_sequencer #(seq_item);
  `uvm_component_utils(sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
// No includes — compiled as part of testbench.sv include chain
class driver extends uvm_driver #(seq_item);
  `uvm_component_utils(driver)

  virtual intf vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual intf)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "No virtual interface found for driver")
  endfunction

      function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    vif.a<=0;
    vif.b<=0;
    `uvm_info(" SOS DRIVER","intial values are reset in intial state ",UVM_LOW)
  endfunction
    
  task run_phase(uvm_phase phase);
    seq_item trans;  // declaration BEFORE the forever loop
    forever begin
      seq_item_port.get_next_item(trans);
      @(posedge vif.clk);   // must use vif.clk, not bare 'clk'
      vif.a <= trans.a;
      vif.b <= trans.b;
//       @(posedge vif.clk);
//       trans.y = vif.y;
      seq_item_port.item_done();
    end
  endtask

endclass

class extend_driver extends driver;
  `uvm_component_utils(extend_driver)
  
  function new(string name = "extend_driver",uvm_component parent );
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual intf)::get(this, "", "vif", vif))
      `uvm_fatal("EXTEND_DRV", "No virtual interface found for EXTEND_driver")
  endfunction
      
       task run_phase(uvm_phase phase);
    seq_item trans;  // declaration BEFORE the forever loop
    forever begin
      seq_item_port.get_next_item(trans);
      @(posedge vif.clk);   // must use vif.clk, not bare 'clk'
      vif.a <= trans.a;
      vif.b <= trans.b;
//       @(posedge vif.clk);
//       trans.y = vif.y;
      seq_item_port.item_done();
    end
  endtask
    endclass
  
// No includes — compiled as part of testbench.sv include chain
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual intf vif;
  uvm_analysis_port #(seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual intf)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "No virtual interface found for monitor")
  endfunction

//   task run_phase(uvm_phase phase);
//     seq_item trans;  // declaration BEFORE the forever loop
//     forever begin
//       trans = seq_item::type_id::create("trans");
//       @(posedge vif.clk);
//       trans.a = vif.a;
//       trans.b = vif.b;
//       @(posedge vif.clk);
//       trans.y = vif.y;
//       ap.write(trans);
//     end
//   endtask
      
      task run_phase(uvm_phase phase);
  seq_item trans;

  forever begin
    trans = seq_item::type_id::create("trans");

    @(posedge vif.clk);
    
    #1;
    trans.a = vif.a;
    trans.b = vif.b;
    trans.y = vif.y;

    ap.write(trans);
  end
endtask

endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  sequencer seqr;
  driver    drv;
  monitor   mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = sequencer::type_id::create("seqr", this);
    drv  = driver::type_id::create("drv",  this);
    mon  = monitor::type_id::create("mon",  this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass

// No includes here — all dependencies included via agent.sv -> environment.sv chain
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp #(seq_item, scoreboard) ap_imp;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap_imp = new("ap_imp", this);
  endfunction

  function void write(seq_item trans);
    if ((trans.a | trans.b) == trans.y)
      `uvm_info("SB", $sformatf("PASS: a=%0d, b=%0d, y=%0d", trans.a, trans.b, trans.y), UVM_LOW)
    else
      `uvm_error("SB", $sformatf("FAIL: a=%0d, b=%0d, y=%0d", trans.a, trans.b, trans.y))
  endfunction

endclass


// `include "scoreboard.sv"
// `include "agent.sv"
class environment extends uvm_env;
  `uvm_component_utils(environment)

  agent agnt;
  scoreboard scb;
  int log_fd;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agnt = agent::type_id::create("agnt", this);
    scb = scoreboard::type_id::create("scb", this);
  endfunction
  
   virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    `uvm_info("EOE_TOPO", "==== UVM TOPOLOGY START ====", UVM_NONE)
    
    uvm_top.print_topology();

    `uvm_info("EOE_TOPO", "==== UVM TOPOLOGY END ====", UVM_NONE)
     
     log_fd=$open("env_log.txt","w");
     if(log_fd==0)
      `uvm_error("EOE","File open failed for env_log.txt")
       else
       `uvm_info("EOE","file opened successfully",UVM_NONE)
       
       set_report_default_file(log_fd);
     set_report_severity_action(UVM_INFO,UVM_DISPLAY|UVM_LOG);
         uvm_config_db#(int)::set(this,"*","monitor_delay",1);    
     
  endfunction
  
  function void connect_phase(uvm_phase phase);
    agnt.mon.ap.connect(scb.ap_imp);
  endfunction

endclass

// `include "environment.sv"
// `include "sequence.sv"

// `include "environment.sv"
// `include "sequence.sv"

class test extends uvm_test;
  `uvm_component_utils(test)

  environment env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_factory::get().set_type_override_by_type(
      driver::get_type(),
      extend_driver::get_type(),"env.agnt.drv"
    );
    `uvm_info("test","factory override successfully done by instance_type_override_by_type", UVM_LOW)

    uvm_factory::get().set_type_override_by_name(
      "driver",
      "extend_driver","env.agnt.drv"
    );
    `uvm_info("test","factory override successfully done by instance_type_override_by_name", UVM_LOW)

    env = environment::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    or_sequence seq;
    phase.raise_objection(this);

    seq = or_sequence::type_id::create("seq");
    seq.start(env.agnt.seqr);

    phase.drop_objection(this);
  endtask
endclass


`include "uvm_macros.svh"
import uvm_pkg::*;

// Include all UVM files in dependency order
// (design.sv is compiled separately as a Design file in EDA Playground)
`include "interface.sv"
`include "seq_item.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "sequence.sv"
`include "test.sv"

module testbench;
  bit clk;
  intf vif(clk);

  initial clk = 0;
  always #5 clk = ~clk;

  or_gate dut (
    .a(vif.a),
    .b(vif.b),
    .y(vif.y)
  );

  initial begin
    uvm_config_db #(virtual intf)::set(null, "*", "vif", vif);
    run_test("test");
  end

endmodule


  # UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(277) @ 0: reporter [Questa UVM] QUESTA_UVM-1.2.3
# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(278) @ 0: reporter [Questa UVM]  questa_uvm::init(+struct)
# UVM_INFO @ 0: reporter [RNTST] Running test test...
# UVM_INFO test.sv(20) @ 0: uvm_test_top [test] factory override successfully done by instance_type_override_by_type
# UVM_INFO @ 0: reporter [TPREGD] Original type 'driver' already registered to produce 'extend_driver'.  Set 'replace' argument to replace the existing entry.
# UVM_INFO test.sv(26) @ 0: uvm_test_top [test] factory override successfully done by instance_type_override_by_name
# UVM_INFO environment.sv(24) @ 0: uvm_test_top.env [EOE_TOPO] ==== UVM TOPOLOGY START ====
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_root.svh(579) @ 0: reporter [UVMTOP] UVM testbench topology:
# --------------------------------------------------------------
# Name                       Type                    Size  Value
# --------------------------------------------------------------
# uvm_test_top               test                    -     @360 
#   env                      environment             -     @378 
#     agnt                   agent                   -     @386 
#       drv                  extend_driver           -     @526 
#         rsp_port           uvm_analysis_port       -     @543 
#         seq_item_port      uvm_seq_item_pull_port  -     @534 
#       mon                  monitor                 -     @552 
#         ap                 uvm_analysis_port       -     @562 
#       seqr                 sequencer               -     @403 
#         rsp_export         uvm_analysis_export     -     @411 
#         seq_item_export    uvm_seq_item_pull_imp   -     @517 
#         arbitration_queue  array                   0     -    
#         lock_queue         array                   0     -    
#         num_last_reqs      integral                32    'd1  
#         num_last_rsps      integral                32    'd1  
#     scb                    scoreboard              -     @394 
#       ap_imp               uvm_analysis_imp        -     @577 
# --------------------------------------------------------------
# 
# UVM_INFO environment.sv(28) @ 0: uvm_test_top.env [EOE_TOPO] ==== UVM TOPOLOGY END ====
# ** Error (suppressible): (vsim-12023) Cannot execute undefined system task/function '$open'
#    Time: 0 ns  Iteration: 30  Process: /uvm_pkg::uvm_phase::m_run_phases/#FORK#2213_7f68a43e85c File: environment.sv Line: 30
# UVM_ERROR environment.sv(32) @ 0: uvm_test_top.env [EOE] File open failed for env_log.txt
# UVM_INFO driver.sv(21) @ 0: uvm_test_top.env.agnt.drv [ SOS DRIVER] intial values are reset in intial state 
# UVM_INFO scoreboard.sv(18) @ 6: uvm_test_top.env.scb [SB] PASS: a=11, b=12, y=15
# UVM_INFO scoreboard.sv(18) @ 16: uvm_test_top.env.scb [SB] PASS: a=4, b=11, y=15
# UVM_INFO scoreboard.sv(18) @ 26: uvm_test_top.env.scb [SB] PASS: a=9, b=9, y=9
# UVM_INFO scoreboard.sv(18) @ 36: uvm_test_top.env.scb [SB] PASS: a=2, b=11, y=11
# UVM_INFO scoreboard.sv(18) @ 46: uvm_test_top.env.scb [SB] PASS: a=6, b=1, y=7
# UVM_INFO scoreboard.sv(18) @ 56: uvm_test_top.env.scb [SB] PASS: a=8, b=11, y=11
# UVM_INFO scoreboard.sv(18) @ 66: uvm_test_top.env.scb [SB] PASS: a=12, b=9, y=13
# UVM_INFO scoreboard.sv(18) @ 76: uvm_test_top.env.scb [SB] PASS: a=15, b=0, y=15
# UVM_INFO scoreboard.sv(18) @ 86: uvm_test_top.env.scb [SB] PASS: a=4, b=9, y=13
# UVM_INFO scoreboard.sv(18) @ 96: uvm_test_top.env.scb [SB] PASS: a=11, b=1, y=11
# UVM_INFO scoreboard.sv(18) @ 106: uvm_test_top.env.scb [SB] PASS: a=2, b=13, y=15
# UVM_INFO scoreboard.sv(18) @ 116: uvm_test_top.env.scb [SB] PASS: a=4, b=4, y=4
# UVM_INFO scoreboard.sv(18) @ 126: uvm_test_top.env.scb [SB] PASS: a=14, b=11, y=15
# UVM_INFO scoreboard.sv(18) @ 136: uvm_test_top.env.scb [SB] PASS: a=5, b=12, y=13
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_objection.svh(1270) @ 145: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_report_server.svh(847) @ 145: reporter [UVM/REPORT/SERVER] 
# --- UVM Report Summary ---
# 
# ** Report counts by severity
# UVM_INFO :   26
# UVM_WARNING :    0
# UVM_ERROR :    1
# UVM_FATAL :    0
# ** Report counts by id
# [ SOS DRIVER]     1
# [EOE]     1
# [EOE_TOPO]     2
# [Questa UVM]     2
# [RNTST]     1
# [SB]    14
# [TEST_DONE]     1
# [TPREGD]     1
# [UVM/RELNOTES]     1
# [UVMTOP]     1
# [test]     2
# 
# ** Note: $finish    : /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_root.svh(517)
#    Time: 145 ns  Iteration: 75  Instance: /testbench
# End time: 13:55:14 on Jun 10,2026, Elapsed time: 0:00:03
# Errors: 1, Warnings: 1
End time: 13:55:14 on Jun 10,2026, Elapsed time: 0:00:17
*** Summary *********************************************
    qrun: Errors:   0, Warnings:   0
    vlog: Errors:   0, Warnings:   0
    vopt: Errors:   0, Warnings:   1
    vsim: Errors:   1, Warnings:   1
