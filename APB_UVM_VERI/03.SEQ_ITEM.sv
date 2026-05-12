class seq_item extends uvm_sequence_item;

  `uvm_object_utils(seq_item)

  function new(string name = "seq_item");
    super.new(name);
  endfunction

  rand bit preset;
  rand bit swrite;
  rand bit ptransfer;

  rand bit [31:0] SADDR;
  rand bit [31:0] SWDATA;

  bit [31:0] f_data;
  bit pready;

  // constraint addr_c {
  //   SADDR inside {5,10,15};
  // }

  constraint reset_c {
    preset dist {1 := 90, 0 := 10};
  }

  constraint transfer_c {
    ptransfer dist {1 := 90, 0 := 10};
  }

  constraint write_c {
    swrite dist {1 := 50, 0 := 50};
  }

  function string convert2string();

    return $sformatf(
      "preset=%0d | swrite=%0d | ptransfer=%0d | ADDR=%0d | DATA=%0h | f_data=%0h | pready=%0d",
      preset, swrite, ptransfer,
      SADDR, SWDATA, f_data, pready
    );

  endfunction

endclass
