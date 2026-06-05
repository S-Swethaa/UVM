//analysis port 
/* why need analysis port to broadcast the transaction to multiple subscribers
 using in monitor to broadcast to scoreboard and coverage 
 1st create a uvm_analysis_port # (transac)ap;-> in monitor and in task write a ap.write(trans)method 
 2nd in create a subscribers class in cov and scb using uvm_analysis_imp for receiving the transaction using write call method then only the subscribers receiving the monitors transaction
 */

`include "uvm_macros.svh"
import uvm_pkg::*;

// Transaction
class transac extends uvm_sequence_item;
  rand bit [5:0] data;
  `uvm_object_utils(transac)

  function new(string name="transac");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("data=%0d", data);
  endfunction
endclass


// Monitor with analysis_port
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  uvm_analysis_port #(transac) ap;

  function new(string name="monitor", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    transac tr;
    repeat(5) begin
      tr = transac::type_id::create("tr");
      assert(tr.randomize());
      `uvm_info("MONITOR", $sformatf("Observed: %s", tr.convert2string()), UVM_MEDIUM)
      ap.write(tr); // broadcast transaction
      #5;
    end
  endtask
endclass


// Scoreboard subscriber using analysis_imp
class scoreboard extends uvm_component;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp #(transac, scoreboard) imp;

  function new(string name="scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    imp = new("imp", this);
  endfunction

  function void write(transac tr);
    `uvm_info("SCOREBOARD", $sformatf("Checking: %s", tr.convert2string()), UVM_MEDIUM)
  endfunction
endclass


// Coverage subscriber using analysis_imp
class coverage extends uvm_component;
  `uvm_component_utils(coverage)

  uvm_analysis_imp #(transac, coverage) imp;

  function new(string name="coverage", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    imp = new("imp", this);
  endfunction

  function void write(transac tr);
    `uvm_info("COVERAGE", $sformatf("Covering: %s", tr.convert2string()), UVM_MEDIUM)
  endfunction
endclass


// Environment
class envi extends uvm_env;
  `uvm_component_utils(envi)

  monitor m;
  scoreboard scb;
  coverage cov;

  function new(string name="envi", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    m   = monitor::type_id::create("m", this);
    scb = scoreboard::type_id::create("scb", this);
    cov = coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    m.ap.connect(scb.imp);
    m.ap.connect(cov.imp);
  endfunction
endclass


// Test
class test extends uvm_test;
  `uvm_component_utils(test)

  envi en;

  function new(string name="test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    en = envi::type_id::create("en", this);
  endfunction
endclass


// Top module
module m;
  initial begin
    run_test("test");
  end
endmodule

# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(277) @ 0: reporter [Questa UVM] QUESTA_UVM-1.2.3
# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(278) @ 0: reporter [Questa UVM]  questa_uvm::init(+struct)
# UVM_INFO @ 0: reporter [RNTST] Running test test...
# UVM_INFO design.sv(174) @ 0: uvm_test_top.en.m [MONITOR] Observed: data=24
# UVM_INFO design.sv(217) @ 0: uvm_test_top.en.cov [COVERAGE] Covering: data=24
# UVM_INFO design.sv(197) @ 0: uvm_test_top.en.scb [SCOREBOARD] Checking: data=24
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_report_server.svh(847) @ 0: reporter [UVM/REPORT/SERVER] 
# --- UVM Report Summary ---
# 
# ** Report counts by severity
# UVM_INFO :    7
# UVM_WARNING :    0
# UVM_ERROR :    0
# UVM_FATAL :    0
# ** Report counts by id
# [COVERAGE]     1
# [MONITOR]     1
# [Questa UVM]     2
# [RNTST]     1
# [SCOREBOARD]     1
# [UVM/RELNOTES]     1
# 
# ** Note: $finish    : /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_root.svh(517)
#    Time: 0 ns  Iteration: 269  Instance: /m
# End time: 04:14:59 on Jun 05,2026, Elapsed time: 0:00:03
# Errors: 0, Warnings: 0
End time: 04:14:59 on Jun 05,2026, Elapsed time: 0:00:17
*** Summary *********************************************
