class environment extends uvm_env;
  `uvm_component_utils(environment)
  
  agent agnt;
  scoreboard scb;
  
  function new(string name = "environment", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase (phase);
    agnt = agent :: type_id :: create("agnt",this);
    scb = scoreboard :: type_id :: create ("scb",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agnt.mon.ap.connect(scb.an_imp);
  endfunction
  
endclass
