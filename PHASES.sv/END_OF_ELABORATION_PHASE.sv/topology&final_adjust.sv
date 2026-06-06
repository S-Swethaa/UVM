//end of elaboration phase
`include "uvm_macros.svh"
import uvm_pkg::*;

class test extends uvm_test;
  `uvm_component_utils(test)
  
  int a;
  function new(string name= "test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a=20;
        `uvm_info("build",$sformatf("a = %0d",a),UVM_LOW)
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    a=30;
            `uvm_info("build",$sformatf("a = %0d",a),UVM_LOW)
    uvm_top.print_topology();
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
          `uvm_info("run",$sformatf("a = %0d",a),UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass

 module test;
          initial
            begin
              run_test("test");
            end
        endmodule




    
