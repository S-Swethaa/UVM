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
