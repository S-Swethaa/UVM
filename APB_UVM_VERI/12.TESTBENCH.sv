`include "uvm_macros.svh"
import uvm_pkg::*;

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

  bit pclk;
  intf vif(pclk);
  initial
    pclk = 0;

  always #5 pclk = ~pclk;
  apb_top dut (
    .preset    (vif.preset),
    .pclk      (vif.pclk),
    .swrite    (vif.swrite),
    .ptransfer (vif.ptransfer),
    .SADDR     (vif.SADDR),
    .SWDATA    (vif.SWDATA),
    .f_data    (vif.f_data),
    .pready    (vif.pready)
  );

  initial begin
    uvm_config_db #(virtual intf)::set(null, "*", "vif",vif);
    run_test("test");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);
  end
  
  initial begin
  #5000;
  `uvm_fatal("TIMEOUT", "Simulation Timeout")
end

endmodule
