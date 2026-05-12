class sequenc extends uvm_sequence #(seq_item);
  `uvm_object_utils(sequenc);
  
  function new(string name = "sequenc");
    super.new(name);
  endfunction
  
  task body();
    seq_item trans;
    
    repeat(10)begin
      trans=seq_item::type_id::create("trans");
      start_item(trans);
      if(!trans.randomize())
        `uvm_fatal("seq","randomization failed")
      
      finish_item(trans);
//       `uvm_info("SEQUENCE",trans.convert2string(),UVM_NONE)
    end
  endtask
endclass
