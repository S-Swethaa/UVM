class test extends uvm_test;

  `uvm_component_utils(test)

  environment env;

  function new(string name = "test", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = environment::type_id::create("env", this);

  endfunction

  task run_phase(uvm_phase phase);

    sequenc seq;

    phase.raise_objection(this);

    seq = sequenc::type_id::create("seq");

    seq.start(env.agnt.seqr);

    #100;

    phase.drop_objection(this);

  endtask

endclass
