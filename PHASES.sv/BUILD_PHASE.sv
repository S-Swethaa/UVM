// Code your design here
//phases 
/* build_phase which is used to create a all uvm component + configure the component
it is the 1st phase which is build using function there is no time time simulation in this phase
it worked with top dowm methodology test component create and env component create to lower level component
using the syntax must register with uvm factory and build phase create the compoennet using 
"component_handle_name= class_name :: type_id::create("component handle name ",this)" -> for component
*/

`include "uvm_macros.svh";
import uvm_pkg::*;

class seqenc extends uvm_sequence_item;
  `uvm_object_utils(seqenc)
  rand int a;
  
  function new(string name = "sequenc");
    super.new(name);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  
  function new(string name = "test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  seqenc seq;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(seq == null)
      `uvm_info(get_type_name(),"OBJECT was not created in this ",UVM_LOW)
      else
      `uvm_info(get_type_name(),"OBJECT was created for this",UVM_LOW)
        
        seq=seqenc :: type_id::create("seq");
     if(seq == null)
      `uvm_info(get_type_name(),"OBJECT was not created in this ",UVM_LOW)
      else
      `uvm_info(get_type_name(),"OBJECT was created for this",UVM_LOW)
        endfunction
        endclass
        
        module test;
          initial
            begin
              run_test("test");
            end
        endmodule
    
      
     UVM_INFO @ 0: reporter [RNTST] Running test test...
UVM_INFO design.sv(28) @ 0: uvm_test_top [test] OBJECT was not created in this 
UVM_INFO design.sv(36) @ 0: uvm_test_top [test] OBJECT was created for this
UVM_INFO /apps/vcsmx/vcs/X-2025.06-SP1//etc/uvm-1.2/src/base/uvm_report_server.svh(904) @ 0: reporter [UVM/REPORT/SERVER] 
--- UVM Report Summary ---

** Report counts by severity
UVM_INFO :    4
UVM_WARNING :    0
UVM_ERROR :    0
UVM_FATAL :    0
** Report counts by id
[RNTST]     1
[UVM/RELNOTES]     1
[test]     2

$finish called from file "/apps/vcsmx/vcs/X-2025.06-SP1//etc/uvm-1.2/src/base/uvm_root.svh", line 532.
$finish at simulation time                    0
           V C S   S i m u l a t i o n   R e p o r t 
