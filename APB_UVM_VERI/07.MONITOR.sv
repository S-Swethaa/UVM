class monitor extends uvm_monitor;

  `uvm_component_utils(monitor)

  virtual intf vif;

  seq_item trans;

  uvm_analysis_port #(seq_item) ap;


  function new(string name = "monitor",
               uvm_component parent);

    super.new(name, parent);

    ap = new("ap", this);

  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db #(virtual intf)::get(this,
                                           "",
                                           "vif",
                                           vif))
      `uvm_fatal("MONITOR",
                 "Virtual interface not found");

  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);

    forever begin

      @(vif.mon_cb);

      // Capture only valid transfer
//       if(vif.mon_cb.ptransfer &&
//          vif.mon_cb.pready) begin
      if(vif.mon_cb.ptransfer)begin
        
        wait (vif.mon_cb.pready==1)
       
        trans = seq_item::type_id::create("trans");

        trans.preset    = vif.mon_cb.preset;
        trans.swrite    = vif.mon_cb.swrite;
        trans.SADDR     = vif.mon_cb.SADDR;
        trans.SWDATA    = vif.mon_cb.SWDATA;
        trans.ptransfer = vif.mon_cb.ptransfer;
        trans.f_data    = vif.mon_cb.f_data;
        trans.pready    = vif.mon_cb.pready;

        ap.write(trans);

        `uvm_info("MONITOR",
                  trans.convert2string(),
                  UVM_NONE)

      end

    end

  endtask

endclass
