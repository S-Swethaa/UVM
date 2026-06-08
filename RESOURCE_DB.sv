/*UVM_resource_db which is used to passing the arguments(datatypes) all uvm_components working different testbenches
uvm_resource db global level set the configuration values with no hierachy,it is a container
there are different methods of resource db is there 
uvm_get_type - which is used to return the resource handle(object),then read gives the values
uvm_get_name - which is also gives the return the resource handle (object)
set - which is used to create  the values later we can override if needed
  set_default - whic is used to default set later we can update it
  set_anonymous - which is used to  bit resource created  with value 1
  read_by_name / read_by_type - we can directly fetch the values
  dump - prints all resource for debug*/

`include "uvm_macros.svh"
import uvm_pkg::*;

module or_gate(
  input wire [3:0]a,b,
  output [3:0]y);
  
  assign y=a|b;
endmodule

interface intf(input logic clk);
  logic [3:0] a;
  logic [3:0] b;
  logic [3:0] y;
endinterface

class seq_item extends uvm_sequence_item;
  `uvm_object_utils(seq_item);

  rand bit [3:0] a, b;
  bit [3:0] y;

  function new(string name = "seq_item");
    super.new(name);
  endfunction
  
 function string convert2string();
    return $sformatf("a=%0d, b=%0d, y=%0d", a, b, y);
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

      function void start_of_simulation_phase(uvm_phase phase);//start of simulation phase we need to start the simulation before we need to initialize the values
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
  scb  = scoreboard::type_id::create("scb", this);

  uvm_resource_db#(int)::set("env_scope","datawidth",4,this);
  uvm_resource_db#(bit)::set("env_scope","reset_initial",0,this);

  uvm_resource_db#(int)::dump();
  uvm_resource_db#(bit)::dump();
endfunction
  
   virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    `uvm_info("EOE_TOPO", "==== UVM TOPOLOGY START ====", UVM_NONE)
    
    uvm_top.print_topology();

    `uvm_info("EOE_TOPO", "==== UVM TOPOLOGY END ====", UVM_NONE)
     
log_fd = $fopen("./env_log.txt","w");
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
  


task run_phase(uvm_phase phase);
  int datawidth;
  bit reset_initial;
  uvm_resource#(int) r_int;
  uvm_resource#(bit) r_bit;

  r_int = uvm_resource#(int)::get_by_name("env_scope", "datawidth", 0);
  r_bit = uvm_resource#(bit)::get_by_name("env_scope", "reset_initial", 0);

  if (r_int != null) datawidth     = r_int.read(this);
  if (r_bit != null) reset_initial = r_bit.read(this);

  `uvm_info("uvm_resource",
            $sformatf("datawidth=%0d | reset_initial=%0b", datawidth, reset_initial),
            UVM_LOW)
endtask



endclass

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
    env = environment::type_id::create("env", this);
  endfunction

  task pre_reset_phase(uvm_phase phase);
    `uvm_info("PRE_RESET",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)
  endtask

  task reset_phase(uvm_phase phase);
    `uvm_info("RESET",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)
  endtask

  task post_reset_phase(uvm_phase phase);
    `uvm_info("POST_RESET",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)
  endtask

  task pre_configure_phase(uvm_phase phase);
    `uvm_info("PRE_CONFIGURE",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)
  endtask

  task configure_phase(uvm_phase phase);
    `uvm_info("CONFIGURE",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)
  endtask

  task post_configure_phase(uvm_phase phase);
    `uvm_info("POST_CONFIGURE",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)
  endtask

  task pre_main_phase(uvm_phase phase);
    `uvm_info("PRE_MAIN",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)
  endtask

  task main_phase(uvm_phase phase);
    `uvm_info("MAIN",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)
  endtask

  task post_main_phase(uvm_phase phase);
    `uvm_info("POST_MAIN",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)
  endtask

  task pre_shutdown_phase(uvm_phase phase);
    `uvm_info("PRE_SHUTDOWN",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)
  endtask

  task shutdown_phase(uvm_phase phase);
    `uvm_info("SHUTDOWN",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)
  endtask

  task post_shutdown_phase(uvm_phase phase);
    `uvm_info("POST_SHUTDOWN",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)
  endtask

  task run_phase(uvm_phase phase);
    or_sequence seq;
    phase.raise_objection(this);

    seq = or_sequence::type_id::create("seq");
    seq.start(env.agnt.seqr);

    `uvm_info("RUN_PHASE",
              $sformatf("Type=%s, FullName=%s",
                        get_type_name(), get_full_name()),
              UVM_LOW)

    phase.drop_objection(this);
  endtask

endclass



// `include "interface.sv"
// `include "seq_item.sv"
// `include "sequencer.sv"
// `include "driver.sv"
// `include "monitor.sv"
// `include "agent.sv"
// `include "scoreboard.sv"
// `include "environment.sv"
// `include "sequence.sv"
// `include "test.sv"

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

    *******************************************************************************************************************************************************
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_resource.svh(1347) @ 0: reporter [UVM/RESOURCE/DUMP] 
# === resource pool ===
#  datawidth [/^env_scope$/] : (int) 4   
#  recording_detail [] : (reg signed[4095:0]) 0   
#  recording_detail [] : (int) 0   
#  reset_initial [/^env_scope$/] : (bit) 0   
#  vif [/^.*$/] : (virtual intf) /testbench/vif   
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_resource.svh(1354) @ 0: reporter [UVM/RESOURCE/DUMP] === end of resource pool ===
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_resource.svh(1347) @ 0: reporter [UVM/RESOURCE/DUMP] 
# === resource pool ===
#  datawidth [/^env_scope$/] : (int) 4   
#  recording_detail [] : (reg signed[4095:0]) 0   
#  recording_detail [] : (int) 0   
#  reset_initial [/^env_scope$/] : (bit) 0   
#  vif [/^.*$/] : (virtual intf) /testbench/vif   
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_resource.svh(1354) @ 0: reporter [UVM/RESOURCE/DUMP] === end of resource pool ===
    *********************************************************************************************************************************************************
# UVM_INFO design.sv(217) @ 0: uvm_test_top.env [EOE_TOPO] ==== UVM TOPOLOGY START ====
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_root.svh(579) @ 0: reporter [UVMTOP] UVM testbench topology:
# --------------------------------------------------------------
# Name                       Type                    Size  Value
# --------------------------------------------------------------
# uvm_test_top               test                    -     @360 
#   env                      environment             -     @372 
#     agnt                   agent                   -     @380 
#       drv                  driver                  -     @533 
#         rsp_port           uvm_analysis_port       -     @550 
#         seq_item_port      uvm_seq_item_pull_port  -     @541 
#       mon                  monitor                 -     @559 
#         ap                 uvm_analysis_port       -     @568 
#       seqr                 sequencer               -     @410 
#         rsp_export         uvm_analysis_export     -     @418 
#         seq_item_export    uvm_seq_item_pull_imp   -     @524 
#         arbitration_queue  array                   0     -    
#         lock_queue         array                   0     -    
#         num_last_reqs      integral                32    'd1  
#         num_last_rsps      integral                32    'd1  
#     scb                    scoreboard              -     @388 
#       ap_imp               uvm_analysis_imp        -     @583 
# --------------------------------------------------------------
# 
# UVM_INFO design.sv(221) @ 0: uvm_test_top.env [EOE_TOPO] ==== UVM TOPOLOGY END ====
# UVM_INFO design.sv(227) @ 0: uvm_test_top.env [EOE] file opened successfully
# UVM_INFO design.sv(82) @ 0: uvm_test_top.env.agnt.drv [ SOS DRIVER] intial values are reset in intial state 

    ***********************************************************************************************************************************************************
# UVM_INFO design.sv(253) @ 0: uvm_test_top.env [uvm_resource] datawidth=4 | reset_initial=0
    ***********************************************************************************************************************************************************
    
# UVM_INFO design.sv(280) @ 0: uvm_test_top [PRE_RESET] Type=test, FullName=uvm_test_top
# UVM_INFO design.sv(287) @ 0: uvm_test_top [RESET] Type=test, FullName=uvm_test_top
# UVM_INFO design.sv(294) @ 0: uvm_test_top [POST_RESET] Type=test, FullName=uvm_test_top
# UVM_INFO design.sv(301) @ 0: uvm_test_top [PRE_CONFIGURE] Type=test, FullName=uvm_test_top
# UVM_INFO design.sv(308) @ 0: uvm_test_top [CONFIGURE] Type=test, FullName=uvm_test_top
# UVM_INFO design.sv(315) @ 0: uvm_test_top [POST_CONFIGURE] Type=test, FullName=uvm_test_top
# UVM_INFO design.sv(322) @ 0: uvm_test_top [PRE_MAIN] Type=test, FullName=uvm_test_top
# UVM_INFO design.sv(329) @ 0: uvm_test_top [MAIN] Type=test, FullName=uvm_test_top
# UVM_INFO design.sv(336) @ 0: uvm_test_top [POST_MAIN] Type=test, FullName=uvm_test_top
# UVM_INFO design.sv(343) @ 0: uvm_test_top [PRE_SHUTDOWN] Type=test, FullName=uvm_test_top
# UVM_INFO design.sv(350) @ 0: uvm_test_top [SHUTDOWN] Type=test, FullName=uvm_test_top
# UVM_INFO design.sv(357) @ 0: uvm_test_top [POST_SHUTDOWN] Type=test, FullName=uvm_test_top
# UVM_INFO design.sv(182) @ 6: uvm_test_top.env.scb [SB] PASS: a=11, b=12, y=15
# UVM_INFO design.sv(182) @ 16: uvm_test_top.env.scb [SB] PASS: a=4, b=11, y=15
# UVM_INFO design.sv(182) @ 26: uvm_test_top.env.scb [SB] PASS: a=9, b=9, y=9
# UVM_INFO design.sv(182) @ 36: uvm_test_top.env.scb [SB] PASS: a=2, b=11, y=11
# UVM_INFO design.sv(182) @ 46: uvm_test_top.env.scb [SB] PASS: a=6, b=1, y=7
# UVM_INFO design.sv(182) @ 56: uvm_test_top.env.scb [SB] PASS: a=8, b=11, y=11
# UVM_INFO design.sv(182) @ 66: uvm_test_top.env.scb [SB] PASS: a=12, b=9, y=13
# UVM_INFO design.sv(182) @ 76: uvm_test_top.env.scb [SB] PASS: a=15, b=0, y=15
# UVM_INFO design.sv(182) @ 86: uvm_test_top.env.scb [SB] PASS: a=4, b=9, y=13
# UVM_INFO design.sv(182) @ 96: uvm_test_top.env.scb [SB] PASS: a=11, b=1, y=11
# UVM_INFO design.sv(182) @ 106: uvm_test_top.env.scb [SB] PASS: a=2, b=13, y=15
# UVM_INFO design.sv(182) @ 116: uvm_test_top.env.scb [SB] PASS: a=4, b=4, y=4
# UVM_INFO design.sv(182) @ 126: uvm_test_top.env.scb [SB] PASS: a=14, b=11, y=15
# UVM_INFO design.sv(182) @ 136: uvm_test_top.env.scb [SB] PASS: a=5, b=12, y=13
# UVM_INFO design.sv(370) @ 145: uvm_test_top [RUN_PHASE] Type=test, FullName=uvm_test_top
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_objection.svh(1270) @ 145: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_report_server.svh(847) @ 145: reporter [UVM/REPORT/SERVER] 
# --- UVM Report Summary ---
# 
# ** Report counts by severity
# UVM_INFO :   42
# UVM_WARNING :    0
# UVM_ERROR :    0
# UVM_FATAL :    0
# ** Report counts by id
# [ SOS DRIVER]     1
# [CONFIGURE]     1
# [EOE]     1
# [EOE_TOPO]     2
# [MAIN]     1
# [POST_CONFIGURE]     1
# [POST_MAIN]     1
# [POST_RESET]     1
# [POST_SHUTDOWN]     1
# [PRE_CONFIGURE]     1
# [PRE_MAIN]     1
# [PRE_RESET]     1
# [PRE_SHUTDOWN]     1
# [Questa UVM]     2
# [RESET]     1
# [RNTST]     1
# [RUN_PHASE]     1
# [SB]    14
# [SHUTDOWN]     1
# [TEST_DONE]     1
# [UVM/RELNOTES]     1
# [UVM/RESOURCE/DUMP]     4
# [UVMTOP]     1
# [uvm_resource]     1


 
