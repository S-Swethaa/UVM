class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard)

  uvm_analysis_imp #(seq_item, scoreboard) an_imp;

  bit [31:0] mem [0:31];
  bit [31:0] expected_data;


  function new(string name="scoreboard",
               uvm_component parent);

    super.new(name,parent);

  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    an_imp = new("an_imp", this);

  endfunction


  function void write(seq_item trans);

    // VALID APB TRANSFER
    if(trans.pready) begin

      // WRITE
      if(trans.swrite) begin

        mem[trans.SADDR[4:0]] = trans.SWDATA;

        `uvm_info(" write pass     :   SCOREBOARD", 
          $sformatf("WRITE : ADDR=%0h DATA=%0h",
          trans.SADDR,
          trans.SWDATA),
          UVM_NONE)

      end


      // READ
      else begin

        expected_data = mem[trans.SADDR[4:0]];

        if(expected_data == trans.f_data) begin

          `uvm_info("SCOREBOARD",
            $sformatf("READ PASS : ADDR=%0h EXP=%0h ACT=%0h",
            trans.SADDR,
            expected_data,
            trans.f_data),
            UVM_NONE)

        end

        else begin

          `uvm_error("SCOREBOARD",
            $sformatf("READ FAIL : ADDR=%0h EXP=%0h ACT=%0h",
            trans.SADDR,
            expected_data,
            trans.f_data))

        end

      end

    end

  endfunction

endclass
