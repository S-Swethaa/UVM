// class driver extends uvm_driver #(seq_item);
//   `uvm_component_utils(driver)
  
//   function new ( string name = "driver" , uvm_component parent);
//     super.new(name,parent);
//   endfunction
  
//   virtual intf vif;
//   seq_item trans;
  
//   function void build_phase (uvm_phase phase);
//     super.build_phase(phase);
    
//     if(!uvm_config_db #(virtual intf)::get(this,"","vif",vif))
//       `uvm_fatal("DRIVER","NO UVM CONFIG DB FOUND IN DRIVER");
//   endfunction
  
//   task run_phase(uvm_phase phase);
//     super.run_phase(phase);
    
//     forever begin
      
//       trans=seq_item::type_id::create("trans");
      
//       seq_item_port.get_next_item(trans);
//      @(vif.drv_cb);

// vif.drv_cb.preset    <= trans.preset;
// vif.drv_cb.SADDR     <= trans.SADDR;
// vif.drv_cb.SWDATA    <= trans.SWDATA;
// vif.drv_cb.swrite    <= trans.swrite;
// vif.drv_cb.ptransfer <= trans.ptransfer;
//       end
       
//       while(vif.drv_cb.pready==0)
//          @(vif.drv_cb);
      
//       `uvm_info("DRIVER",trans.convert2string(),UVM_NONE)
       
//       seq_item_port.item_done();
//     end
//   endtask
// endclass

// class driver extends uvm_driver #(seq_item);

//   `uvm_component_utils(driver)

//   virtual intf vif;
//   seq_item trans;


//   function new(string name = "driver",
//                uvm_component parent);

//     super.new(name, parent);

//   endfunction


//   function void build_phase(uvm_phase phase);

//     super.build_phase(phase);

//     if(!uvm_config_db #(virtual intf)::get(this, "", "vif", vif))
//       `uvm_fatal("DRIVER", "Virtual interface not found")

//   endfunction


//  task run_phase(uvm_phase phase);

//   forever begin

//     seq_item_port.get_next_item(trans);

//     @(vif.drv_cb);

//     vif.drv_cb.preset    <= trans.preset;
//     vif.drv_cb.SADDR     <= trans.SADDR;
//     vif.drv_cb.SWDATA    <= trans.SWDATA;
//     vif.drv_cb.swrite    <= trans.swrite;
//     vif.drv_cb.ptransfer <= trans.ptransfer;

//     wait(vif.drv_cb.pready == 1);

//     `uvm_info("DRIVER",
//       trans.convert2string(),
//       UVM_NONE)

//     seq_item_port.item_done();

//   end

// endtask

// endclass
      

class driver extends uvm_driver #(seq_item);

  `uvm_component_utils(driver)

  virtual intf vif;
  seq_item trans;

  function new(string name = "driver",
               uvm_component parent);

    super.new(name, parent);

  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db #(virtual intf)::get(this, "", "vif", vif))
      `uvm_fatal("DRIVER", "Virtual interface not found")

  endfunction


  task run_phase(uvm_phase phase);

    forever begin

      seq_item_port.get_next_item(trans);

      @(vif.drv_cb);

      vif.drv_cb.preset    <= trans.preset;
      vif.drv_cb.SADDR     <= trans.SADDR;
      vif.drv_cb.SWDATA    <= trans.SWDATA;
      vif.drv_cb.swrite    <= trans.swrite;
      vif.drv_cb.ptransfer <= trans.ptransfer;

      // wait until pready becomes 1
     repeat(20) begin

  @(vif.drv_cb);

  if(vif.drv_cb.pready)
    break;

end

      `uvm_info("DRIVER",
                trans.convert2string(),
                UVM_LOW)

      seq_item_port.item_done();

    end

  endtask

endclass
