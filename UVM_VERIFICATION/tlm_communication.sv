/* uvm_tlm_analysis fifo which is used to broadcast the transaction to multiple subscribers .
uvm_tlm_analysis port extends uvm_tlm_fifo which extra adds unbounded fifo + analysis export
as well same as monitor write using analysis port and write write method
in sscoreboard write uvm_tlm_analysis_fifo 
and create the object for thet port and connect the port to analysis port+uvm_tlm_analysis_fifo port
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

  uvm_tlm_analysis_fifo #(transac)fifo;

  function new(string name="scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    fifo = new("fifo", this);
  endfunction

  
  task run_phase(uvm_phase phase);
    transac tr;
    forever begin
      fifo.get(tr);
      `uvm_info("SCOREBOARD", $sformatf("Checking: %s", tr.convert2string()), UVM_MEDIUM)
    end
  endtask
endclass

// Environment
class envi extends uvm_env;
  `uvm_component_utils(envi)

  monitor m;
  scoreboard scb;
  function new(string name="envi", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    m   = monitor::type_id::create("m", this);
    scb = scoreboard::type_id::create("scb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    m.ap.connect(scb.fifo.analysis_export);
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

# 
# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(277) @ 0: reporter [Questa UVM] QUESTA_UVM-1.2.3
# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(278) @ 0: reporter [Questa UVM]  questa_uvm::init(+struct)
# UVM_INFO @ 0: reporter [RNTST] Running test test...
# UVM_INFO design.sv(174) @ 0: uvm_test_top.en.m [MONITOR] Observed: data=24
# UVM_INFO design.sv(201) @ 0: uvm_test_top.en.scb [SCOREBOARD] Checking: data=24
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_report_server.svh(847) @ 0: reporter [UVM/REPORT/SERVER] 
# --- UVM Report Summary ---
# 
# ** Report counts by severity
# UVM_INFO :    6
# UVM_WARNING :    0
# UVM_ERROR :    0
# UVM_FATAL :    0
# ** Report counts by id
# [MONITOR]     1
# [Questa UVM]     2
# [RNTST]     1
# [SCOREBOARD]     1
# [UVM/RELNOTES]     1
# 
# ** Note: $finish    : /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_root.svh(517)
#    Time: 0 ns  Iteration: 269  Instance: /m
# End time: 04:51:11 on Jun 05,2026, Elapsed time: 0:00:02

    
      
    
    
    
  
